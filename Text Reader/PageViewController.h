//
//  PageViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/26/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGBook.h"
#import <UIKit/UIKit.h>

@interface PageViewController : UIViewController <UIScrollViewDelegate>

@property UIImage *image;
@property UIImageView *imageView;
@property UIScrollView *scrollView;
@property SGBook *book;
@property NSString *savePath;
@property int currentPageIndex;
@property IBOutlet UIBarButtonItem *previousButton;
@property IBOutlet UIBarButtonItem *nextButton;
@property IBOutlet UIBarButtonItem *actionButton;

- (void)setupPageIndicator;
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)openIn:(id)sender;

@end
