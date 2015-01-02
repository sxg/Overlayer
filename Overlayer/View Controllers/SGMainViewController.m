//
//  SGMainViewController.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/9/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGMainViewController.h"

//  Frameworks
#import <MBProgressHUD/MBProgressHUD.h>
#import <StandardPaths/StandardPaths.h>

//  App Delegate
#import "SGAppDelegate.h"

//  Models
#import "SGDocument.h"

//  Views
#import "SGDocumentTitlePromptView.h"

//  Utility
#import "SGUtility.h"
#import "SGTextRecognizer.h"
#import "SGDocumentManager.h"

//  Controllers
#import "SGTableViewController.h"


NSString *SGMainViewControllerDidTapNewDocumentButtonNotification = @"SGMainViewControllerDidTapNewDocumentButtonNotification";
NSString *SGMainViewControllerDidStartCreatingDocumentNotification = @"SGMainViewControllerDidStartCreatingDocumentNotification";
NSString *SGMainViewControllerDidFinishCreatingDocumentNotification = @"SGMainViewControllerDidFinishCreatingDocumentNotification";
NSString *SGMainViewControllerDidTapNewFolderButtonNotification = @"SGMainViewControllerDidTapNewFolderButtonNotification";
NSString *SGMainViewControllerDidFinishCreatingFolderNotification = @"SGMainViewControllerDidFinishCreatingFolderNotification";

@interface SGMainViewController ()

@property (readwrite, weak, nonatomic) IBOutlet UIWebView *webView;

@property (readwrite, weak, nonatomic) IBOutlet UIView *sidePaneView;
@property (readwrite, weak, nonatomic) IBOutlet UIButton *toggleSidePaneViewButton;
@property (readwrite, weak, nonatomic) IBOutlet NSLayoutConstraint *sidePaneLeadingConstraint;
@property (readwrite, assign, getter = isDisplayingSidePane) BOOL displayingSidePane;

@property (readwrite, strong, nonatomic) SGDocumentTitlePromptView *documentTitlePromptView;

@property (readwrite, strong, nonatomic) MBProgressHUD *hud;

@property (readwrite, strong, nonatomic) UIImage *lastImage;

@property (readwrite, strong, nonatomic) SGDocument *currentDocument;
@property (readwrite, strong, nonatomic) SGDocumentManager *manager;

@property (readwrite, strong, nonatomic) NSString *theNewDocumentName;
@property (readwrite, strong, nonatomic) NSURL *saveURL;
@property (readwrite, strong, nonatomic) NSArray *importedImages;

@end

@implementation SGMainViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	self.displayingSidePane = YES;
    self.manager = [[SGDocumentManager alloc] init];
    
    __block SGMainViewController *blockSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:SGTableViewControllerDidSelectDocumentNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        blockSelf.currentDocument = note.userInfo[SGDocumentKey];
        NSURLRequest *pdfURLRequest = [NSURLRequest requestWithURL:blockSelf.currentDocument.previewItemURL];
        [blockSelf.webView loadRequest:pdfURLRequest];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SGTableViewControllerDidNameNewDocumentNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        blockSelf.theNewDocumentName = note.userInfo[SGDocumentNameKey];
        blockSelf.saveURL = note.userInfo[SGURLKey];
        if (blockSelf.importedImages) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [blockSelf createDocumentWithImages:blockSelf.importedImages];
                });
            });
        } else {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = blockSelf;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [blockSelf presentViewController:picker animated:YES completion:nil];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SGTableViewControllerDidNameNewFolderNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [blockSelf.manager createFolder:note.userInfo[SGFolderNameKey] atURL:note.userInfo[SGURLKey]];
        [[NSNotificationCenter defaultCenter] postNotificationName:SGMainViewControllerDidFinishCreatingFolderNotification object:nil];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SGAppDelegateDidImportImagesNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        blockSelf.importedImages = note.userInfo[SGImportedImagesKey];
    }];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UI Actions

- (IBAction)didTapToggleSidePaneButton:(UIButton *)sender
{
	//  Setup
	CGFloat animationDuration = 0.4;
    CGFloat sidePaneLeadingSpace;
	if (self.isDisplayingSidePane) {
        sidePaneLeadingSpace = -194.0f;
	} else {
        sidePaneLeadingSpace = 0.0f;
	}

	//  Animate
	__block SGMainViewController *blockSelf = self;
	[UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //  Mirror the toggle side pane button
        CGFloat scale = blockSelf.displayingSidePane ? -1.0f : 1.0f;
        blockSelf.toggleSidePaneViewButton.transform = CGAffineTransformMakeScale(scale, 1.0f);
        blockSelf.sidePaneLeadingConstraint.constant = sidePaneLeadingSpace;
        [blockSelf.view layoutIfNeeded];
	 } completion:^(BOOL finished) {
         blockSelf.displayingSidePane = !blockSelf.isDisplayingSidePane;
	 }];
}

- (IBAction)didTapCameraButton:(id)sender
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SGMainViewControllerDidTapNewDocumentButtonNotification object:nil];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"This device doesn't have a camera available to use." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
	}
}

- (IBAction)didTapNewFolderButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SGMainViewControllerDidTapNewFolderButtonNotification object:nil];
}

- (IBAction)didTapPDFButton:(id)sender
{
	if (self.currentDocument) {
		QLPreviewController *quickLookVC = [[QLPreviewController alloc] init];
		quickLookVC.dataSource = self;
		[self presentViewController:quickLookVC animated:YES completion:nil];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Document Selected" message:@"Select a document by tapping on a row in the table to the left." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
	}
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.webView;
}

#pragma mark - QLPreviewController Data Source

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.currentDocument;
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [SGUtility imageWithImage:info[UIImagePickerControllerOriginalImage] scaledToWidth:968.0f];
    [self createDocumentWithImages:@[image]];
}

#pragma mark - Helpers

- (void)createDocumentWithImages:(NSArray *)images
{
   [[NSNotificationCenter defaultCenter] postNotificationName:SGMainViewControllerDidStartCreatingDocumentNotification object:nil];
    
    __block SGMainViewController *blockSelf = self;
    [SGTextRecognizer recognizeTextOnImages:images completion:^(NSData *pdfWithRecognizedText, NSArray *recognizedText, NSArray *recognizedRects) {
        SGDocument *document = [[SGDocument alloc] initWithURL:blockSelf.manager.currentURL pdfData:pdfWithRecognizedText title:blockSelf.theNewDocumentName];
        [blockSelf.manager saveDocument:document atURL:blockSelf.saveURL];
        blockSelf.saveURL = nil;
        blockSelf.importedImages = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:SGMainViewControllerDidFinishCreatingDocumentNotification object:nil];
    }];
}

@end
