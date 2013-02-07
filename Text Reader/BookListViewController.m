//
//  BookListViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/31/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageListViewController.h"
#import "BookListViewController.h"
#import "TextReaderViewController.h"

@interface BookListViewController ()

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
    
    //need to setup images and imageNames
    [self firstLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    _books = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_documentsDirectory error:nil] mutableCopy];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)firstLoad
{
    _documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    _books = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_documentsDirectory error:nil] mutableCopy];
}

- (IBAction)addBook:(id)sender
{
    _bookName = [self getBookName];
    
    //Setup the view controller for the popover
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController setContentSizeForViewInPopover:CGSizeMake(260, 125)];
    [viewController.view setBackgroundColor:[UIColor whiteColor]];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(30, 60, 200, 35)];
    [textField setDelegate:self];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setPlaceholder:_bookName];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, 200, 35)];
    [label setText:@"Enter the book name:"];
    
    [viewController.view addSubview:textField];
    [viewController.view addSubview:label];
    _popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    
    [_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _bookName = textField.text;
    
    //Take the name that does not exist, create a new book with it, and add it to the data source
    NSString *path = [_documentsDirectory stringByAppendingPathComponent:_bookName];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    [_books addObject:_bookName];
    
    //Add the new book to the table
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_books count] - 1) inSection:0];
    NSArray *array = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [_popover dismissPopoverAnimated:YES];
    [textField resignFirstResponder];
    return YES;
}

- (NSString*)getBookName
{
    //Search the Documents directory for a book called "New Book". If it exists, then look for "New Book 2" etc.
    //There is a minor bug in this code - if "New Book", "New Book 2", and "New Book 4" are the only books that exist, then the next book that is added will be "New Book 3" instead of "New Book 5"
    bool alreadyExists;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:_documentsDirectory error:nil];
    int i = 1;
    NSString *newBookName;
    do {
        alreadyExists = NO;
        newBookName = @"New Book";
        if (i > 1)
        {
            NSString *num = [[[NSNumber alloc] initWithInt:i] stringValue];
            newBookName = [newBookName stringByAppendingString:@" "];
            newBookName = [newBookName stringByAppendingString:num];
        }
        
        for (NSString *fileName in files)
        {
            if ([fileName isEqualToString:newBookName])
            {
                alreadyExists = YES;
            }
        }
        i++;
    } while (alreadyExists);

    return newBookName;
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
    
    NSString *name = [_books objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    NSString *selectedBook = [_books objectAtIndex:indexPath.row];
    [_pageListViewController setBook:selectedBook];
    NSFileManager *fm = [NSFileManager defaultManager];
    _pageListViewController.savePath = [_pageListViewController.documentsDirectory stringByAppendingPathComponent:_pageListViewController.book];
    _pageListViewController.pages = [[fm contentsOfDirectoryAtPath:_pageListViewController.savePath error:nil] mutableCopy];
    
    _pageListViewController.navigationItem.title = _pageListViewController.book;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewBook"]) {    
        _pageListViewController = segue.destinationViewController;
        [_pageListViewController setDocumentsDirectory:_documentsDirectory];
    }
    else if ([segue.identifier isEqualToString:@"CameraFromBooks"])
    {
        NSString *savePath = [_documentsDirectory stringByAppendingPathComponent:[self getBookName]];
        [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
        TextReaderViewController *textReaderViewController = segue.destinationViewController;
        [textReaderViewController setSavePath:savePath];
    }
}

@end
