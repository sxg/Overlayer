//
//  BookViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/13/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Book.h"
#import "BookListViewController.h"
#import "TextReaderViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <UIKit/UIKit.h>

@interface BookViewController : UIViewController <TextReaderViewControllerDelegate, DBRestClientDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) DBRestClient *restClient;
@property (nonatomic) Book *book;
@property IBOutlet UILabel *bookTitle;
@property IBOutlet UILabel *numPages;
@property IBOutlet UIScrollView *scrollingPages;
@property NSString *savePath;
@property NSString *documentsDirectory;
@property BookListViewController *bookListViewController;

- (IBAction)closeModalViewController:(id)sender;
- (IBAction)deleteBook:(id)sender;
- (IBAction)openBook:(id)sender;
- (IBAction)addPage:(id)sender;
- (IBAction)imageViewTapped:(id)sender;

@end
