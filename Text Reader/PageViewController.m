//
//  PageViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/26/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

/*
    This is a UIViewController subclass, and it displays the image selected in PageListViewController inside of a UIScrollView. Previous
    and next buttons appear on a toolbar at the bottom of the view. The buttons are only enabled if there is a next or previous page. This
    view controller has customized rotation handling.
 
    _image is the image of the page to be displayed
    _imageView displays _image
    _scrollView holds _imageView to allow zooming and scrolling
    _pages is an array holding the file names of all the pages in the current book
    _savePath is a string holding the path to the current book folder
    _currentPageIndex is an int specifying which page in _pages we are currently displaying
    _previousButton is the toolbar button that lets users view the previous page
    _nextButton is the toolbar button that lets users view the next page
 */

#import "Page.h"
#import "PageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PageViewController ()

@property UIView *pageIndicator;
@property UILabel *indicatorLabel;

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
    
    //  Setup toolbar and navbar
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  This method handles rotation of the device. Configure the UIScrollView's size based on the new interface orientation. If the interface is going to be portrait, then make the image take up the entire view, and if it's going to be landscape, then horizontally center the image, but don't zoom in. 44 is the height of the navbar and toolbar, and 20 is the height of the status bar.
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

#pragma mark - Helper methods

- (void)setupPageIndicator
{
    //  Setup the page indicator (translucent bubble that says "x of y")
    _pageIndicator = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 80, 30)];
    _pageIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _pageIndicator.clipsToBounds = YES;
    _pageIndicator.layer.cornerRadius = 15.0;
    _pageIndicator.userInteractionEnabled = NO;
    
    _indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    _indicatorLabel.backgroundColor = [UIColor clearColor];
    _indicatorLabel.textColor = [UIColor whiteColor];
    _indicatorLabel.font = [UIFont fontWithName:@"Amoon1" size:17];
    _indicatorLabel.textAlignment = NSTextAlignmentCenter;
    _indicatorLabel.text = [NSString stringWithFormat:@"%i of %i", (_currentPageIndex + 1), [_book.pages count]];
    [_pageIndicator addSubview:_indicatorLabel];
    
    [self.view addSubview:_pageIndicator];
    
    //  The fade out animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:2.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    _pageIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    _indicatorLabel.alpha = 0;
    
    [UIView commitAnimations];
}

#pragma mark - Interface button actions

//  This is enacted when the previous buton is touched to go to the previous page
- (IBAction)previous:(id)sender
{
    //  Get rid of the page indicator every time you change the page. Setup the new one at the end of this method.
    [_pageIndicator removeFromSuperview];
    
    //  The button should only work if the current page isn't the first page
    if (_currentPageIndex > 0)
    {
        //  Set the current page index to the previous page index
        _currentPageIndex--;
        
        //  If the next button is disabled (i.e. the last page of the book is being displayed), then re-enable it since we are going back a page and a next page exists
        if (![_nextButton isEnabled])
        {
            [_nextButton setEnabled:YES];
        }
        
        //  Set the previous image to _imageView's image and the navbar title to the previous image's file name
        Page *page = [_book.pages objectAtIndex:_currentPageIndex];
        _imageView.image = [page pageImage];
        
        //  If we are now on the first page of the book, then disable the previous button
        if (_currentPageIndex == 0)
        {
            [_previousButton setEnabled:NO];
        }
        
        //  Setup the page indicator (translucent bubble that says "x of y")
        [self setupPageIndicator];
    }
}

//  This is enacted when the next button is touched to go to the next page
- (IBAction)next:(id)sender
{
    //  Get rid of the page indicator every time you change the page. Setup the new one at the end of this method.
    [_pageIndicator removeFromSuperview];
    
    //  The button should only work if the current page isn't the last page
    if (_currentPageIndex < [_book.pages count] - 1)
    {
        //  Set the current page index to the next page index
        _currentPageIndex++;
        
        //  If the previous button is disabled (i.e. the first page of the book is being displayed), then re-enable it since we are going forward a page and a previous page exists
        if (![_previousButton isEnabled])
        {
            [_previousButton setEnabled:YES];
        }
        
        //  Set the next image to _imageView's image and the navbar title to the next image's file name
        Page *page = [_book.pages objectAtIndex:_currentPageIndex];
        _imageView.image = [page pageImage];
        
        //  If we are now on the last page of the book, then disable the next button
        if (_currentPageIndex == [_book.pages count] - 1)
        {
            [_nextButton setEnabled:NO];
        }
        
        //  Setup the page indicator (translucent bubble that says "x of y")
        [self setupPageIndicator];
    }
}

#pragma mark - UIScrollView delegate methods

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

@end
