//
//  SGBookListViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/11/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGBookListViewController.h"
#import "SGBookViewController.h"
#import "SGBook.h"

@interface SGBookListViewController ()

@property (nonatomic, weak) SGBookViewController *bookVC;

@property (nonatomic, readwrite, strong) NSMutableArray *books;

@end

@implementation SGBookListViewController

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
    
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController.parentViewController;
    _bookVC = (SGBookViewController *)[[splitVC viewControllers] lastObject];
    
    _books = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SGAddBook delegate

- (void)addBookController:(SGAddBookController *)addBookVC didAddBookWithTitle:(NSString *)title
{
    SGBook *book = [[SGBook alloc] initWithTitle:title];
    [_books addObject:book];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(_books.count - 1) inSection:0];
    
    NSString *bookDirectory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:title];
    [[NSFileManager defaultManager] createDirectoryAtPath:bookDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    return _books.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"bookCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[_books objectAtIndex:indexPath.row] title];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete) {
        
        SGBook *book = [_books objectAtIndex:indexPath.row];
        [_books removeObjectAtIndex:indexPath.row];
        
        NSString *bookDirectory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:book.title];
        [[NSFileManager defaultManager] removeItemAtPath:bookDirectory error:nil];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _bookVC.label.text = [[_books objectAtIndex:indexPath.row] title];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addBook"]) {
        SGAddBookController *addBookVC = (SGAddBookController *)[[segue.destinationViewController viewControllers] lastObject];
        [addBookVC setDelegate:self];
    }
}

@end
