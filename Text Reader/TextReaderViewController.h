//
//  TextReaderViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/8/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//
#import "DrawingView.h"
#import <UIKit/UIKit.h>

@interface TextReaderViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, UIPopoverControllerDelegate>

@property dispatch_queue_t backgroundQueue;
@property UIImagePickerController *imagePicker;
@property UIImage *backgroundImage;
@property UIImageView *backgroundImageView;
@property UIScrollView *backgroundImageScrollView;
@property UIPopoverController *popOver;
@property int height;
@property int width;
@property NSUInteger bytesPerPixel;
@property NSUInteger bytesPerRow;
@property NSUInteger bitsPerComponent;
@property int lineThickness;
@property DrawingView *drawingView;
@property UIView *imageAndPathView;
@property UIView *loadingHUD;
@property UIActivityIndicatorView *loadingView;
@property UILabel *loadingLabel;
@property UIBarButtonItem *cameraButton;
@property UIBarButtonItem *drawLinesButton;
@property NSString *savePath;
@property NSString *backgroundImageName;

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)callCamera;
- (void)drawLines;
- (void)save;
- (void)saveWithLines;

@end
