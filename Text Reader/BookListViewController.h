//
//  BookListViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/31/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGBook.h"
#import "Page.h"
#import <UIKit/UIKit.h>
#import "PageListViewController.h"

@interface BookListViewController : UIViewController <UITextFieldDelegate, TextReaderViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property PageViewController *pageViewController;

- (IBAction)addBook:(id)sender;
- (void)setupPageViewControllerSegueWithBook:(SGBook*)book Page:(Page*)page Index:(NSUInteger)index;

@end
