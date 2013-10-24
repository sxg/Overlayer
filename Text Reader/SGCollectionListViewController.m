//
//  SGCollectionListViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/11/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGCollectionListViewController.h"
#import "SGCollectionViewController.h"
#import "SGCollection.h"

@interface SGCollectionListViewController ()

@property (nonatomic, weak) SGCollectionViewController *CollectionVC;

@property (nonatomic, readwrite, strong) NSMutableArray *Collections;

@end

@implementation SGCollectionListViewController

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
    _CollectionVC = (SGCollectionViewController *)[[[[splitVC viewControllers] lastObject] viewControllers] lastObject];
    
    _Collections = [[NSMutableArray alloc] init];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSArray *CollectionDirectories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString *CollectionDirectoryName in CollectionDirectories) {
        SGCollection *collection = [[SGCollection alloc] initWithTitle:CollectionDirectoryName];
        [_Collections addObject:collection];
    }
    
    if (_Collections.count > 0) {
        _CollectionVC.collection = _Collections[0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SGAddCollection delegate

- (void)addCollectionController:(SGAddCollectionController *)addCollectionVC didAddCollectionWithTitle:(NSString *)title
{
    SGCollection *collection = [[SGCollection alloc] initWithTitle:title];
    [_Collections addObject:collection];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(_Collections.count - 1) inSection:0];
    
    NSString *CollectionDirectory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:title];
    [[NSFileManager defaultManager] createDirectoryAtPath:CollectionDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    
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
    return _Collections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"collectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[_Collections objectAtIndex:indexPath.row] title];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete) {
        
        SGCollection *collection = [_Collections objectAtIndex:indexPath.row];
        [_Collections removeObjectAtIndex:indexPath.row];
        
        NSString *CollectionDirectory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:collection.title];
        [[NSFileManager defaultManager] removeItemAtPath:CollectionDirectory error:nil];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _CollectionVC.collection = _Collections[indexPath.row];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addCollection"]) {
        SGAddCollectionController *addCollectionVC = (SGAddCollectionController *)[[segue.destinationViewController viewControllers] lastObject];
        [addCollectionVC setDelegate:self];
    }
}

@end
