//
//  SGCollectionController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/12/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGCollectionController.h"
#import "SGCollectionsListController.h"
#import "UIImage+Transform.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SGDrawingView.h"
#import "SGLineDrawing.h"

@interface SGCollectionController ()

@property (nonatomic, weak) SGCollectionsListController *collectionListVC;

@end

@implementation SGCollectionController

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
    
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController.parentViewController;
    _collectionListVC = (SGCollectionsListController *)[[[[splitVC viewControllers] objectAtIndex:0] viewControllers] lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCollection:(SGCollection *)collection
{
    _collection = collection;
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

@end
