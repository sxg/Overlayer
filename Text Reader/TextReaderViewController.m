//
//  TextReaderViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/8/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

/*
    This is a UIViewController subclass, and it is responsible for allowing the user to take a picture, view it, and optionally draw
    strikethroughs on the picture. The picture taken is automatically saved to the appropriate directory, and if the user chooses to
    draw strikethroughs on the picture, then the original image is overwritten with the new image with strikethroughs.

    _backgroundQueue is the background thread on which the image processing occurs since it is very time intensive
    _backgroundImage is the image that is displayed, which is the image that was just taken by the camera
    _backgroundImageView contains the background image
    _backgroundImageScrollView contains the background imageview, which allows the background image to be zoomed in on
    _height is the height of the background image
    _width is the width of the background image
    _bytesPerPixel is the number of bytes needed per pixel on the background image
    _bytesPerRow is the number of bytes needed to store one horizontal row of pixels on the background image
    _bitsPerComponent is the number of bits needed per pixel component (RGBA)
    _lineThickness is the user's desired strikethrough thickness
    _drawingView has the strikethroughs drawn on it by a UIBezierPath
    _imageAndPathView is a container view that contains the background image behind the drawing view. This view is used to consolidate
                      the strikethroughs and the original image when saving the two in one image.
    _cameraButton is the navbar button that calls the camera
    _drawLinesButton is the navbar button that initiates the procesing of the image to draw the strikethroughs
    _savePath is where the images the user takes should be saved
    _backgroundImageName is the file name that the background image should be given when saved to _savePath
    _delegate implements the TextReaderViewController protocol
 */

#import "TextReaderViewController.h"
#import "UIImage+LineDrawer.h"
#import "BookListViewController.h"
#import <dispatch/dispatch.h>
#import <QuartzCore/QuartzCore.h>

@interface TextReaderViewController ()

@property (readwrite)dispatch_queue_t backgroundQueue;
@property (readwrite)UIImage *backgroundImage;
@property (readwrite)UIImageView *backgroundImageView;
@property (readwrite)UIScrollView *backgroundImageScrollView;
@property (readwrite)int height;
@property (readwrite)int width;
@property (readwrite)NSUInteger bytesPerPixel;
@property (readwrite)NSUInteger bytesPerRow;
@property (readwrite)NSUInteger bitsPerComponent;
@property (readwrite)float lineThickness;
@property (readwrite)DrawingView *drawingView;
@property (readwrite)UIView *imageAndPathView;
@property (readwrite)UIBarButtonItem *cameraButton;
@property (readwrite)UIBarButtonItem *drawLinesButton;

@end

@implementation TextReaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //  Setup easy ivars
    _backgroundImage = [UIImage imageNamed:nil];
    [self setWidth:0];
    [self setHeight:0];
    _bytesPerPixel = 4;
    _bitsPerComponent = 8;
    _bytesPerRow = _bytesPerPixel * _width;
    
    //  Setup ivars by looking up user settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lineThicknessWrapper = [defaults objectForKey:@"strikethroughWidth"];
    if (lineThicknessWrapper == nil)
    {
        _lineThickness = 1.0;
        //  Save 1.0 as the line thickness in user defaults
        [defaults setObject:[[NSNumber alloc] initWithFloat:1.0] forKey:@"strikethroughWidth"];
    }
    else
    {
        _lineThickness = [lineThicknessWrapper floatValue];
    }
    
    //  Setup interface buttons. The "Draw Lines" button should only be enabled if the background image exists and is unprocessed.
    _cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(callCamera)];
    _drawLinesButton = [[UIBarButtonItem alloc] initWithTitle:@"Draw Lines" style:UIBarButtonItemStyleDone target:self action:@selector(drawLines)];
    [_drawLinesButton setEnabled:NO];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_cameraButton, _drawLinesButton, nil];
    
    //  Setup the background queue
    _backgroundQueue = dispatch_queue_create("backgroundQueue", NULL);
}

- (void)viewDidAppear:(BOOL)animated
{
    //  Every time this view comes up, look for a background image, and if there isn't one, then call the camera to make one
    if (_backgroundImage == nil)
    {
        [self callCamera];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  Rotation handling. In landscape, the scrollview should be centered horizontally, and in portrait, the image should take up the entire space
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //reverse self.view.frame.size.height and self.view.frame.size.width since the rotation hasn't happened yet
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [_backgroundImageScrollView setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.height - _backgroundImageScrollView.frame.size.width) / 2, 0, _backgroundImageScrollView.frame.size.width, [UIScreen mainScreen].bounds.size.width - 44 - 20)];
    }
    else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        [_backgroundImageScrollView setFrame:CGRectMake(0, 0, _backgroundImageScrollView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 44 - 20)];
    }
}

#pragma mark - Interface button actions

//  Action for the "Draw Lines" button. The actual procesing and drawing of the lines occurs on a background thread since it is time intensive. A translucent black square with rounded corners and a UIActivitiyIndicator with the caption "Drawing Lines" appears while processing occurs.
- (void)drawLines
{
    //  Be sure there is an image to be processed
    if (_backgroundImage != nil)
    {
        //  Setup the translucent black square
        UIView *loadingHUD = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 170)];
        loadingHUD.center = self.view.center;
        loadingHUD.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        loadingHUD.clipsToBounds = YES;
        loadingHUD.layer.cornerRadius = 10.0;
        loadingHUD.userInteractionEnabled = NO;
        
        //  Setup the UIActivityIndicator
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingView.frame = CGRectMake(0, 0, loadingHUD.bounds.size.width, loadingHUD.bounds.size.height);
        [loadingHUD addSubview:loadingView];
        [loadingView startAnimating];
        
        //  Setup the caption
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 130, 22)];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.font = [UIFont fontWithName:@"Amoon1" size:18 ];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.text = @"Drawing Lines";
        [loadingHUD addSubview:loadingLabel];
        
        [self.view addSubview:loadingHUD];
        
        //  Do all the processing on a background thread and disable the "Draw Lines" button that activated this whole process while processing is occurring
        dispatch_async(_backgroundQueue, ^{
            [_drawLinesButton setEnabled:NO];
            
            //  All of the processing happens in this method. drawingView is a custom UIView that has the lines drawn on it.
            _drawingView = [_backgroundImage identifyCharactersWithlineThickness:_lineThickness onView:_drawingView bytesPerPixel:_bytesPerPixel bitsPerComponent:_bitsPerComponent];
            
            //  Make UI changes and save the image with the strikethroughs on the main thread after processing is finished
            dispatch_async(dispatch_get_main_queue(), ^{
                [_drawingView setNeedsDisplay];
                [self saveWithLines];
                [loadingView stopAnimating];
                [loadingHUD removeFromSuperview];
                self.navigationItem.rightBarButtonItem = _cameraButton;
            });
        });
    }
}

- (void)callCamera
{
    //  Setup the camera and present it, or if there is no camera, then present a popover with pictures from the saved photos album
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover setPopoverContentSize:CGSizeMake(500, 200)];
            [popover presentPopoverFromRect:CGRectMake(0, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [popover setDelegate:self];
        }
    }
    
    [_drawLinesButton setEnabled:YES];
}

#pragma mark - Helper methods

//  Save the original image to the appropriate directory
- (void)save
{
    dispatch_async(_backgroundQueue, ^{
        //  Get the appropriate directory and file name for the new image to be saved
        NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_savePath error:nil];
        for (int i = 0; i < [fileList count]; i++)
        {
            NSString *checkName = [NSString stringWithFormat:@"%i.png", (i + 1)];
            if (![fileList containsObject:checkName])
            {
                _backgroundImageName = checkName;
            }
        }
       // _backgroundImageName = [NSString stringWithFormat:@"%i.png", ([fileList count] + 1)];
        NSString *imagePath = [_savePath stringByAppendingPathComponent:_backgroundImageName];
        
        //  Save the image and inform the delegate that saving has completed
        [UIImagePNGRepresentation(_backgroundImage) writeToFile:imagePath atomically:YES];
        
        //  Dropbox rest client methods MUST be called from the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate finishedSavingImage:_backgroundImageName toPath:imagePath uploadToDropbox:NO];
        });
    });
}

//  Save the original image with the lines, and overwrite the original image
- (void)saveWithLines
{
    dispatch_async(_backgroundQueue, ^{
        //  Get the path to the original image
        NSString *imagePath = [_savePath stringByAppendingPathComponent:_backgroundImageName];
        
        //  Consolidate imageAndPathView's two subviews into a single image
        UIGraphicsBeginImageContext(_imageAndPathView.bounds.size);
        [_imageAndPathView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //  Save the image and inform the delegate that saving has completed
        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
        
        //  Dropbox rest client methods MUST be called from the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate finishedSavingImage:_backgroundImageName toPath:imagePath uploadToDropbox:YES];
        });
    });
}

#pragma mark - Camera delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //  If the user touches the "Cancel" button on the camera, then dismiss the camera and go back to the previous table view controller (either book list or page list)
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //  The user has taken a picture, now the view has to be reset to display the new picture
    _backgroundImage = nil;
    [_backgroundImageView removeFromSuperview];
    [_backgroundImageScrollView removeFromSuperview];
    
    //  Get the image, resize it, and set the relevant image ivars
    _backgroundImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    _backgroundImage = [_backgroundImage imageScaledToSize:CGSizeMake(768, 1024)];
    [self setWidth:_backgroundImage.size.width];
    [self setHeight:_backgroundImage.size.height];
    _bytesPerRow = _bytesPerPixel * _width;
    
    //  Reset the drawingView on which a UIBezierPath will draw lines and the imageAndPathView, which contains _backgroundImageView and drawingView
    _drawingView = [[DrawingView alloc] initWithFrame:CGRectMake(0, 0, _width, _height)];
    _imageAndPathView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _width, _height)];
    
    //  Add the image to the view
    _backgroundImageView = [[UIImageView alloc] initWithImage:_backgroundImage];
    
    //  Setup the scroll view
    _backgroundImageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_backgroundImageScrollView setDelegate:self];
    [_backgroundImageScrollView addSubview:_backgroundImageView];
    [_backgroundImageScrollView setContentSize:CGSizeMake(_backgroundImageView.image.size.width, _backgroundImageView.image.size.height)];
    [_backgroundImageScrollView setMinimumZoomScale:1.0];
    [_backgroundImageScrollView setMaximumZoomScale:3.0];
    
    //  imageAndPathView is a container view containing the _backgroundImageView (the original image) behind the drawingView, which contains the lines
    [_imageAndPathView addSubview:_backgroundImageView];
    [_imageAndPathView addSubview:_drawingView];
    [_backgroundImageScrollView addSubview:_imageAndPathView];
    [_imageAndPathView sendSubviewToBack:_backgroundImageView];
    [self.view addSubview:_backgroundImageScrollView];
    
    //  Save the original image to the appropriate folder
    [self save];
    
    //  Dismiss the camera but stay in this view controller so the user can see the picture taken
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Scroll view delegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [_backgroundImageView superview];
}

@end
