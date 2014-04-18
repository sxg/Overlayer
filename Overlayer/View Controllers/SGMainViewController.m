//
//  SGMainViewController.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/9/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGMainViewController.h"

//  Frameworks
#import <GPUImage/GPUImage.h>

//  Utility
#import "SGUtility.h"

//  Views
#import "SGDoubleStrikethroughView.h"


@interface SGMainViewController ()

@property (readwrite, weak, nonatomic) IBOutlet UIImageView *imageView;

@property (readwrite, weak, nonatomic) IBOutlet UIView *sidePaneView;

@property (readwrite, assign, getter = isDisplayingSidePane) BOOL displayingSidePane;

@end

@implementation SGMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    for (NSValue *rectValue in [self.tesseract recognizedTextBoxes]) {
    //        CGRect rect = [rectValue CGRectValue];
    //        CGRect scaledRect = CGRectMake(rect.origin.x/2/1.26, rect.origin.y/2/1.26, rect.size.width/2/1.26, rect.size.height/2/1.26);
    //        SGDoubleStrikethroughView *view = [[SGDoubleStrikethroughView alloc] initWithFrame:scaledRect];
    //        [self.imageView addSubview:view];
    //    }
    
    self.displayingSidePane = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Actions

- (IBAction)didTapToggleSidePaneButton:(UIButton *)sender
{
    if (self.isDisplayingSidePane) {
        [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGRect endFrame = CGRectMake(CGRectGetMinX(self.sidePaneView.frame),
                                         (-1*CGRectGetHeight(self.sidePaneView.frame))+30,
                                         CGRectGetWidth(self.sidePaneView.frame),
                                         CGRectGetHeight(self.sidePaneView.frame));
            self.sidePaneView.frame = endFrame;
            
        } completion:^(BOOL finished) {
            
        }];
        self.displayingSidePane = NO;
    } else {
        [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGRect endFrame = CGRectMake(CGRectGetMinX(self.sidePaneView.frame),
                                         CGRectGetMinY(self.view.frame),
                                         CGRectGetWidth(self.sidePaneView.frame),
                                         CGRectGetHeight(self.sidePaneView.frame));
            self.sidePaneView.frame = endFrame;
            
        } completion:^(BOOL finished) {
            
        }];
        self.displayingSidePane = YES;
    }
}

@end
