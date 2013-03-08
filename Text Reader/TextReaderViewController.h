//
//  TextReaderViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/8/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//
#import "DrawingView.h"
#import <UIKit/UIKit.h>

@protocol TextReaderViewControllerDelegate <NSObject>

@optional
- (void)finishedSavingImage:(NSString*)fileName toPath:(NSString*)path;

@end

@interface TextReaderViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, UIPopoverControllerDelegate>

@property (readonly)dispatch_queue_t backgroundQueue;
@property (readonly)UIImage *backgroundImage;
@property (readonly)UIImageView *backgroundImageView;
@property (readonly)UIScrollView *backgroundImageScrollView;
@property (readonly)int height;
@property (readonly)int width;
@property (readonly)NSUInteger bytesPerPixel;
@property (readonly)NSUInteger bytesPerRow;
@property (readonly)NSUInteger bitsPerComponent;
@property (readonly)float lineThickness;
@property (readonly)DrawingView *drawingView;
@property (readonly)UIView *imageAndPathView;
@property (readonly)UIBarButtonItem *cameraButton;
@property (readonly)UIBarButtonItem *drawLinesButton;
@property NSString *savePath;
@property NSString *backgroundImageName;
@property id <TextReaderViewControllerDelegate> delegate;

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)callCamera;
- (void)drawLines;
- (void)save;
- (void)saveWithLines;

@end
