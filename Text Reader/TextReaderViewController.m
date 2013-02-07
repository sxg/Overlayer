//
//  TextReaderViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/8/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "TextReaderViewController.h"
#import "UIImage+LineDrawer.h"
#import "BookListViewController.h"
#import <dispatch/dispatch.h>
#import <QuartzCore/QuartzCore.h>

@interface TextReaderViewController ()

@end

@implementation TextReaderViewController

@synthesize imagePicker;
@synthesize backgroundImage;
@synthesize backgroundImageView;
@synthesize backgroundImageScrollView;
@synthesize popOver;
@synthesize height;
@synthesize width;
@synthesize bytesPerPixel;
@synthesize bytesPerRow;
@synthesize bitsPerComponent;
@synthesize lineThickness;
@synthesize drawingView;
@synthesize imageAndPathView;
@synthesize loadingView;
@synthesize loadingHUD;
@synthesize loadingLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    backgroundImage = [UIImage imageNamed:nil];
    [self setWidth:0];
    [self setHeight:0];
    bytesPerPixel = 4;
    bitsPerComponent = 8;
    bytesPerRow = bytesPerPixel * width;
    lineThickness = 1;
    
    _cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(callCamera)];
    _drawLinesButton = [[UIBarButtonItem alloc] initWithTitle:@"Draw Lines" style:UIBarButtonItemStyleDone target:self action:@selector(drawLines)];
    self.navigationItem.rightBarButtonItem = _cameraButton;
    
    _backgroundQueue = dispatch_queue_create("backgroundQueue", NULL);
}

- (void)viewDidAppear:(BOOL)animated
{
    if (backgroundImage == nil)
    {
        [self callCamera];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callCamera
{
    imagePicker = [[UIImagePickerController alloc] init];
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
            popOver = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popOver setPopoverContentSize:CGSizeMake(500, 200)];
            [popOver presentPopoverFromRect:CGRectMake(0, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [popOver setDelegate:self];
        }
    }
    
    self.navigationItem.rightBarButtonItem = _drawLinesButton;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    backgroundImage = nil;
    [backgroundImageView removeFromSuperview];
    [backgroundImageScrollView removeFromSuperview];
    
    //get the image, save it, resize it, and set the relevant image data...
    backgroundImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    backgroundImage = [backgroundImage imageScaledToSize:CGSizeMake(768, 1024)];
    [self setWidth:backgroundImage.size.width];
    [self setHeight:backgroundImage.size.height];
    bytesPerRow = bytesPerPixel * width;
    drawingView = [[DrawingView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    imageAndPathView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    //add the image to the view...
    backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    backgroundImageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [backgroundImageScrollView setDelegate:self];
    [backgroundImageScrollView addSubview:backgroundImageView];
    [backgroundImageScrollView setContentSize:CGSizeMake(backgroundImageView.image.size.width, backgroundImageView.image.size.height)];
    [backgroundImageScrollView setMinimumZoomScale:1.0];
    [backgroundImageScrollView setMaximumZoomScale:3.0];
    
    [imageAndPathView addSubview:backgroundImageView];
    [imageAndPathView addSubview:drawingView];
    [backgroundImageScrollView addSubview:imageAndPathView];
    [imageAndPathView sendSubviewToBack:backgroundImageView];
    [self.view addSubview:backgroundImageScrollView];
    
    [self save];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //reverse self.view.frame.size.height and self.view.frame.size.width since the rotation hasn't happened yet
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if (backgroundImage.size.width >= 1024)
        {
            [backgroundImageScrollView setFrame:CGRectMake( 0, 44, 1024, 768 - 20 - 49 - 44)];
        }
        else
        {
            [backgroundImageScrollView setFrame:CGRectMake( (1024 - backgroundImage.size.width) / 2, 44, backgroundImage.size.width, 768 - 20 - 49 - 44)];
        }
    }
    else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [backgroundImageScrollView setFrame:CGRectMake(0, 44, 768, 1024 - 20 - 49 - 44)];
    }
    else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [backgroundImageScrollView setFrame:CGRectMake(0, 44, 480, 320 - 20 - 49 - 44)];
    }
    else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [backgroundImageScrollView setFrame:CGRectMake(0, 44, 320, 480 - 20 - 49 - 44)];
    }
}

/*- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}*/

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [backgroundImageView superview];
}

- (void)drawLines
{
    if (backgroundImage != nil)
    {
        loadingHUD = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 170)];
        loadingHUD.center = self.view.center;
        loadingHUD.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        loadingHUD.clipsToBounds = YES;
        loadingHUD.layer.cornerRadius = 10.0;
        loadingHUD.userInteractionEnabled = NO;
        
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingView.frame = CGRectMake(0, 0, loadingHUD.bounds.size.width, loadingHUD.bounds.size.height);
        [loadingHUD addSubview:loadingView];
        [loadingView startAnimating];
        
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 130, 22)];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18 ];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.text = @"Drawing Lines";
        [loadingHUD addSubview:loadingLabel];
        
        [self.view addSubview:loadingHUD];
        
        dispatch_async(_backgroundQueue, ^{
            [_drawLinesButton setEnabled:NO];
            drawingView = [backgroundImage identifyCharactersWithlineThickness:lineThickness onView:drawingView bytesPerPixel:bytesPerPixel bitsPerComponent:bitsPerComponent];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [drawingView setNeedsDisplay];
                [self saveWithLines];
                [loadingView stopAnimating];
                [loadingHUD removeFromSuperview];
                self.navigationItem.rightBarButtonItem = _cameraButton;
                [_drawLinesButton setEnabled:YES];
            });
        });
    }
}

- (void)save
{
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_savePath error:nil];
    _backgroundImageName = [NSString stringWithFormat:@"%i.png", ([fileList count] + 1)];
    NSString *imagePath = [_savePath stringByAppendingPathComponent:_backgroundImageName];
    
    [UIImagePNGRepresentation(backgroundImage) writeToFile:imagePath atomically:YES];
}

- (void)saveWithLines
{
    NSString *imagePath = [_savePath stringByAppendingPathComponent:_backgroundImageName];
    
    UIGraphicsBeginImageContext(imageAndPathView.bounds.size);
    [imageAndPathView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
}

@end
