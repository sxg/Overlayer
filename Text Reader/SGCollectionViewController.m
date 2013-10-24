//
//  SGCollectionViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/12/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGCollectionViewController.h"
#import "SGCollectionListViewController.h"
#import "UIImage+Transform.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SGDrawingView.h"
#import "SGLineDrawing.h"

@interface SGCollectionViewController ()

@property (nonatomic, weak) SGCollectionListViewController *collectionListVC;

@property (nonatomic, assign) int currentDocumentIndex;

@property (nonatomic, weak) IBOutlet UIScrollView *documentscrollView;
@property (nonatomic, readwrite, strong) UIImageView *documentImageView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *previous;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *next;

@end

@implementation SGCollectionViewController

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
    
    [self.navigationItem setTitle:_collection.title];
    
    [_previous setEnabled:NO];
    [_next setEnabled:NO];
    
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController.parentViewController;
    _collectionListVC = (SGCollectionListViewController *)[[[[splitVC viewControllers] objectAtIndex:0] viewControllers] lastObject];
    
    if (_collection.documents.count > 0) {
        _currentDocumentIndex = 0;
        _documentImageView = [[UIImageView alloc] initWithImage:_collection.documents[0]];
        [_documentscrollView addSubview:_documentImageView];
        [_documentscrollView setContentSize:_documentImageView.frame.size];
        
        if (_collection.documents.count > 1) {
            [_next setEnabled:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCollection:(SGCollection *)collection
{
    _collection = collection;
    
    if (_collection.documents.count > 0) {
        _currentDocumentIndex = 0;
        _documentImageView = [[UIImageView alloc] initWithImage:_collection.documents[0]];
        [_documentscrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_documentscrollView addSubview:_documentImageView];
        [_documentscrollView setContentSize:_documentImageView.frame.size];
    }
}

#pragma mark - UI Actions

- (IBAction)drawLines:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud setLabelFont:[UIFont fontWithName:@"Amoon1" size:16.0f]];
    [hud setLabelText:@"Drawing Lines"];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("backgroundQueue", NULL);
    dispatch_async(backgroundQueue, ^{
        
        [_collection drawLines];
        
        //  Make UI changes and save the image with the strikethroughs on the main thread after processing is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [self setCollection:_collection];
        });
    });
}

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

- (IBAction)previousDocument:(id)sender
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_collection.documents[--_currentDocumentIndex]];
    [_documentscrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_documentscrollView addSubview:imageView];
    [_documentscrollView setContentSize:imageView.frame.size];
    
    if (_currentDocumentIndex > 0) {
        [_previous setEnabled:YES];
    } else {
        [_previous setEnabled:NO];
    }
    [_next setEnabled:YES];
}

- (IBAction)nextDocument:(id)sender
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_collection.documents[++_currentDocumentIndex]];
    [_documentscrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_documentscrollView addSubview:imageView];
    [_documentscrollView setContentSize:imageView.frame.size];
    
    if (_currentDocumentIndex == _collection.documents.count - 1) {
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
    image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
    [_collection addDocumentImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
