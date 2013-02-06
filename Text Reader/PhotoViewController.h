//
//  PhotoViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/26/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController <UIScrollViewDelegate>

@property UIImage *image;
@property UIImageView *imageView;
@property UIScrollView *scrollView;

@end
