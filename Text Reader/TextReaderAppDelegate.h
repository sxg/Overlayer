//
//  TextReaderAppDelegate.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/8/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Book.h"
#import <UIKit/UIKit.h>

@interface TextReaderAppDelegate : UIResponder <UIApplicationDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)customizeAppearance;

@end
