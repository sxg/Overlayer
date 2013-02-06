//
//  PhotoListViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/31/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoViewController.h"

@interface PhotoListViewController : UITableViewController

@property NSMutableDictionary *images;
@property NSString *mainPath;
@property PhotoViewController *destination;

- (void)firstLoad;

@end
