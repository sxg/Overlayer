//
//  SGDocumentsListController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/23/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGDocumentsListController.h"
#import "SGAddDocumentController.h"
#import "SGDocumentController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIImage+Transform.h"
#import "SGSettingsController.h"

@interface SGDocumentsListController ()

@property (nonatomic, readwrite, strong) UIActionSheet *actionSheet;

@property (nonatomic, weak) SGDocumentController *documentVC;
@property (nonatomic, readwrite, copy) NSString *documentTitle;

@end

@implementation SGDocumentsListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _documentTitle = @"INIT";
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Add Document", @"Draw Lines for Collection", @"View PDF", nil];
    
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController.parentViewController;
    _documentVC = (SGDocumentController *)[[[[splitVC viewControllers] lastObject] viewControllers] lastObject];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([_actionSheet isVisible]) {
        [_actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI actions

- (IBAction)actionButtonClicked:(id)sender
{
    UIBarButtonItem *actionButton = (UIBarButtonItem *)sender;
    [_actionSheet showFromBarButtonItem:actionButton animated:YES];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"addDocument" sender:nil];
    } else if (buttonIndex == 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_documentVC.view animated:YES];
        [hud setMode:MBProgressHUDModeIndeterminate];
        [hud setLabelText:@"Drawing Lines"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
            
            NSNumber *lineWidth = [[NSUserDefaults standardUserDefaults] objectForKey:LINE_WIDTH_KEY];
            [_collection drawLinesWithLineWidth:[lineWidth floatValue]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:_documentVC.view animated:YES];
                NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
                SGDocument *document = _collection.documents[selectedIndexPath.row];
                [_documentVC setDocument:document];
            });
        });
    } else if (buttonIndex == 2) {
        
        if (![_collection hasPDF]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_documentVC.view animated:YES];
            [hud setMode:MBProgressHUDModeIndeterminate];
            [hud setLabelText:@"Creating PDF"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
                
                [_collection createPDF];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:_documentVC.view animated:YES];
                    [self openPDFInQuickLook];
                });
            });
        } else {
            [self openPDFInQuickLook];
        }
    }
}

#pragma mark - SGAddDocumentController delegate

- (void)addDocumentController:(SGAddDocumentController *)addDocumentVC didAddDocumentWithTitle:(NSString *)title
{
    //  TO-DO: make sure the title isn't already taken by another document
    _documentTitle = title;
    
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
    CGFloat aspectRatio = image.size.width/image.size.height;
    CGFloat newWidth = 768.f;
    CGFloat newHeight = newWidth/aspectRatio;
    image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(newWidth, newHeight)];
    
    SGDocument *document = [[SGDocument alloc] initWithImage:image title:_documentTitle];
    [_collection addDocument:document];
    
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _collection.documents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"documentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [_collection.documents[indexPath.row] title];
    cell.textLabel.font = [UIFont fontWithName:@"Amoon1" size:16];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete) {
        
        SGDocument *documentToDelete = _collection.documents[indexPath.row];
        [_collection deleteDocumentWithTitle:documentToDelete.title];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _documentVC.document = _collection.documents[indexPath.row];
    //[_documentVC setDocument:_collection.documents[indexPath.row]];
}

#pragma mark - Quick look data source

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:[_collection pdfPath]];
}

#pragma mark - Segue control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addDocument"]) {
        SGAddDocumentController *addDocumentVC = (SGAddDocumentController *)[[segue.destinationViewController viewControllers] lastObject];
        [addDocumentVC setDelegate:self];
    }
}

#pragma mark - Helpers

- (void)openPDFInQuickLook
{
    QLPreviewController *qlVC = [[QLPreviewController alloc] init];
    [qlVC setDataSource:self];
    [self presentViewController:qlVC animated:YES completion:nil];
}

@end
