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
#import "ClipView.h"
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
@property IBOutlet ClipView *clipView;

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
    [_clipView setClipsToBounds:YES];
    [_clipView setScrollingPages:_scrollingPages];
    
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

#pragma mark - Dropbox delegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"File upload failed with error - %@", error);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    if (metadata.isDirectory)
    {
        _folderMetadata = metadata;
    }
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
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
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
}

- (IBAction)openBook:(id)sender
{
    if ([_book.pages count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Can't Open %@", _book.title]
                                                        message:[NSString stringWithFormat:@"%@ has no pages to open.", _book.title]
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        //  Close this modal VC
        [self dismissViewControllerAnimated:NO completion:nil];
        
        [_bookListViewController performSegueWithIdentifier:@"ViewPage" sender:self];
    }
    
}

- (IBAction)addPage:(id)sender
{
    //  Close this modal VC
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [_bookListViewController performSegueWithIdentifier:@"CameraFromDetail" sender:self];
}

- (IBAction)imageViewTapped:(id)sender
{
    int x = ((UIImageView*)((UITapGestureRecognizer*)sender).view).frame.origin.x;
    _indexOfPageToOpen = x / (275 + 20);

    [self dismissViewControllerAnimated:NO completion:nil];
    [_bookListViewController performSegueWithIdentifier:@"ViewPage" sender:self];
}

@end
