//
//  SettingsViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/18/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsStrikethroughWidthDetailViewController.h"

@interface SettingsViewController ()

@property UIBarButtonItem *doneButton;

@end

@implementation SettingsViewController

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
    
    
    //  Setup the navbar
    [self.navigationController setNavigationBarHidden:NO];
    float grayVal = ((float)66/(float)255);
    UIColor *customGray = [UIColor colorWithRed:grayVal green:grayVal blue:grayVal alpha:1.0];
    [self.navigationController.navigationBar setTintColor:customGray];
    
    //  Setup the defualt strikethrough value if not already set
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"strikethroughWidth"] == nil)
    {
        NSNumber *strikethroughWidth = [[NSNumber alloc] initWithFloat:1.0];
        [defaults setObject:strikethroughWidth forKey:@"strikethroughWidth"];
        [defaults synchronize];
        [_strikethroughWidth setText:@"1.0"];
    }
    else
    {
        NSNumber *strikethroughWidth = [defaults objectForKey:@"strikethroughWidth"];
        [_strikethroughWidth setText:[NSString stringWithFormat:@"%.1f", [strikethroughWidth floatValue]]];
    }
    
    //  Setup the save button
    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSelf)];
    UINavigationItem *doneButton = [[UINavigationItem alloc] initWithTitle:@"Settings"];
    doneButton.rightBarButtonItem = _doneButton;
    doneButton.hidesBackButton = YES;
    [self.navigationController.navigationBar pushNavigationItem:doneButton animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper methods

- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Strikethrough width delegate

- (void)sswdvcDidFinishPickingStrikethroughWidth:(float)width
{
    //  Set the strikethroughWidth text field
    NSString *strikethroughWidth = [NSString stringWithFormat:@"%.1f", width];
    [_strikethroughWidth setText:strikethroughWidth];
    
    //  Save settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *strikethroughWidthWrapper = [[NSNumber alloc] initWithFloat:width];
    [defaults setObject:strikethroughWidthWrapper forKey:@"strikethroughWidth"];
    [defaults synchronize];
    
    //  Pop the view controller to go back to the main settings page (AKA this view controller)
    [self.navigationController popViewControllerAnimated:YES];
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
}

#pragma mark - Navigation control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //  If we're going to the strikethrough width detail VC, then we have to set the delegate first
    if ([segue.identifier isEqualToString:@"StrikethroughWidthDetail"])
    {
        SettingsStrikethroughWidthDetailViewController *sswdvc = segue.destinationViewController;
        [sswdvc setDelegate:self];
    }
}

@end
