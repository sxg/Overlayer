//
//  SettingsStrikethroughWidthDetailViewController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/18/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsStrikethroughWidthDetailViewControllerDelegate <NSObject>

@required
- (void)sswdvcDidFinishPickingStrikethroughWidth:(float)width;

@end

@interface SettingsStrikethroughWidthDetailViewController : UITableViewController

@property id<SettingsStrikethroughWidthDetailViewControllerDelegate> delegate;

@end
