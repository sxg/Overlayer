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
#import "UIImage+Transform.h"

@interface SGDocumentsListController ()

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _documentTitle = @"INIT";
    
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController.parentViewController;
    _documentVC = (SGDocumentController *)[[[[splitVC viewControllers] lastObject] viewControllers] lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SGAddDocumentController delegate

- (void)addDocumentController:(SGAddDocumentController *)addDocumentVC didAddDocumentWithTitle:(NSString *)title
{
    //  TO-DO: make sure the title isn't already taken by another document
    _documentTitle = title;
    [self takePicture:nil];
}

#pragma mark - UI actions

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
    image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
    
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
    
    return cell;
}

#pragma mark - Segue control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addDocument"]) {
        SGAddDocumentController *addDocumentVC = (SGAddDocumentController *)[[segue.destinationViewController viewControllers] lastObject];
        [addDocumentVC setDelegate:self];
    }
}

@end
