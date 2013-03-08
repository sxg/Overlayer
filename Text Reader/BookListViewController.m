//
//  BookListViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/31/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

/*
    This is a UITableViewController subclass, and it is the initial view controller. BookListViewController (BLVC) contains only one section,
    and it lists all the "books" that have been created with the app. Books are simply folders within which are images of pages. The
    only public method is addBook:, which allows the user to create a new book through a popover. If the camera button is touched and
    a picture is taken, then a new book folder is automatically created, and the new picture goes into the new folder. Books are listed
    in alphabetic order. 
 
    _books is an array containing the string names of all the books and the data source for the table
    _documentsDirectory is the string path of the Documents directory of the app
    _pageListViewController is a reference to the view controller that will be called upon selecting a book from the table
    _popover is the popover that appears when the add button is touched to add a new book
 */

#import "PageListViewController.h"
#import "BookListViewController.h"
#import "TextReaderViewController.h"
#import "SettingsViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface BookListViewController ()

@property (nonatomic) NSMutableArray *books;
@property NSString *documentsDirectory;
@property PageListViewController *pageListViewController;
@property UIPopoverController *popover;

@end

@implementation BookListViewController

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
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //  Link Dropbox
    [self linkWithDropbox];
    
    //  Show the navigation controller's built-in toolbar
    [self.navigationController setToolbarHidden:NO];
    
    //  Need to setup images and imageNames
    _documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    _books = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_documentsDirectory error:nil] mutableCopy];
}

- (void)viewDidAppear:(BOOL)animated
{
    //  Look for new folders AKA books
    _books = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_documentsDirectory error:nil] mutableCopy];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public methods

// Allow the user to add a new book by interacting with a textfield within a popover
- (IBAction)addBook:(id)sender
{
    if (_popover == nil || ![_popover isPopoverVisible])
    {
        //  Get a default book name of the form "New Book %i" that doesn't already exist
        NSString* bookName = [self getDefaultBookName];
        
        //  Setup the view controller for the popover
        UIViewController *viewController = [[UIViewController alloc] init];
        [viewController setContentSizeForViewInPopover:CGSizeMake(260, 125)];
        [viewController.view setBackgroundColor:[UIColor whiteColor]];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(30, 60, 200, 35)];
        [textField setDelegate:self];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        [textField setBackgroundColor:[UIColor whiteColor]];
        [textField setFont:[UIFont fontWithName:@"Amoon1" size:17]];
        [textField setText:bookName];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, 200, 35)];
        [label setFont:[UIFont fontWithName:@"Amoon1" size:17]];
        [label setText:@"Enter the book name:"];
        
        [viewController.view addSubview:textField];
        [viewController.view addSubview:label];
        _popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
        
        //  Present the popover
        [_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - Helper methods

- (void)linkWithDropbox
{
    //  Check to see if the user's Dropbox account is linked to Text Reader
    if (![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
        
        //  Initial sync
        [self syncWithDropbox];
    }
}

- (DBRestClient*)restClient
{
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    
    return _restClient;
}

- (void)syncWithDropbox
{
    //  Iterate through each file and folder in the local Documents directory and upload to Dropbox
    NSArray *folders = [[[NSFileManager defaultManager] contentsAtPath:_documentsDirectory] copy];
    for (NSString *folder in folders)
    {
        NSString *currentFolderPath = [_documentsDirectory stringByAppendingPathComponent:folder];
        NSArray *files = [[[NSFileManager defaultManager] contentsAtPath:currentFolderPath] copy];
        
        for (NSString *file in files)
        {
            NSString *currentFilePath = [currentFolderPath stringByAppendingPathComponent:file];
            NSString *destPath = [[@"/" stringByAppendingPathComponent:folder] stringByAppendingPathComponent:file];
            
            //  Upload the file
            [[self restClient] uploadFile:file toPath:destPath withParentRev:nil fromPath:currentFilePath];
        }
    }
}

//  Search the Documents directory for a book called "New Book". If it exists, then look for "New Book 2" etc.
- (NSString*)getDefaultBookName
{
    //  There is a minor bug in this code - if "New Book", "New Book 2", and "New Book 4" are the only books that exist, then the next book that is added will be "New Book 3" instead of "New Book 5"
    //  Another minor bug: the numbers within the books will be sorted alphabetically and not numerically, so "New Book 10" will appear before "New Book 2"

    bool alreadyExists;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:_documentsDirectory error:nil];
    int i = 1;
    NSString *newBookName;
    do {
        alreadyExists = NO;
        newBookName = @"New Book";
        
        //  Don't append a number to the end of the first "New Book", but do it to all subsequent "New Book"s
        if (i > 1)
        {
            NSString *num = [[[NSNumber alloc] initWithInt:i] stringValue];
            newBookName = [newBookName stringByAppendingString:@" "];
            newBookName = [newBookName stringByAppendingString:num];
        }
        
        //  Look for a book AKA folder named newBookName in the Documents folder
        for (NSString *fileName in files)
        {
            if ([fileName isEqualToString:newBookName])
            {
                alreadyExists = YES;
            }
        }
        i++;
        
        //  Keep going until you find a book name that has not already been taken
    } while (alreadyExists);

    return newBookName;
}

#pragma mark - Dropbox delegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"File upload failed with error - %@", error);
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *bookName = textField.text;
    
    //  Add the new book only if the name does not already exist
    if (![_books containsObject:bookName])
    {
        //  Create a new folder by the name the user specifies in the textfield, and add it to the data source _books
        NSString *path = [_documentsDirectory stringByAppendingPathComponent:bookName];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
        [_books addObject:bookName];
        
        //  Create the folder on Dropbox
        [[self restClient] createFolder:[@"/" stringByAppendingPathComponent:bookName]];
        
        //  Add the new book to the table
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_books count] - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    //  Remove the popover and the keyboard
    [_popover dismissPopoverAnimated:YES];
    [textField resignFirstResponder];
    
    return YES;
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
    return [_books count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Book";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    //  Give the book's cell the same name as the book's folder
    NSString *name = [_books objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont fontWithName:@"Amoon1" size:20]];
    [cell.textLabel setText:name];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *bookToDelete = [_books objectAtIndex:indexPath.row];
        NSString *pathToBook = [_documentsDirectory stringByAppendingPathComponent:bookToDelete];
        [[NSFileManager defaultManager] removeItemAtPath:pathToBook error:nil];
        [_books removeObjectAtIndex:indexPath.row];
        
        //  Remove the row from the table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

//  Go to the PageListViewController if the user selected a book from the table (called after prepareForSegue:)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    //  Get the name of the selected book, tell PLVC the book name, tell PLVC the path to that book, and set PLVC up with all the names of pages contained in that book folder
    NSString *selectedBook = [_books objectAtIndex:indexPath.row];
    [_pageListViewController setBook:selectedBook];
    NSFileManager *fm = [NSFileManager defaultManager];
    _pageListViewController.savePath = [_pageListViewController.documentsDirectory stringByAppendingPathComponent:_pageListViewController.book];
    _pageListViewController.pages = [[fm contentsOfDirectoryAtPath:_pageListViewController.savePath error:nil] mutableCopy];
    
    //  Sort names of pages numerically so that 10.png does not come before 2.png
    NSSortDescriptor *numericalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedStandardCompare:)];
    [_pageListViewController.pages sortUsingDescriptors:[NSArray arrayWithObject:numericalSort]];
    
    //  Set PLVC's navbar's title to the name of the book
    _pageListViewController.navigationItem.title = _pageListViewController.book;
}

#pragma mark - Segue control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  Go to the PageListViewController if the user selected a book from the table
    if ([segue.identifier isEqualToString:@"ViewBook"]) {
        //  Get the PLVC that's about to come into view, and tell it where the app's Documents directory is
        _pageListViewController = segue.destinationViewController;
        [_pageListViewController setDocumentsDirectory:_documentsDirectory];
    }
    //  Go to the TextReaderViewController if the user wants to take a picture from here (BLVC)
    else if ([segue.identifier isEqualToString:@"CameraFromBooks"])
    {
        //  Since a book name has not been specified but the user wants to take a picture, get a default book name, make a folder with that name, create a path to that folder, and give TRVC that path so it knows where to save the picture
        NSString *savePath = [_documentsDirectory stringByAppendingPathComponent:[self getDefaultBookName]];
        [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
        TextReaderViewController *textReaderViewController = segue.destinationViewController;
        [textReaderViewController setSavePath:savePath];
    }
}

@end
