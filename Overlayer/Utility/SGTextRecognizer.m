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

@property (readwrite, strong, nonatomic) Tesseract *tesseract;
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
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

	                       //  Set the progress update block
	                       self.update = update;

	                       //  Filter the image to get just the text
	                       GPUImageAdaptiveThresholdFilter *adaptiveThresholdFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
	                       UIImage *blackWhiteImage = [adaptiveThresholdFilter imageByFilteringImage:upOrientedImage];

	                       //  Setup Tesseract with the training data
	                       self.tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];
	                       self.tesseract.delegate = self;

	                       //  Set the character whitelist (Tesseract will look for these characters in images)
	                       //[self.tesseract setVariableValue:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\"\',.!$%()*?;:/\\-&@" forKey:@"tessedit_char_whitelist"];

	                       //  Set the image and recognize it (synchronous)
	                       [self.tesseract setImage:blackWhiteImage];
	                       [self.tesseract recognize];

	                       self.update = nil;

	                       //  Draw the lines
	                       UIImageView *imageView = [[UIImageView alloc] initWithImage:upOrientedImage];
	                       NSDictionary *recognizedRects = self.tesseract.characterBoxes;
	                       for (NSValue *rectValue in recognizedRects) {
	                               CGRect rect = [rectValue CGRectValue];
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
	                                                      completion(imageWithLines, self.tesseract.recognizedText, recognizedRects);
	                                                      self.tesseract = nil;
						      });
			       }
		       });
}

#pragma mark - Tesseract Delegate

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
	//
	//  This method is called from a background thread
	//

	NSLog(@"progress: %d", tesseract.progress);
	if (self.update) {
		dispatch_async(dispatch_get_main_queue(), ^{
		                       self.update((CGFloat)((CGFloat)tesseract.progress / 100.0f));
			       });
	}
	return NO;
}

@end
