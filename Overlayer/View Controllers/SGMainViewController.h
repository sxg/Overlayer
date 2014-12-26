//
//  SGMainViewController.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/9/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

//  Frameworks
#import <QuickLook/QuickLook.h>

extern NSString *SGMainViewControllerDidTapNewDocumentButtonNotification;
extern NSString *SGMainViewControllerDidFinishCreatingDocumentNotification;


@interface SGMainViewController : UIViewController <UIImagePickerControllerDelegate,  UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, QLPreviewControllerDataSource, UIScrollViewDelegate>

- (void)createDocumentWithImages:(NSArray *)images;

@end
