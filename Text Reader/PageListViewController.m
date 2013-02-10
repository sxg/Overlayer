//
//  PageListViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/6/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageListViewController.h"
#import "TextReaderViewController.h"
#import "UIImage+LineDrawer.h"
#import "DrawingView.h"
#import "PageListViewCell.h"
#import <dispatch/dispatch.h>
#import <QuartzCore/QuartzCore.h>

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
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //NSArray *buttonItems = [[NSArray alloc] initWithObjects:self.navigationItem.backBarButtonItem, self.editButtonItem, nil];
    _drawLinesButton = [[UIBarButtonItem alloc] initWithTitle:@"Draw Lines" style:UIBarButtonItemStyleDone target:self action:@selector(drawLines)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem, _drawLinesButton, nil];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    _backgroundQueue = dispatch_queue_create("backgroundQueue", NULL);
}

- (void)viewDidAppear:(BOOL)animated
{
    _pages = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_savePath error:nil] mutableCopy];
    
    NSSortDescriptor *numericalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedStandardCompare:)];
    [_pages sortUsingDescriptors:[NSArray arrayWithObject:numericalSort]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawLines
{
    dispatch_async(_backgroundQueue, ^{
        for (NSString *pageName in _pages)
        {
            int i = [_pages indexOfObject:pageName];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            PageListViewCell *cell = (PageListViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setIsProcessing:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell resizeAndAddLoadingIndicator:YES];
            });
            
            NSString *path = [_savePath stringByAppendingPathComponent:pageName];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
            
            //if the image is unprocessed since unprocessed images have not been sized down to 1024x768
            if (image.size.width > 768)
            {
                image = [image imageScaledToSize:CGSizeMake(768, 1024)];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                UIView *imageAndPathView = [[UIView alloc] initWithFrame:imageView.frame];
                [imageAndPathView addSubview:imageView];
                DrawingView *drawingView = [[DrawingView alloc] initWithFrame:imageView.frame];
                [imageAndPathView addSubview:drawingView];
                [imageAndPathView sendSubviewToBack:imageView];
                
                [image identifyCharactersWithlineThickness:1.0 onView:drawingView bytesPerPixel:4 bitsPerComponent:8];
                [self saveWithLinesAndName:pageName onContainerView:imageAndPathView];
            }
            
            [cell setIsProcessing:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell resizeAndRemoveLoadingIndicator:YES];
            });
        }
    });
}

- (void)saveWithLinesAndName:(NSString*)pageName onContainerView:(UIView*)imageAndPathView
{
    NSString *imagePath = [_savePath stringByAppendingPathComponent:pageName];
    
    UIGraphicsBeginImageContext(imageAndPathView.bounds.size);
    [imageAndPathView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
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
    PageListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *name = [_pages objectAtIndex:indexPath.row];
    [cell.label setText:name];
    if ([cell isProcessing]) {
        [cell resizeAndAddLoadingIndicator:NO];
    }
    
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
        NSString *pageToDelete = [_pages objectAtIndex:indexPath.row];
        NSString *pathToPage = [_savePath stringByAppendingPathComponent:pageToDelete];
        [[NSFileManager defaultManager] removeItemAtPath:pathToPage error:nil];
        [_pages removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
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
    
    NSString *page = [_pages objectAtIndex:indexPath.row];
    NSString *path = [_savePath stringByAppendingPathComponent:page];
    
    [self performSegueWithIdentifier:@"ViewPage" sender:self];
    
    _pageViewController.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _pageViewController.view.frame.size.width, _pageViewController.view.frame.size.height)];
    [_pageViewController.scrollView setDelegate:_pageViewController];
    _pageViewController.image = [[UIImage alloc] initWithContentsOfFile:path];
    _pageViewController.imageView = [[UIImageView alloc] initWithImage:_pageViewController.image];
    [_pageViewController.scrollView addSubview:_pageViewController.imageView];
    [_pageViewController.scrollView setContentSize:CGSizeMake(_pageViewController.imageView.image.size.width, _pageViewController.imageView.image.size.height)];
    [_pageViewController.scrollView setMinimumZoomScale:1.0];
    [_pageViewController.scrollView setMaximumZoomScale:3.0];
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
    }
}

@end
