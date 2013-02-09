//
//  PageListViewCell.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/9/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageListViewCell : UITableViewCell

@property UIActivityIndicatorView *loadingIndicator;
@property IBOutlet UILabel *label;

- (void)resizeAndAddLoadingIndicator;
- (void)resizeAndRemoveLoadingIndicator;

@end
