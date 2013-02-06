//
//  PageListViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/6/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageListViewController.h"
#import "TextReaderViewController.h"

@interface PageListViewController ()

@end

@implementation PageListViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [_pages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Page";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *name = [_pages objectAtIndex:indexPath.row];
    [cell.textLabel setText:name];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    
    NSString *page = [_pages objectAtIndex:indexPath.row];
    NSString *path = [_savePath stringByAppendingPathComponent:page];
    
    _pageViewController.image = [[UIImage alloc] initWithContentsOfFile:path];
    _pageViewController.imageView = [[UIImageView alloc] initWithImage:_pageViewController.image];
    [_pageViewController.scrollView addSubview:_pageViewController.imageView];
    [_pageViewController.scrollView setContentSize:CGSizeMake(_pageViewController.image.size.width, _pageViewController.image.size.height)];
    [_pageViewController.scrollView setMinimumZoomScale:1.0];
    [_pageViewController.scrollView setMaximumZoomScale:3.0];
    [_pageViewController.scrollView setShowsHorizontalScrollIndicator:YES];
    [_pageViewController.view addSubview:_pageViewController.scrollView];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CameraFromPages"])
    {
        TextReaderViewController *textReaderViewController = segue.destinationViewController;
        [textReaderViewController setSavePath:_savePath];
    }
    else if ([segue.identifier isEqualToString:@"ViewPage"])
    {
        _pageViewController = segue.destinationViewController;
        _pageViewController.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _pageViewController.view.frame.size.width, _pageViewController.view.frame.size.height)];
        [_pageViewController.scrollView setDelegate:_pageViewController];
    }
}

@end
