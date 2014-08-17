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


@interface SGMainViewController ()

@property (readwrite, weak, nonatomic) IBOutlet UIImageView *imageView;

@property (readwrite, weak, nonatomic) IBOutlet UITableView *tableView;

@property (readwrite, weak, nonatomic) IBOutlet UIView *sidePaneView;
@property (readwrite, weak, nonatomic) IBOutlet UIButton *toggleSidePaneViewButton;
@property (readwrite, weak, nonatomic) IBOutlet NSLayoutConstraint *sidePaneLeftEdgeConstraint;
@property (readwrite, assign) CGFloat sidePaneLeftEdge;
@property (readwrite, assign, getter = isDisplayingSidePane) BOOL displayingSidePane;

@property (readwrite, strong, nonatomic) SGDocumentTitlePromptView *documentTitlePromptView;

@property (readwrite, strong, nonatomic) MBProgressHUD *hud;

@property (readwrite, strong, nonatomic) UIImage *lastImage;

@property (readwrite, strong, nonatomic) SGDocument *currentDocument;

@end

@implementation SGMainViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	self.displayingSidePane = YES;

	//  Set the default SGDocument if possible
	if ([[SGDocumentManager sharedManager] documents].count != 0) {
		SGDocument *firstDocument = [[SGDocumentManager sharedManager] documents][0];
		self.currentDocument = firstDocument;
		self.imageView.image = firstDocument.documentImage;
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		[self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)createDocumentWithImage:(UIImage *)image
{
	self.imageView.image = image;
	self.lastImage = self.imageView.image;

	//  Show the document title prompt
	self.documentTitlePromptView = [[NSBundle mainBundle] loadNibNamed:@"SGDocumentTitlePromptView" owner:nil options:nil][0];
	[self.documentTitlePromptView setFrame:CGRectMake(362.0f, 127.0f, 300.0f, 130.0f)];
	self.documentTitlePromptView.titleTextField.delegate = self;
	[self.documentTitlePromptView.titleTextField becomeFirstResponder];
	[self.view addSubview:self.documentTitlePromptView];
}

#pragma mark - UI Actions

- (IBAction)didDragSidePane:(UIPanGestureRecognizer *)pan
{
	if (pan.state == UIGestureRecognizerStateBegan) {
		self.sidePaneLeftEdge = self.isDisplayingSidePane ? 0.0f : -1.0f * self.sidePaneView.frame.size.width + 56.0f;
	} else if (pan.state == UIGestureRecognizerStateChanged) {
		CGPoint translation = [pan translationInView:self.view];
		CGFloat updatedConstant = self.sidePaneLeftEdge + translation.x;
		updatedConstant = MAX(-1.0f * self.sidePaneView.frame.size.width + 56.0f, MIN(0.0f, updatedConstant));
		self.sidePaneLeftEdgeConstraint.constant = updatedConstant;
		//[self.view setNeedsUpdateConstraints];
		//[self.view layoutIfNeeded];
	}
}

- (IBAction)didTapToggleSidePaneButton:(UIButton *)sender
{
	//  Setup
	CGFloat animationDuration = 0.4;
	CGFloat endToggleSidePaneButtonScaleX;
	if (self.isDisplayingSidePane) {
		self.sidePaneLeftEdgeConstraint.constant = -1.0f * self.sidePaneView.frame.size.width + 56.0f;
		endToggleSidePaneButtonScaleX = -1.0f;
	} else {
		self.sidePaneLeftEdgeConstraint.constant = 0.0f;
		endToggleSidePaneButtonScaleX = 1.0f;
	}

	[self.view setNeedsUpdateConstraints];

	//  Animate
	__block SGMainViewController *blockSelf = self;
	[UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
	         [blockSelf.view layoutIfNeeded];
	         //  Mirror the toggle side pane button
	         blockSelf.toggleSidePaneViewButton.transform = CGAffineTransformMakeScale(endToggleSidePaneButtonScaleX, 1.0f);
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
	return self.imageView;
}

#pragma mark - QLPreviewController Data Source

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	return [NSURL fileURLWithPath:self.currentDocument.documentPDFPath];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissViewControllerAnimated:YES completion:nil];
	UIImage *image = [SGUtility imageWithImage:info[UIImagePickerControllerOriginalImage] scaledToWidth:968.0f];
	[self createDocumentWithImage:image];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (self.documentTitlePromptView.titleTextField == textField) {
		[textField endEditing:YES];
		[self.documentTitlePromptView removeFromSuperview];

		//  When the document title prompt view's text field returns, create a new document
		SGDocument *document = [SGDocument createDocumentWithImage:self.lastImage title:textField.text parentFolderName:nil];
		[document drawLinesCompletion:nil];

		//  Insert the new document into the table and select it with the delegate method (selectRowAtIndexPath:animated:scrollPosition: doesn't inform the delegate for some reason)
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([[SGDocumentManager sharedManager] documents].count - 1) inSection:0];
		[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		[self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
	}

	return YES;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.currentDocument = [[SGDocumentManager sharedManager] documents][indexPath.row];
	self.imageView.image = self.currentDocument.documentImage;

	//  If the currently selected document is in the process of drawing lines
	if (self.currentDocument.isDrawingLines) {
		//  Show a progress HUD
		[self.hud hide:YES];
		[self.hud removeFromSuperview];
		self.hud = nil;
		self.hud = [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
		self.hud.mode = MBProgressHUDModeIndeterminate;
		self.hud.labelText = @"Drawing Lines";
        self.hud.labelFont = [UIFont fontWithName:kSGFontAmoon size:18.0f];

		//  Register KVO for the progress
		[self.currentDocument addObserver:self forKeyPath:@"drawingLines" options:NSKeyValueObservingOptionNew context:nil];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.hud hide:YES];
	//  Need to use a try/catch block since removeObserver throws an exception if self isn't an observer
	@try {
		[self.currentDocument removeObserver:self forKeyPath:@"drawingLines"];
	} @catch (NSException *exception) {}
	self.currentDocument = nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"drawingLines"]) {
		//  If the currently selected document is no longer drawing lines
		if (!self.currentDocument.isDrawingLines) {
			//  Unregister KVO, hide the HUD, and show the document image with lines on it
			[self.currentDocument removeObserver:self forKeyPath:@"drawingLines"];
			[self.hud hide:YES];
			self.imageView.image = self.currentDocument.documentImage;
		}
	}
}

@end
