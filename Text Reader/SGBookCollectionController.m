//
//  SGBookCollectionController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/11/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGBookCollectionController.h"
#import "SGBookCollectionCell.h"
#import "SGBook.h"

@interface SGBookCollectionController ()

@property (nonatomic, readwrite, strong) NSMutableArray *books;

@end

@implementation SGBookCollectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    
    [self.collectionView reloadData];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _books.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SGBookCollectionCell *cell = (SGBookCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"bookCell" forIndexPath:indexPath];
    
    //  Configure the cell
    cell.bookTitle.text = [[_books objectAtIndex:indexPath.row] title];
    [cell.bookTitle setFont:[UIFont fontWithName:@"Amoon1" size:17.0f]];
    
    return cell;
}

#pragma mark - Collection view delegate

#pragma mark - Collection view flow layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(215, 275);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(25, 25, 25, 25);
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addBook"]) {
        SGAddBookController *addBookVC = (SGAddBookController *)segue.destinationViewController;
        addBookVC.delegate = self;
    }
}

@end
