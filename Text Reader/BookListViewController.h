//
//  BookListViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/31/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Book.h"
#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "PageListViewController.h"

@interface BookListViewController : UIViewController <UITextFieldDelegate, DBRestClientDelegate, TextReaderViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (IBAction)addBook:(id)sender;

@end
