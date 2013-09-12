//
//  SGPageListController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/11/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGBook.h"

@interface SGPageListController : UITableViewController

@property (nonatomic, readwrite, strong) SGBook *book;

@end
