//
//  SGTextRecognizer.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/9/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGTextRecognizer.h"

//  Frameworks
#import <GPUImage/GPUImage.h>
#import <QuartzCore/QuartzCore.h>
#import <StandardPaths/StandardPaths.h>

//  Views
#import "SGDoubleStrikethroughView.h"

//  Utilities
#import "SGUtility.h"


@interface SGTextRecognizer ()

@end

@implementation SGTextRecognizer

#pragma mark - Text Recognition

+ (void)recognizeTextOnImages:(NSArray *)images completion:(void (^)(NSData *pdfWithRecognizedText, NSString *recognizedText, NSDictionary *recognizedRects))completion
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSOperationQueue *q = [[NSOperationQueue alloc] init];
    q.maxConcurrentOperationCount = 1;
    
    for (NSInteger i = 0; i < images.count; i++) {
        [q addOperationWithBlock:^{
            [self recognizeTextOnImage:images[i] completion:^(UIImage *imageWithRecognizedText) {
                NSLog(@"done %ld", (long)i);
                dispatch_semaphore_signal(sem);
            }];
        }];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (NSInteger i = 0; i < images.count; i++) {
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, nil, nil);
        });
    });
}

#pragma mark - Helpers

+ (void)recognizeTextOnImage:(UIImage *)image completion:(void (^)(UIImage *imageWithRecognizedText))completion
{
    //  Get the image properly oriented
    UIImage *upOrientedImage = [SGUtility imageOrientedUpFromImage:image];
    
    //  Filter the image to get just the text
    GPUImageAdaptiveThresholdFilter *adaptiveThresholdFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    UIImage *blackWhiteImage = [adaptiveThresholdFilter imageByFilteringImage:upOrientedImage];
    
    //  Create JSON
    NSString *base64StringEncodedImage = [UIImagePNGRepresentation(blackWhiteImage) base64EncodedStringWithOptions:0];
    NSDictionary *jsonDictionary = @{@"imageData": base64StringEncodedImage};
    
    //  Make request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [session.configuration setTimeoutIntervalForRequest:60];
    [session.configuration setTimeoutIntervalForResource:60];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://overlayer-ocr.herokuapp.com/api/v1/recognize"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    [[session uploadTaskWithRequest:request fromData:jsonData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            [[[UIAlertView alloc] initWithTitle:@"Internet Error" message:@"Make sure you are connected to the internet." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        }
        NSError *error2;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error2];
        if (error2) {
            NSLog(@"%@", error2);
        }
        
        //  Draw the lines
        UIImageView *imageView = [[UIImageView alloc] initWithImage:upOrientedImage];
        NSMutableDictionary *recognizedRects = [NSMutableDictionary dictionary];
        for (NSDictionary *recognizedWord in jsonDictionary) {
            CGRect rect = [self rectForString:recognizedWord[@"box"]];
            NSLog(@"%@", recognizedWord[@"box"]);
            NSValue *rectValue = [NSValue valueWithCGRect:rect];
            recognizedRects[rectValue] = recognizedWord[@"word"];
            
            SGDoubleStrikethroughView *view = [[SGDoubleStrikethroughView alloc] initWithFrame:rect word:recognizedWord[@"word"]];
            [imageView addSubview:view];
        }
        
        //  Flatten the lines into an image
        UIGraphicsBeginImageContext(upOrientedImage.size);
        [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *imageWithRecognizedText = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //  Return the important data in the completion block
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(imageWithRecognizedText);
            });
        }
    }] resume];
}

+ (CGRect)rectForString:(NSString *)string
{
    NSArray *boxComponents = [string componentsSeparatedByString:@" "];
    CGFloat x = [boxComponents[1] floatValue];
    CGFloat y = [boxComponents[4] floatValue];
    CGFloat width = [boxComponents[3] floatValue] - [boxComponents[1] floatValue];
    CGFloat height = [boxComponents[2] floatValue] - [boxComponents[4] floatValue];
    return CGRectMake(x, y, width, height);
}

@end
