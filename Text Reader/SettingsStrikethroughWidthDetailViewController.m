//
//  SettingsStrikethroughWidthDetailViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/18/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SettingsStrikethroughWidthDetailViewController.h"

@interface SettingsStrikethroughWidthDetailViewController ()

@end

@implementation SettingsStrikethroughWidthDetailViewController

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
    
    //  Tell the delegate that a strikethrough width has been specified
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [_delegate sswdvcDidFinishPickingStrikethroughWidth:[cell.textLabel.text floatValue]];
}

@end
