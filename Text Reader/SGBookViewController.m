//
//  SGBookViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/12/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGBookViewController.h"
#import "SGBookListViewController.h"

@interface SGBookViewController ()

@property (nonatomic, weak) SGBookListViewController *bookListVC;

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
    
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController.parentViewController;
    _bookListVC = (SGBookListViewController *)[[[[splitVC viewControllers] objectAtIndex:0] viewControllers] lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Camera delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_book addPage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
