//
//  SettingsViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/18/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SettingsStrikethroughWidthDetailViewController.h"
#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController <SettingsStrikethroughWidthDetailViewControllerDelegate>

@property IBOutlet UILabel *strikethroughWidth;

@end
