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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //reverse self.view.frame.size.height and self.view.frame.size.width since the rotation hasn't happened yet
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [_scrollView setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.height - _scrollView.frame.size.width) / 2, 0, _scrollView.frame.size.width, [UIScreen mainScreen].bounds.size.width - 44 - 20 - 44)];
    }
    else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        [_scrollView setFrame:CGRectMake(0, 0, _scrollView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 44 - 20 - 44)];
    }
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
