//
//  SGMainViewController.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/9/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

//  Frameworks
#import <TesseractOCR/TesseractOCR.h>
#import <QuickLook/QuickLook.h>


@interface SGMainViewController : UIViewController <TesseractDelegate, UIImagePickerControllerDelegate,  UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, QLPreviewControllerDataSource>

@end
