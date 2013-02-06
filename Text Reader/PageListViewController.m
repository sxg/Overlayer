//
//  PhotoListViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/31/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageViewController.h"
#import "BookListViewController.h"

@interface PageListViewController ()

@end

@implementation PageListViewController

@synthesize images;
@synthesize mainPath;
@synthesize destination;

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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //need to setup images and imageNames
    //[self firstLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    /*NSArray *updatedImageNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mainPath error:nil];
    bool update = false;
    
    if ([updatedImageNames count] != [[images allKeys] count])
    {
        update = true;
    }
    else
    {
        //[updatedImageNames count] should equal [imageNames count] in this else block
        for (int i = 0; i < [updatedImageNames count]; i++)
        {
            NSString *updated = [updatedImageNames objectAtIndex:i];
            NSString *original = [[images allKeys] objectAtIndex:i];
            
            if (![updated isEqualToString:original])
            {
                update = true;
            }
        }
    }
        
    if (update)
    {
        for (NSString *imageName in updatedImageNames)
        {
            if (![[images allKeys] containsObject:imageName])
            {
                NSString *path = [mainPath stringByAppendingPathComponent:imageName];
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
                [images setObject:image forKey:imageName];
            }
        }
        
        for (NSString *imageName in [images allKeys])
        {
            if (![updatedImageNames containsObject:imageName])
            {
                [images removeObjectForKey:imageName];
            }
        }
        [self.tableView reloadData];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)firstLoad
{
    mainPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSMutableArray *imageNames = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:mainPath error:nil] mutableCopy];
    images = [[NSMutableDictionary alloc] initWithCapacity:[imageNames count]];
    for (NSString *name in imageNames)
    {
        NSString *path = [mainPath stringByAppendingPathComponent:name];
        //UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        [images setObject:path forKey:name];
    }
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
    return [images count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ImageListing";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString *name = @"";
    name = [name stringByAppendingFormat:@"%i.png", (indexPath.row + 1)];
    //UIImage *image = [images objectForKey:name];
    //cell.imageView.image = image;
    [cell.textLabel setText:[NSString stringWithFormat:@"%i.png", (indexPath.row + 1)]];
    
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
    
    NSString *name = @"";
    name = [name stringByAppendingFormat:@"%i.png", (indexPath.row + 1)];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[images objectForKey:name]];
    destination.image = image;
    
    destination.imageView = [[UIImageView alloc] initWithImage:destination.image];
    [destination.scrollView addSubview:destination.imageView];
    [destination.scrollView setContentSize:CGSizeMake(destination.image.size.width, destination.image.size.height)];
    [destination.scrollView setMinimumZoomScale:1.0];
    [destination.scrollView setMaximumZoomScale:3.0];
    [destination.scrollView setShowsHorizontalScrollIndicator:YES];
    [destination.view addSubview:destination.scrollView];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Detail"]) {
        destination = segue.destinationViewController;
        [destination setHidesBottomBarWhenPushed:YES];
        destination.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, destination.view.frame.size.width, destination.view.frame.size.height)];
        [destination.scrollView setDelegate:destination];
    }
}

@end
