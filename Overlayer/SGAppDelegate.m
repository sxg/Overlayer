//
//  SGAppDelegate.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/9/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGAppDelegate.h"

//  Frameworks
#import <UIImage+PDF/UIImage+PDF.h>
#import <Crashlytics/Crashlytics.h>

//  Controllers
#import "SGMainViewController.h"

//  Utilities
#import "SGTextRecognizer.h"
#import "SGUtility.h"


NSString * const kSGFontAmoon = @"Amoon1";


@implementation SGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [Crashlytics startWithAPIKey:@"c0946e755af032a6ed749d647f73248bc823fb73"];
    
    UIImage *image1 = [UIImage imageNamed:@"TestImage1"];
    UIImage *image2 = [UIImage imageNamed:@"TestImage2"];
    image1 = [SGUtility imageWithImage:image1 scaledToWidth:968.0f];
    image2 = [SGUtility imageWithImage:image2 scaledToWidth:968.0f];
    [SGTextRecognizer recognizeTextOnImages:@[image1, image2] completion:^(NSData *pdfWithRecognizedText, NSArray *recognizedText, NSArray *recognizedRects) {
        NSLog(@"all done");
    }];

	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if ([url isFileURL]) {
		//  Convert PDF files to PNG and set the image
		NSString *pathExtension = [[url absoluteString] pathExtension];
		UIImage *image;
		if ([pathExtension isEqualToString:@"pdf"]) {
			image = [UIImage imageWithPDFURL:url atWidth:968.0f];
		} else if ([pathExtension isEqualToString:@"png"] || [pathExtension isEqualToString:@"jpg"] || [pathExtension isEqualToString:@"jpeg"]) {
			image = [[UIImage alloc] initWithContentsOfFile:[url path]];
			CGFloat width;
			if (image.size.width > 968.0f) {
				width = 968.0f;
			} else {
				width = image.size.width;
			}
			image = [SGUtility imageWithImage:image scaledToWidth:968.0f];
		}

		if (image) {
			SGMainViewController *mainVC = (SGMainViewController *)self.window.rootViewController;
			[mainVC createDocumentWithImage:image];
			return YES;
		}
	}
	return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
