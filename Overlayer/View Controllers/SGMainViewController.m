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

@end

@implementation SGMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GPUImageAdaptiveThresholdFilter *adaptiveThresholdFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    UIImage *blackWhiteImage = [adaptiveThresholdFilter imageByFilteringImage:[UIImage imageNamed:@"4"]];
    
    //GPUImageLowPassFilter *lowPassFilter = [[GPUImageLowPassFilter alloc] init];
    //[self.imageView setImage:[lowPassFilter imageByFilteringImage:self.imageView.image]];
    
    //[self.imageView setImage:[SGUtility imageWithImage:self.imageView.image scaledByFactor:0.2]];
    
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];
    tesseract.delegate = self;
    
    [tesseract setVariableValue:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\"\',.!$%()*?;:/\\-&@" forKey:@"tessedit_char_whitelist"];
    [tesseract setImage:blackWhiteImage];
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
    
    for (NSValue *rectValue in [tesseract recognizedTextBoxes]) {
        CGRect rect = [rectValue CGRectValue];
        CGRect scaledRect = CGRectMake(rect.origin.x/2/1.26, rect.origin.y/2/1.26, rect.size.width/2/1.26, rect.size.height/2/1.26);
        SGDoubleStrikethroughView *view = [[SGDoubleStrikethroughView alloc] initWithFrame:scaledRect];
        [self.imageView addSubview:view];
    }
    
    tesseract = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tesseract delegate

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

@end
