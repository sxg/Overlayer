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


@interface SGTextRecognizer ()

@property (readwrite, strong, nonatomic) Tesseract *tesseract;
@property (readwrite, strong, nonatomic) void (^update)(NSUInteger);

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
        //  Setup Tesseract with the training data
        self.tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];
        self.tesseract.delegate = self;
        
        //  Set the character whitelist (Tesseract will look for these characters in images)
        [self.tesseract setVariableValue:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\"\',.!$%()*?;:/\\-&@" forKey:@"tessedit_char_whitelist"];
    }
    return self;
}

#pragma mark - Text Recognition

- (void)recognizeTextOnImage:(UIImage *)image update:(void (^)(NSUInteger))update completion:(void (^)(NSString *, NSArray *))completion
{
    //  Set the progress update block
    self.update = update;
    
    //  Filter the image to get just the text
    GPUImageAdaptiveThresholdFilter *adaptiveThresholdFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    UIImage *blackWhiteImage = [adaptiveThresholdFilter imageByFilteringImage:image];
    
    //  Set the image and recognize it (synchronous)
    [self.tesseract setImage:blackWhiteImage];
    [self.tesseract recognize];
    
    //  Clear the progress update block
    self.update = nil;
    
    //  Return the important data in the completion block
    if (completion) {
        completion(self.tesseract.recognizedText, self.tesseract.recognizedTextBoxes);
    }
}

#pragma mark - Tesseract Delegate

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
    NSLog(@"progress: %d", tesseract.progress);
    if (self.update) {
        self.update((NSUInteger)(tesseract.progress/100));
    }
    return NO;
}

@end
