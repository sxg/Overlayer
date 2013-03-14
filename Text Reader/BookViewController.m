//
//  BookViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/13/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "BookViewController.h"
#import "PageViewController.h"
#import "TextReaderViewController.h"
#import "UIImage+LineDrawer.h"
#import "DrawingView.h"
#import "Page.h"
#import <dispatch/dispatch.h>
#import <DropboxSDK/DropboxSDK.h>
#import <QuartzCore/QuartzCore.h>

@interface BookViewController ()

@property PageViewController *pageViewController;
@property dispatch_queue_t backgroundQueue;
@property DBMetadata *folderMetadata;
@property IBOutlet UIBarButtonItem *closeButton;
@property UIBarButtonItem *drawLinesButton;
@property IBOutlet UIBarButtonItem *openButton;
@property IBOutlet UIBarButtonItem *deleteButton;
@property IBOutlet UIBarButtonItem *cameraButton;

@end

@implementation BookViewController

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
	// Do any additional setup after loading the view
    
    [self.navigationController setToolbarHidden:NO];
    
    //  Set navbar color
    float grayVal = ((float)66/(float)255);
    UIColor *customGray = [UIColor colorWithRed:grayVal green:grayVal blue:grayVal alpha:1.0];
    [self.navigationController.navigationBar setTintColor:customGray];
    [self.navigationController.toolbar setTintColor:customGray];
    
    //  Setup draw lines button
    _drawLinesButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(drawLines)];
    _drawLinesButton.title = @"Draw Lines";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI button methods

- (void)drawLines
{
    dispatch_async(_backgroundQueue, ^{
        //  Iterate through all the page file names in this book individually
        for (Page *page in [_book pages])
        {
            //  Get the PageListViewCell corresponding to the current page file name and mark it as currently processing
#warning mark the page in page control as processing
            
            //  Get the actual image object and store it in a UIImage
            UIImage *image = [page pageImage];
            
            //  If the image is unprocessed since unprocessed images have not been sized down to 1024x768
            if (image.size.width > 768)
            {
                //  Resize the image
                image = [image imageScaledToSize:CGSizeMake(768, 1024)];
                
                // imageAndPathView is a container view for both drawingView and imageView. drawingView is where the strikethroughs will be drawn by a UIBezierPath, and imageView is where the current image is displayed. imageAndPathView can be used to create a new image that contains the strikethroughs.
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                UIView *imageAndPathView = [[UIView alloc] initWithFrame:imageView.frame];
                [imageAndPathView addSubview:imageView];
                DrawingView *drawingView = [[DrawingView alloc] initWithFrame:imageView.frame];
                [imageAndPathView addSubview:drawingView];
                [imageAndPathView sendSubviewToBack:imageView];
                
                //  Get the strikethrough width from user defaults if it is set
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSNumber *lineThicknessWrapper = [defaults objectForKey:@"strikethroughWidth"];
                float lineThickness;
                if (lineThicknessWrapper == nil)
                {
                    lineThickness = 1.0;
                    //  Save 1.0 as the line thickness in user defaults
                    [defaults setObject:[[NSNumber alloc] initWithFloat:1.0] forKey:@"strikethroughWidth"];
                }
                else
                {
                    lineThickness = [lineThicknessWrapper floatValue];
                }
                
                //  The first method actually draws the strikethroughs on the drawingView, and the second method consolidates the strikethroughs and the original image into one image and saves it with the same name as the original image
                [image identifyCharactersWithlineThickness:lineThickness onView:drawingView bytesPerPixel:4 bitsPerComponent:8];
                
                //  Dropbox rest client MUST be used on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self saveWithLinesAndName:[page pageName] onContainerView:imageAndPathView];
                });
            }
            
            //  Unshift the UILabel and remove the UIActivityIndicator on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
#warning undo the page control modifications/animations
            });
        }
    });
}

- (IBAction)closeModalViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteBook:(id)sender
{
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete %@", _book.title]
                                                          message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", _book.title]
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Delete", nil];
    [deleteAlert show];
}

#pragma mark - Helper methods

//  This method takes a container view that has a subview containing the original image and another subview that has the strikethroughs drawn on it by a UIBezierPath and saves the container view as an image with the name pageName.png
- (void)saveWithLinesAndName:(NSString*)pageName onContainerView:(UIView*)imageAndPathView
{
    //  The path to the new image
    NSString *imagePath = [_savePath stringByAppendingPathComponent:pageName];
    
    //  Setup a new graphics context from the container view and create an image from that context
    UIGraphicsBeginImageContext(imageAndPathView.bounds.size);
    [imageAndPathView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //  Save the new image
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    
    [self finishedSavingImage:pageName toPath:imagePath uploadToDropbox:YES];
}

- (DBRestClient*)restClient
{
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    
    return _restClient;
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self closeModalViewController:nil];
        
        //  Delete locally
        [[NSFileManager defaultManager] removeItemAtPath:_savePath error:nil];
        
        //  Delete from Dropbox
        NSString *path = [@"/" stringByAppendingPathComponent:_book.title];
        [[self restClient] deletePath:path];
        
        //  Reload the collection view
        [_bookListViewController viewDidAppear:YES];
    }
}

#pragma mark - Text reader delegate

- (void)finishedSavingImage:(NSString *)fileName toPath:(NSString *)path uploadToDropbox:(bool)shouldUpload
{
    if (shouldUpload)
    {
        //  Save image to Dropbox
        NSString *destDir = [@"/" stringByAppendingPathComponent:_book.title];
        
        //  Look for an existing file
        [[self restClient] loadMetadata:destDir];
        NSString *parentRev = nil;
        for (DBMetadata *file in _folderMetadata.contents)
        {
            if ([file.filename isEqualToString:fileName])
            {
                parentRev = file.rev;
            }
        }
        _folderMetadata = nil;
        
        [[self restClient] uploadFile:fileName toPath:destDir withParentRev:parentRev fromPath:path];
    }
    
    //  Reload the book and the table
    _book = [[Book alloc] initWithPath:_savePath];
    
#warning update the page control
    //[self.tableView reloadData];
}

#pragma mark - Segue control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //  If the camera button has been touched, then setup TextReaderViewController
    if ([segue.identifier isEqualToString:@"CameraFromDetail"])
    {
        TextReaderViewController *textReaderViewController = segue.destinationViewController;
        [textReaderViewController setDelegate:self];
        [textReaderViewController setSavePath:_savePath];
    }
    //  If a page's cell in the table has been selected, then setup PageViewController
    else if ([segue.identifier isEqualToString:@"ViewPage"])
    {
        _pageViewController = segue.destinationViewController;
        [self setupPageViewControllerSegueWithPage:[_book.pages objectAtIndex:0] andIndex:0];
    }
}

//  Page is the page that should be displayed in PVC, and index is the index of that page
- (void)setupPageViewControllerSegueWithPage:(Page*)page andIndex:(NSUInteger)index
{
    //  Setup PageViewController's ivars and navbar title
    _pageViewController.book = _book;
    _pageViewController.savePath = _savePath;
    _pageViewController.currentPageIndex = index;
    [_pageViewController.navigationItem setTitle:_book.title];
    
    //  Create and configure a UIScrollView within which the selected image will be displayed, and get the selected image in a UIImage, and put it in a UIImageView
    _pageViewController.scrollView = [[UIScrollView alloc] init];
    [_pageViewController.scrollView setDelegate:_pageViewController];
    _pageViewController.image = [page pageImage];
    _pageViewController.imageView = [[UIImageView alloc] initWithImage:_pageViewController.image];
    [_pageViewController.scrollView addSubview:_pageViewController.imageView];
    [_pageViewController.scrollView setContentSize:CGSizeMake(_pageViewController.imageView.image.size.width, _pageViewController.imageView.image.size.height)];
    [_pageViewController.scrollView setMinimumZoomScale:1.0];
    [_pageViewController.scrollView setMaximumZoomScale:3.0];
    [_pageViewController.view addSubview:_pageViewController.scrollView];
    
    //  If the selected page is the first page, then disable the previous button. If the selected page is the last page, then disable the next button. Two "if"s are used in case there is only one image in the book and the first page is also the last page.
    if (_pageViewController.currentPageIndex == 0)
    {
        [_pageViewController.previousButton setEnabled:NO];
    }
    if (_pageViewController.currentPageIndex == [_pageViewController.book.pages count] - 1)
    {
        [_pageViewController.nextButton setEnabled:NO];
    }
    
    //  Configure the UIScrollView's size based on the current interface orientation. If the interface is portrait, then make the image take up the entire view, and if it's landscape, then horizontally center the image, but don't zoom in. 44 is the height of the navbar and toolbar, and 20 is the height of the status bar.
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        [_pageViewController.scrollView setFrame:CGRectMake(0, 0, _pageViewController.view.frame.size.width, _pageViewController.view.frame.size.height)];
    }
    else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        //  The x coordinate is half the difference between the device's width and the image's width. This centers the image horizontally.
        [_pageViewController.scrollView setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.height - _pageViewController.imageView.image.size.width) / 2, 0, _pageViewController.imageView.image.size.width, [UIScreen mainScreen].bounds.size.width - 44 - 20 - 44)];
    }
    
    //  Setup the page indicator
    [_pageViewController setupPageIndicator];

}

@end
