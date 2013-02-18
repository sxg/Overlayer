//
//  PageListViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/6/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

/*
    This is a UITableViewController subclass, and it is accessed via BookListViewController (BLVC). The table displays all the page images
    contained in the book folder in numerical order. The cells used are a subclass of UITableViewCell named PageListViewCell. PageListViewCell
    is equipped with a UILabel, and when the drawLines method is processing a particular cell, the UILabel will shift slightly to the right
    and a UIActivityIndicator will appear in the space to the left of the UILabel. PageListViewController allows the user to add a picture
    of another page via TextReaderViewController in the current book, delete pages, select a page to view, and draw strikethroughs on all
    images that have not yet had strikethroughs added to them in a background thread.
 
    _book is the string name of the current book
    _pages is an array containing the string names of all the page image file names in the current book folder and the data source for the table
    _savePath is a string path that points to the current book folder
    _documentsDirectory is a string path that points to the app's Documents directory
    _pageViewController is a reference to the view controller that will be called upon selecting a page from the table
    _drawLinesButton is a navigation bar button that calls the drawLines method to draw strikethroughs on all images in the current book
    _backgroundQueue is a queue that will handle the drawLines method in the background
 */

#import "PageListViewController.h"
#import "TextReaderViewController.h"
#import "UIImage+LineDrawer.h"
#import "DrawingView.h"
#import "PageListViewCell.h"
#import <dispatch/dispatch.h>
#import <QuartzCore/QuartzCore.h>

@interface PageListViewController ()

@property PageViewController *pageViewController;
@property UIBarButtonItem *drawLinesButton;
@property dispatch_queue_t backgroundQueue;

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
    
    
    
    //  Setup the "Edit" and "Draw Lines" navigation bar buttons
    _drawLinesButton = [[UIBarButtonItem alloc] initWithTitle:@"Draw Lines" style:UIBarButtonItemStyleDone target:self action:@selector(drawLines)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem, _drawLinesButton, nil];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    //  Create the background queue
    _backgroundQueue = dispatch_queue_create("backgroundQueue", NULL);
}

- (void)viewDidAppear:(BOOL)animated
{
    //  Everytime this view appears the table's list of pages needs to be refreshed
    _pages = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_savePath error:nil] mutableCopy];
    
    //  Sort the page names numerically instead of alphabetically so that 10.png does not appear before 2.png
    NSSortDescriptor *numericalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedStandardCompare:)];
    [_pages sortUsingDescriptors:[NSArray arrayWithObject:numericalSort]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Interface button actions

//  This method will draw strikethroughs on all unprocessed images within this book. The currently processing PageListViewCell's UILabel will shift slightly to the right and a UIActivityIndicator will appear in the space to the left of the UILabel with an animation. This method will take some time, so it will be handled in the background queue.
- (void)drawLines
{
    dispatch_async(_backgroundQueue, ^{
        //  Iterate through all the page file names in this book individually
        for (NSString *pageName in _pages)
        {
            //  Get the PageListViewCell corresponding to the current page file name and mark it as currently processing
            int i = [_pages indexOfObject:pageName];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            PageListViewCell *cell = (PageListViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setIsProcessing:YES];
            
            //  Do the UILabel shift and UIActivityIndicator addition animation on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell resizeAndAddLoadingIndicator:YES];
            });
            
            //  Get the actual image object and store it in a UIImage
            NSString *path = [_savePath stringByAppendingPathComponent:pageName];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
            
            //  If the image is unprocessed since unprocessed images have not been sized down to 1024x768
            if (image.size.width > 768)
            {
                //  Resize the image
                image = [image imageScaledToSize:CGSizeMake(768, 1024)];
                
                // imageAndPathView is a container view for both drawingView and imageView. drawingView is where the strikethroughs will be drawn by a UIBezierPath, and imageView is where the current image is displayed. imageAndPathView can be used to create a new image that contains the strikethroughs.
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                UIView *imageAndPathView = [[UIView alloc] initWithFrame:imageView.frame];
                [imageAndPathView addSubview:imageView];
                DrawingView *drawingView = [[DrawingView alloc] initWithFrame:imageView.frame];
                [imageAndPathView addSubview:drawingView];
                [imageAndPathView sendSubviewToBack:imageView];
                
                //  The first method actually draws the strikethroughs on the drawingView, and the second method consolidates the strikethroughs and the original image into one image and saves it with the same name as the original image
                [image identifyCharactersWithlineThickness:1.0 onView:drawingView bytesPerPixel:4 bitsPerComponent:8];
                [self saveWithLinesAndName:pageName onContainerView:imageAndPathView];
            }
            
            //  Mark the cell as not currently processing
            [cell setIsProcessing:NO];
            
            //  Unshift the UILabel and remove the UIActivityIndicator on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell resizeAndRemoveLoadingIndicator:YES];
            });
        }
    });
}

#pragma mark - Helper methods

//  This method takes a container view that has a subview containing the original image and another subview that has the strikethroughs drawn on it by a UIBezierPath and saves the container view as an image with the name pageName.png
- (void)saveWithLinesAndName:(NSString*)pageName onContainerView:(UIView*)imageAndPathView
{
    //  The path to the new image
    NSString *imagePath = [_savePath stringByAppendingPathComponent:pageName];
    
    //  Setup a new graphics context from the container view and create an image from that context
    UIGraphicsBeginImageContext(imageAndPathView.bounds.size);
    [imageAndPathView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //  Save the new image
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
}

#pragma mark - TextReaderViewControl delegate

//  TextReaderViewController calls this when an image has been saved. This implementation makes the PLVC refresh the table's data and display so that the newly saved image can be seen immediately.
- (void)finishedSavingImage:(NSString *)fileName
{
    //  All the image names in the current book folder
    _pages = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_savePath error:nil] mutableCopy];
    
    //  Sort the image names numerically so that 10.png does not come before 2.png
    NSSortDescriptor *numericalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedStandardCompare:)];
    [_pages sortUsingDescriptors:[NSArray arrayWithObject:numericalSort]];
    
    [self.tableView reloadData];
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
    
    //  Set the PageListViewCell's UILabel's text to the file name of the image it is supposed to open
    NSString *name = [_pages objectAtIndex:indexPath.row];
    [cell.label setFont:[UIFont fontWithName:@"Amoon1" size:20]];
    [cell.label setText:name];
    
    //  If this PageListViewCell is currently being processed, then shift the UILabel and add the UIActivityIndicator without an animation
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
        
        //  Remove the row from the table as well
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

//  This method is called after prepareForSegue: and it sets up the next view controller, PageViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
    //  Get the selected page and the path to that page
    NSString *page = [_pages objectAtIndex:indexPath.row];
    NSString *path = [_savePath stringByAppendingPathComponent:page];
    
    //  Perform the segue to PageViewController manually since in the Storyboard the segue is not setup to activate upon selecting a cell. This is because I want to allow users to also select specific cells that they would like to process (this functionality has not been implemented yet). Since selecting a cell is an ambiguous action, the segue is not performed simply on detecting a selection but on this specific type of selection.
    [self performSegueWithIdentifier:@"ViewPage" sender:self];
    
    //  Setup PageViewController's ivars and navbar title
    _pageViewController.pages = _pages;
    _pageViewController.savePath = _savePath;
    _pageViewController.currentPageIndex = indexPath.row;
    [_pageViewController.navigationItem setTitle:page];
    
    //  Create and configure a UIScrollView within which the selected image will be displayed, and get the selected image in a UIImage, and put it in a UIImageView
    _pageViewController.scrollView = [[UIScrollView alloc] init];
    [_pageViewController.scrollView setDelegate:_pageViewController];
    _pageViewController.image = [[UIImage alloc] initWithContentsOfFile:path];
    _pageViewController.imageView = [[UIImageView alloc] initWithImage:_pageViewController.image];
    [_pageViewController.scrollView addSubview:_pageViewController.imageView];
    [_pageViewController.scrollView setContentSize:CGSizeMake(_pageViewController.imageView.image.size.width, _pageViewController.imageView.image.size.height)];
    [_pageViewController.scrollView setMinimumZoomScale:1.0];
    [_pageViewController.scrollView setMaximumZoomScale:3.0];
    [_pageViewController.view addSubview:_pageViewController.scrollView];
    
    //  If the selected page is the first page, then disable the previous button. If the selected page is the last page, then disable the next button. Two "if"s are used in case there is only one image in the book and the first page is also the last page.
    if (_pageViewController.currentPageIndex == 0)
    {
        [_pageViewController.previousButton setEnabled:NO];
    }
    if (_pageViewController.currentPageIndex == [_pageViewController.pages count] - 1)
    {
        [_pageViewController.nextButton setEnabled:NO];
    }
    
    //  Configure the UIScrollView's size based on the current interface orientation. If the interface is portrait, then make the image take up the entire view, and if it's landscape, then horizontally center the image, but don't zoom in. 44 is the height of the navbar and toolbar, and 20 is the height of the status bar.
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        [_pageViewController.scrollView setFrame:CGRectMake(0, 0, _pageViewController.view.frame.size.width, _pageViewController.view.frame.size.height)];
    }
    else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        //  The x coordinate is half the difference between the device's width and the image's width. This centers the image horizontally.
        [_pageViewController.scrollView setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.height - _pageViewController.imageView.image.size.width) / 2, 0, _pageViewController.imageView.image.size.width, [UIScreen mainScreen].bounds.size.width - 44 - 20 - 44)];
    }
    
    //  In case the cell is not deselected automatically do it manually
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //  If the camera button has been touched, then setup TextReaderViewController
    if ([segue.identifier isEqualToString:@"CameraFromPages"])
    {
        TextReaderViewController *textReaderViewController = segue.destinationViewController;
        [textReaderViewController setDelegate:self];
        [textReaderViewController setSavePath:_savePath];
    }
    //  If a page's cell in the table has been selected, then setup PageViewController
    else if ([segue.identifier isEqualToString:@"ViewPage"])
    {
        _pageViewController = segue.destinationViewController;
    }
}

@end
