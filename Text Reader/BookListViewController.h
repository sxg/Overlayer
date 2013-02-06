//
//  PhotoListViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/31/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

@interface BookListViewController : UITableViewController

@property NSMutableDictionary *images;
@property NSString *mainPath;
@property PageViewController *destination;

- (void)firstLoad;

@end
