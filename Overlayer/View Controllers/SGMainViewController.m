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
#import <MBProgressHUD/MBProgressHUD.h>
#import <StandardPaths/StandardPaths.h>

//  Utility
#import "SGUtility.h"
#import "SGTextRecognizer.h"

//  Views
#import "SGDoubleStrikethroughView.h"


@interface SGMainViewController ()

@property (readwrite, weak, nonatomic) IBOutlet UIImageView *imageView;

@property (readwrite, weak, nonatomic) IBOutlet UIView *sidePaneView;
@property (readwrite, weak, nonatomic) IBOutlet UIButton *toggleSidePaneViewButton;

@property (readwrite, assign, getter = isDisplayingSidePane) BOOL displayingSidePane;

@end

@implementation SGMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.displayingSidePane = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    
    //  Draw lines on the image and show a progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Drawing Lines";
    [[SGTextRecognizer sharedClient] recognizeTextOnImage:info[UIImagePickerControllerOriginalImage] update:^(CGFloat progress) {
        hud.progress = progress;
    } completion:^(UIImage *imageWithLines, NSString *recognizedText, NSArray *recognizedCharacterRects) {
        self.imageView.image = imageWithLines;
        [hud hide:YES];
    }];
}

#pragma mark - UI Actions

- (IBAction)didTapToggleSidePaneButton:(UIButton *)sender
{
    //  Setup
    CGRect endSidePaneViewFrame;
    CGFloat endToggleSidePaneViewButtonAngle;
    if (self.isDisplayingSidePane) {
        endSidePaneViewFrame = CGRectMake(CGRectGetMinX(self.sidePaneView.frame),
                              (-1*CGRectGetHeight(self.sidePaneView.frame))+42,
                              CGRectGetWidth(self.sidePaneView.frame),
                              CGRectGetHeight(self.sidePaneView.frame));
        endToggleSidePaneViewButtonAngle = M_PI;
    } else {
        endSidePaneViewFrame = CGRectMake(CGRectGetMinX(self.sidePaneView.frame),
                                     CGRectGetMinY(self.view.frame),
                                     CGRectGetWidth(self.sidePaneView.frame),
                                     CGRectGetHeight(self.sidePaneView.frame));
        endToggleSidePaneViewButtonAngle = 0;
    }
    
    //  Animate
    __block SGMainViewController *blockSelf = self;
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        //  Push the side pane view
        blockSelf.sidePaneView.frame = endSidePaneViewFrame;
        
        //  Rotate the toggle side pane button
        blockSelf.toggleSidePaneViewButton.transform = CGAffineTransformMakeRotation(endToggleSidePaneViewButtonAngle);
        
    } completion:^(BOOL finished) {
        blockSelf.displayingSidePane = !blockSelf.isDisplayingSidePane;
    }];
}

- (IBAction)didTapCameraButton:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"This device doesn't have a camera available to use." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

@end
