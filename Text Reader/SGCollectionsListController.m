//
//  SGcollectionsListController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/11/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGCollectionsListController.h"
#import "SGAddCollectionController.h"
#import "SGDocumentController.h"
#import "SGDocumentsListController.h"
#import "SGCollection.h"

@interface SGCollectionsListController ()

@property (nonatomic, weak) SGDocumentController *documentVC;

@property (nonatomic, readwrite, strong) NSMutableArray *collections;

@end

@implementation SGCollectionsListController

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
    _documentVC = (SGDocumentController *)[[[[splitVC viewControllers] lastObject] viewControllers] lastObject];
    
    _collections = [[NSMutableArray alloc] init];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSArray *collectionDirectories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString *collectionDirectoryName in collectionDirectories) {
        SGCollection *collection = [[SGCollection alloc] initWithTitle:collectionDirectoryName];
        [_collections addObject:collection];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SGAddCollection delegate

- (void)addCollectionController:(SGAddCollectionController *)addcollectionVC didAddCollectionWithTitle:(NSString *)title
{
    SGCollection *collection = [[SGCollection alloc] initWithTitle:title];
    [_collections addObject:collection];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(_collections.count - 1) inSection:0];
    
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
    return _collections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"collectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[_collections objectAtIndex:indexPath.row] title];
    cell.textLabel.font = [UIFont fontWithName:@"Amoon1" size:16];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete) {
        
        SGCollection *collection = [_collections objectAtIndex:indexPath.row];
        [collection deleteCollection];
        [_collections removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addCollection"]) {
        SGAddCollectionController *addCollectionVC = (SGAddCollectionController *)[[segue.destinationViewController viewControllers] lastObject];
        [addCollectionVC setDelegate:self];
    } else if ([segue.identifier isEqualToString:@"selectCollection"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        SGDocumentsListController *documentsLstVC = (SGDocumentsListController *)segue.destinationViewController;
        
        [documentsLstVC setCollection:_collections[indexPath.row]];
    }
}

@end
