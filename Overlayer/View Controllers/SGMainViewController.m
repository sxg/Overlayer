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


@interface SGMainViewController ()

@property (readwrite, weak, nonatomic) IBOutlet UIWebView *webView;

@property (readwrite, weak, nonatomic) IBOutlet UIView *sidePaneView;
@property (readwrite, weak, nonatomic) IBOutlet UIButton *toggleSidePaneViewButton;
@property (readwrite, assign, getter = isDisplayingSidePane) BOOL displayingSidePane;

@property (readwrite, strong, nonatomic) SGDocumentTitlePromptView *documentTitlePromptView;

@property (readwrite, strong, nonatomic) MBProgressHUD *hud;

@property (readwrite, strong, nonatomic) UIImage *lastImage;

@property (readwrite, strong, nonatomic) SGDocument *currentDocument;
@property (readwrite, strong, nonatomic) SGDocumentManager *manager;

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

	//  Set the default SGDocument if possible
//	if ([SGDocumentManager documentsAtURL:<#(NSURL *)#>].count != 0) {
//		SGDocument *firstDocument = [[SGDocumentManager sharedManager] documents][0];
//		self.currentDocument = firstDocument;
//		self.imageView.image = firstDocument.documentImage;
//		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
//		[self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
//	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)createDocumentWithImages:(NSArray *)images
{
    __block SGMainViewController *blockSelf = self;
    [SGTextRecognizer recognizeTextOnImages:images completion:^(NSData *pdfWithRecognizedText, NSArray *recognizedText, NSArray *recognizedRects) {
        SGDocument *document = [[SGDocument alloc] initWithURL:blockSelf.manager.currentURL pdfData:pdfWithRecognizedText title:@"Import Test"];
        [blockSelf.manager saveDocument:document];
    }];
//	self.imageView.image = image;
//	self.lastImage = self.imageView.image;
//
//	//  Show the document title prompt
//	self.documentTitlePromptView = [[NSBundle mainBundle] loadNibNamed:@"SGDocumentTitlePromptView" owner:nil options:nil][0];
//	[self.documentTitlePromptView setFrame:CGRectMake(362.0f, 127.0f, 300.0f, 130.0f)];
//	self.documentTitlePromptView.titleTextField.delegate = self;
//	[self.documentTitlePromptView.titleTextField becomeFirstResponder];
//	[self.view addSubview:self.documentTitlePromptView];
}

#pragma mark - UI Actions

- (IBAction)didTapToggleSidePaneButton:(UIButton *)sender
{
	//  Setup
	CGFloat animationDuration = 0.4;
    CGRect newFrame;
	if (self.isDisplayingSidePane) {
        newFrame = CGRectMake(-1.0f * self.sidePaneView.frame.size.width + 56.0f, self.sidePaneView.frame.origin.y, self.sidePaneView.frame.size.width, self.sidePaneView.frame.size.height);
	} else {
        newFrame = CGRectMake(0.0f, self.sidePaneView.frame.origin.y, self.sidePaneView.frame.size.width, self.sidePaneView.frame.size.height);
	}

	//  Animate
	__block SGMainViewController *blockSelf = self;
	[UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [blockSelf.view layoutIfNeeded];
        //  Mirror the toggle side pane button
        CGFloat scale = blockSelf.displayingSidePane ? -1.0f : 1.0f;
        blockSelf.toggleSidePaneViewButton.transform = CGAffineTransformMakeScale(scale, 1.0f);
        [blockSelf.sidePaneView setFrame:newFrame];
	 } completion:^(BOOL finished) {
         blockSelf.displayingSidePane = !blockSelf.isDisplayingSidePane;
	 }];
}

- (IBAction)didTapCameraButton:(id)sender
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentViewController:picker animated:YES completion:nil];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"This device doesn't have a camera available to use." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
	}
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
    __block SGMainViewController *blockSelf = self;
    [SGTextRecognizer recognizeTextOnImages:@[image] completion:^(NSData *pdfWithRecognizedText, NSArray *recognizedText, NSArray *recognizedRects) {
        SGDocument *document = [[SGDocument alloc] initWithURL:blockSelf.manager.currentURL pdfData:pdfWithRecognizedText title:@"Test"];
        [blockSelf.manager saveDocument:document];
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (self.documentTitlePromptView.titleTextField == textField) {
		[textField endEditing:YES];
		[self.documentTitlePromptView removeFromSuperview];

		//  When the document title prompt view's text field returns, create a new document
//        __block SGMainViewController *blockSelf = self;
//        [SGTextRecognizer recognizeTextOnImage:self.lastImage completion:^(UIImage *imageWithLines, NSString *recognizedText, NSDictionary *recognizedRects) {
//            
//            SGDocument *document = [[SGDocument alloc] initWithImages:@[blockSelf.lastImage] title:textField.text];
//            [SGDocumentManager saveDocument:document atURL:<#(NSURL *)#>]
//            
//            //  Insert the new document into the table and select it with the delegate method (selectRowAtIndexPath:animated:scrollPosition: doesn't inform the delegate for some reason)
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([[SGDocumentManager sharedManager] documents].count - 1) inSection:0];
//            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
//            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
//        }];
	}

	return YES;
}

@end
