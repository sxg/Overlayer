//
//  PageListViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/6/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageViewController.h"
#import "TextReaderViewController.h"
#import "Book.h"
#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface PageListViewController : UITableViewController <TextReaderViewControllerDelegate, DBRestClientDelegate>

@property (nonatomic) DBRestClient *restClient;
@property (nonatomic) Book *book;
@property NSString *savePath;
@property NSString *documentsDirectory;

@end
