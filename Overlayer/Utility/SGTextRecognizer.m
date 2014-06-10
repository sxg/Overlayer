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

//  Models
#import "SGDocument.h"

//  Utilities
#import "SGUtility.h"
#import "SGDocumentManager.h"


@interface SGTextRecognizer ()

@property (readwrite, assign) NSInteger imageHeight;
@property (readwrite, strong, nonatomic) void (^update)(CGFloat);

@end

@implementation SGTextRecognizer

static SGTextRecognizer *sharedClient;

#pragma mark - Getting the Shared SGTextRecognizer Instance

+ (SGTextRecognizer *)sharedClient
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	                      sharedClient = [[SGTextRecognizer alloc] init];
		      });
	return sharedClient;
}

#pragma mark - Initializing an SGTextRecognizer Object

- (instancetype)init
{
	self = [super init];
	if (self) {

	}
	return self;
}

#pragma mark - Text Recognition

- (void)recognizeTextOnImage:(UIImage *)image update:(void (^)(CGFloat))update completion:(void (^)(UIImage *, NSString *, NSDictionary *))completion
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
        }
        NSError *error2;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error2];
        if (error2) {
            NSLog(@"%@", error2);
        }
        
        //  Draw the lines
        UIImageView *imageView = [[UIImageView alloc] initWithImage:upOrientedImage];
        self.imageHeight = imageView.frame.size.height;
        NSMutableDictionary *recognizedRects = [NSMutableDictionary dictionary];
        for (NSDictionary *recognizedWord in jsonDictionary) {
            CGRect rect = [self rectForString:recognizedWord[@"box"]];
            SGDoubleStrikethroughView *view = [[SGDoubleStrikethroughView alloc] initWithFrame:rect];
            [imageView addSubview:view];
        }
        
        //  Flatten the lines into an image
        UIGraphicsBeginImageContext(upOrientedImage.size);
        [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *imageWithLines = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //  Return the important data in the completion block
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(imageWithLines, nil, recognizedRects);
            });
        }
    }] resume];
}

#pragma mark - Helpers

- (CGRect)rectForString:(NSString *)string
{
    NSArray *boxComponents = [string componentsSeparatedByString:@" "];
    CGFloat x = [boxComponents[1] floatValue];
    CGFloat y = [boxComponents[4] floatValue];
    CGFloat width = [boxComponents[3] floatValue] - [boxComponents[1] floatValue];
    CGFloat height = [boxComponents[2] floatValue] - [boxComponents[4] floatValue];
    return CGRectMake(x, y, width, height);
}

@end
