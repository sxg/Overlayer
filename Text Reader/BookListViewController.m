//
//  BookListViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/31/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

/*
    This is a UITableViewController subclass, and it is the initial view controller. BookListViewController (BLVC) contains only one section,
    and it lists all the "books" that have been created with the app. Books are simply folders within which are images of pages. The
    only public method is addBook:, which allows the user to create a new book through a popover. If the camera button is touched and
    a picture is taken, then a new book folder is automatically created, and the new picture goes into the new folder. Books are listed
    in alphabetic order. 
 
    _books is an array containing the string names of all the books and the data source for the table
    _documentsDirectory is the string path of the Documents directory of the app
    _pageListViewController is a reference to the view controller that will be called upon selecting a book from the table
    _popover is the popover that appears when the add button is touched to add a new book
 */

#import "PageListViewController.h"
#import "BookListViewController.h"
#import "Page.h"
#import "BookListViewCell.h"
#import "BookViewController.h"
#import "PageViewController.h"
#import "TextReaderViewController.h"
#import "SettingsViewController.h"
#import "Book.h"
#import <DropboxSDK/DropboxSDK.h>

@interface BookListViewController ()

@property IBOutlet UICollectionView *cv;
@property (nonatomic) NSMutableArray *books;
@property NSString *documentsDirectory;
@property BookViewController *bookViewController;
@property PageViewController *pageViewController;
@property UIPopoverController *popover;
@property DBMetadata *folderMetadata;
@property (nonatomic) DBRestClient *restClient;

@end

@implementation BookListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;

    //  init variables
    _books = [[NSMutableArray alloc] init];
    
    //  Show the navigation controller's built-in toolbar
    [self.navigationController setToolbarHidden:NO];
    
    //  Need to setup images and imageNames
    _documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSMutableArray *bookTitles = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_documentsDirectory error:nil] mutableCopy];
    [self initializeBooks:bookTitles];
    
    //  Set background
    [self.navigationController.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"collectionViewBackground.png"]]];
    
    //  Set navbar color
    float grayVal = ((float)66/(float)255);
    UIColor *customGray = [UIColor colorWithRed:grayVal green:grayVal blue:grayVal alpha:1.0];
    [self.navigationController.navigationBar setTintColor:customGray];
    [self.navigationController.toolbar setTintColor:customGray];
    
    //  Link Dropbox
    [self linkWithDropbox];
}

- (void)viewDidAppear:(BOOL)animated
{
    //  Look for new folders AKA books
    NSMutableArray *bookTitles = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_documentsDirectory error:nil] mutableCopy];
    [self initializeBooks:bookTitles];
    [self.cv reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public methods

// Allow the user to add a new book by interacting with a textfield within a popover
- (IBAction)addBook:(id)sender
{
    if (_popover == nil || ![_popover isPopoverVisible])
    {
        //  Get a default book name of the form "New Book %i" that doesn't already exist
        NSString* bookName = [self getDefaultBookName];
        
        //  Setup the view controller for the popover
        UIViewController *viewController = [[UIViewController alloc] init];
        [viewController setContentSizeForViewInPopover:CGSizeMake(260, 125)];
        [viewController.view setBackgroundColor:[UIColor whiteColor]];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(30, 60, 200, 35)];
        [textField setDelegate:self];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        [textField setBackgroundColor:[UIColor whiteColor]];
        [textField setFont:[UIFont fontWithName:@"Amoon1" size:17]];
        [textField setText:bookName];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, 200, 35)];
        [label setFont:[UIFont fontWithName:@"Amoon1" size:17]];
        [label setText:@"Enter the book name:"];
        
        [viewController.view addSubview:textField];
        [viewController.view addSubview:label];
        _popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
        
        //  Present the popover
        [_popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - Helper methods

- (void)initializeBooks:(NSMutableArray*)bookTitles
{
    _books = [[NSMutableArray alloc] init];
    
    //  Sort names of pages numerically so that 10.png does not come before 2.png
    NSSortDescriptor *numericalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedStandardCompare:)];
    [bookTitles sortUsingDescriptors:[NSArray arrayWithObject:numericalSort]];
    
    for (NSString *bookTitle in bookTitles)
    {
        NSString *bookPath = [_documentsDirectory stringByAppendingPathComponent:bookTitle];
        Book *book = [[Book alloc] initWithPath:bookPath];
        [_books addObject:book];
    }
}

- (void)linkWithDropbox
{
    //  Check to see if the user's Dropbox account is linked to Text Reader
    if (![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
        
        //  Initial sync
        [self syncWithDropbox];
    }
}

- (DBRestClient*)restClient
{
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    
    return _restClient;
}

- (void)syncWithDropbox
{
    //  Iterate through each file and folder in the local Documents directory and upload to Dropbox
    NSArray *folders = [[[NSFileManager defaultManager] contentsAtPath:_documentsDirectory] copy];
    for (NSString *folder in folders)
    {
        NSString *currentFolderPath = [_documentsDirectory stringByAppendingPathComponent:folder];
        NSArray *files = [[[NSFileManager defaultManager] contentsAtPath:currentFolderPath] copy];
        
        for (NSString *file in files)
        {
            NSString *currentFilePath = [currentFolderPath stringByAppendingPathComponent:file];
            NSString *destPath = [[@"/" stringByAppendingPathComponent:folder] stringByAppendingPathComponent:file];
            
            //  Upload the file
            [[self restClient] uploadFile:file toPath:destPath withParentRev:nil fromPath:currentFilePath];
        }
    }
}

//  Search the Documents directory for a book called "New Book". If it exists, then look for "New Book 2" etc.
- (NSString*)getDefaultBookName
{
    //  There is a minor bug in this code - if "New Book", "New Book 2", and "New Book 4" are the only books that exist, then the next book that is added will be "New Book 3" instead of "New Book 5"
    //  Another minor bug: the numbers within the books will be sorted alphabetically and not numerically, so "New Book 10" will appear before "New Book 2"

    bool alreadyExists;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:_documentsDirectory error:nil];
    int i = 1;
    NSString *newBookName;
    do {
        alreadyExists = NO;
        newBookName = @"New Book";
        
        //  Don't append a number to the end of the first "New Book", but do it to all subsequent "New Book"s
        if (i > 1)
        {
            NSString *num = [[[NSNumber alloc] initWithInt:i] stringValue];
            newBookName = [newBookName stringByAppendingString:@" "];
            newBookName = [newBookName stringByAppendingString:num];
        }
        
        //  Look for a book AKA folder named newBookName in the Documents folder
        for (NSString *fileName in files)
        {
            if ([fileName isEqualToString:newBookName])
            {
                alreadyExists = YES;
            }
        }
        i++;
        
        //  Keep going until you find a book name that has not already been taken
    } while (alreadyExists);

    return newBookName;
}

#pragma mark - Dropbox delegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"File upload failed with error - %@", error);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    if (metadata.isDirectory)
    {
        _folderMetadata = metadata;
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //  Look for this book name in the list of books
    NSString *bookName = textField.text;
    BOOL found = false;
    for (Book *book in _books)
    {
        if ([book.title isEqualToString:bookName])
        {
            found = true;
        }
    }
    
    //  Add the new book only if the name does not already exist
    if (!found)
    {
        //  Create a new folder by the name the user specifies in the textfield, and add it to the data source _books
        NSString *path = [_documentsDirectory stringByAppendingPathComponent:bookName];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
        Book *book = [[Book alloc] initWithPath:path];
        [_books addObject:book];
        
        //  Create the folder on Dropbox
        [[self restClient] createFolder:[@"/" stringByAppendingPathComponent:bookName]];
        
        //  Add the new book to the table
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_books count] - 1) inSection:0];
        [self.cv insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
    
    //  Remove the popover and the keyboard
    [_popover dismissPopoverAnimated:YES];
    [textField resignFirstResponder];
    
    //  Reload the collection view
    [self viewDidAppear:YES];
    
    return YES;
}

#pragma mark - TextReaderViewControl delegate

//  TextReaderViewController calls this when an image has been saved. This implementation makes the PLVC refresh the table's data and display so that the newly saved image can be seen immediately.
- (void)finishedSavingImage:(NSString *)fileName toPath:(NSString *)path uploadToDropbox:(bool)shouldUpload
{
    if (shouldUpload)
    {
        //  Save image to Dropbox
        NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
        NSString *destDir = [@"/" stringByAppendingPathComponent:[pathComponents objectAtIndex:([pathComponents count] - 2)]];
        
        //  Look for an existing file
        [[self restClient] loadMetadata:destDir];
        NSString *parentRev = nil;
        for (DBMetadata *file in _folderMetadata.contents)
        {
            if ([file.filename isEqualToString:fileName])
            {
                parentRev = file.rev;
            }
        }
        _folderMetadata = nil;
        
        [[self restClient] uploadFile:fileName toPath:destDir withParentRev:parentRev fromPath:path];
    }
    
    //  All the image names in the current book folder
    NSMutableArray *bookTitles = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_documentsDirectory error:nil] mutableCopy];
    [self initializeBooks:bookTitles];
    [self.cv reloadData];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //  The collection view will be populated with only books
    return [_books count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //  The only section is the section that displays the books
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookListViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookCell" forIndexPath:indexPath];
    cell.bookTitle.text = ((Book*)[_books objectAtIndex:indexPath.row]).title;
    [cell.bookTitle setFont:[UIFont fontWithName:@"Amoon1" size:17]];
    
    return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //  Get the name of the selected book, tell PLVC the book name, tell PLVC the path to that book, and set PLVC up with all the names of pages contained in that book folder
    Book *selectedBook = (Book*)[_books objectAtIndex:indexPath.row];
    [_bookViewController setBook:selectedBook];
    _bookViewController.savePath = [_bookViewController.documentsDirectory stringByAppendingPathComponent:_bookViewController.book.title];
    _bookViewController.bookTitle.text = selectedBook.title;
    _bookViewController.numPages.text = [NSString stringWithFormat:@"%i", [selectedBook.pages count]];
    
    //  Set PLVC's navbar's title to the name of the book
    _bookViewController.navigationItem.title = _bookViewController.book.title;
}

#pragma mark - Collection view flow layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(215, 275);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(25, 25, 25, 25);
}

#pragma mark - Segue control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  Go to the PageListViewController if the user selected a book from the table
    if ([segue.identifier isEqualToString:@"ViewBook"]) {
        //  Get the PLVC that's about to come into view, and tell it where the app's Documents directory is
        _bookViewController = (BookViewController*) ((UINavigationController*) segue.destinationViewController).topViewController;
        _bookViewController.bookListViewController = self;
        _bookViewController.documentsDirectory = _documentsDirectory;
    }
    //  Go to the TextReaderViewController if the user wants to take a picture from here (BLVC)
    else if ([segue.identifier isEqualToString:@"CameraFromBooks"])
    {
        //  Since a book name has not been specified but the user wants to take a picture, get a default book name, make a folder with that name, create a path to that folder, and give TRVC that path so it knows where to save the picture
        NSString *defaultBookName = [self getDefaultBookName];
        NSString *savePath = [_documentsDirectory stringByAppendingPathComponent:defaultBookName];
        [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
        
        //  Create book folder on Dropbox
        NSString *dropboxPath = [@"/" stringByAppendingPathComponent:defaultBookName];
        [[self restClient] createFolder:dropboxPath];
        
        TextReaderViewController *textReaderViewController = segue.destinationViewController;
        [textReaderViewController setSavePath:savePath];
        [textReaderViewController setDelegate:self];
    }
    else if ([segue.identifier isEqualToString:@"ViewPage"])
    {
        _pageViewController = segue.destinationViewController;
        [self setupPageViewControllerSegueWithPage:[_bookToOpen.pages objectAtIndex:0] andIndex:0];
    }
}

- (void)setupPageViewControllerSegueWithPage:(Page*)page andIndex:(NSUInteger)index
{
    //  Setup PageViewController's ivars and navbar title
    _pageViewController.book = _bookToOpen;
    _pageViewController.savePath = [_documentsDirectory stringByAppendingPathComponent:_bookToOpen.title];
    _pageViewController.currentPageIndex = index;
    [_pageViewController.navigationItem setTitle:_bookToOpen.title];
    
    //  Create and configure a UIScrollView within which the selected image will be displayed, and get the selected image in a UIImage, and put it in a UIImageView
    _pageViewController.scrollView = [[UIScrollView alloc] init];
    [_pageViewController.scrollView setDelegate:_pageViewController];
    _pageViewController.image = [page pageImage];
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
    if (_pageViewController.currentPageIndex == [_pageViewController.book.pages count] - 1)
    {
        [_pageViewController.nextButton setEnabled:NO];
    }
    
    //  Configure the UIScrollView's size based on the current interface orientation. If the interface is portrait, then make the image take up the entire view, and if it's landscape, then horizontally center the image, but don't zoom in. 44 is the height of the navbar and toolbar, and 20 is the height of the status bar.
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        [_pageViewController.scrollView setFrame:CGRectMake(0, 0, _pageViewController.view.frame.size.width, _pageViewController.view.frame.size.height - 44 - 44)];
    }
    else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        //  The x coordinate is half the difference between the device's width and the image's width. This centers the image horizontally.
        [_pageViewController.scrollView setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.height - _pageViewController.imageView.image.size.width) / 2, 0, _pageViewController.imageView.image.size.width, [UIScreen mainScreen].bounds.size.width - 44 - 20 - 44)];
    }
    
    //  Setup the page indicator
    [_pageViewController setupPageIndicator];
    
}

@end
