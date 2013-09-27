//
//  SGBookViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/12/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGBookViewController.h"
#import "SGBookListViewController.h"
#import "UIImage+Rotate.h"

@interface SGBookViewController ()

@property (nonatomic, weak) SGBookListViewController *bookListVC;

@property (nonatomic, assign) int currentPageIndex;

@property (nonatomic, weak) IBOutlet UIScrollView *pageScrollView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *previous;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *next;

@end

@implementation SGBookViewController

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
    
    [self.navigationItem setTitle:_book.title];
    
    [_previous setEnabled:NO];
    [_next setEnabled:NO];
    
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController.parentViewController;
    _bookListVC = (SGBookListViewController *)[[[[splitVC viewControllers] objectAtIndex:0] viewControllers] lastObject];
    
    if (_book.pages.count > 0) {
        _currentPageIndex = 0;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_book.pages[0]];
        [_pageScrollView addSubview:imageView];
        [_pageScrollView setContentSize:imageView.frame.size];
        
        if (_book.pages.count > 1) {
            [_next setEnabled:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBook:(SGBook *)book
{
    _book = book;
    
    if (_book.pages.count > 0) {
        _currentPageIndex = 0;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_book.pages[0]];
        [_pageScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_pageScrollView addSubview:imageView];
        [_pageScrollView setContentSize:imageView.frame.size];
    }
}

#pragma mark - UI Actions

- (IBAction)takePicture:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *cameraVC = [[UIImagePickerController alloc] init];
        [cameraVC setDelegate:self];
        [cameraVC setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:cameraVC animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Unavailable" message:@"There is no camera available on this device" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)previousPage:(id)sender
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_book.pages[--_currentPageIndex]];
    [_pageScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_pageScrollView addSubview:imageView];
    [_pageScrollView setContentSize:imageView.frame.size];
    
    if (_currentPageIndex > 0) {
        [_previous setEnabled:YES];
    } else {
        [_previous setEnabled:NO];
    }
    [_next setEnabled:YES];
}

- (IBAction)nextPage:(id)sender
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_book.pages[++_currentPageIndex]];
    [_pageScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_pageScrollView addSubview:imageView];
    [_pageScrollView setContentSize:imageView.frame.size];
    
    if (_currentPageIndex == _book.pages.count - 1) {
        [_next setEnabled:NO];
    } else {
        [_next setEnabled:YES];
    }
    [_previous setEnabled:YES];
}

#pragma mark - Camera delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image rotateToOrientation:UIImageOrientationDown];
    [_book addPage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
