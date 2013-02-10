//
//  PageViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/26/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (IBAction)previous:(id)sender
{
    if (_currentPageIndex > 0)
    {
        _currentPageIndex--;
        
        if (![_nextButton isEnabled])
        {
            [_nextButton setEnabled:YES];
        }
        
        NSString *page = [_pages objectAtIndex:_currentPageIndex];
        NSString *path = [_savePath stringByAppendingPathComponent:page];
        _imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
        [self.navigationItem setTitle:page];
        
        if (_currentPageIndex == 0)
        {
            [_previousButton setEnabled:NO];
        }
    }
}

- (IBAction)next:(id)sender
{
    if (_currentPageIndex < [_pages count] - 1)
    {
        _currentPageIndex++;

        if (![_previousButton isEnabled])
        {
            [_previousButton setEnabled:YES];
        }
        
        NSString *page = [_pages objectAtIndex:_currentPageIndex];
        NSString *path = [_savePath stringByAppendingPathComponent:page];
        _imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
        [self.navigationItem setTitle:page];
        
        if (_currentPageIndex == [_pages count] - 1)
        {
            [_nextButton setEnabled:NO];
        }
    }
}

@end
