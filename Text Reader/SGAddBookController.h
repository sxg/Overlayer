//
//  SGAddBookController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/11/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGAddBookController;


@protocol SGAddBookDelegate <NSObject>

- (void)addBookController:(SGAddBookController *)addBookVC didAddBookWithTitle:(NSString *)title;

@end


#import "SGBookCollectionController.h"


@interface SGAddBookController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<SGAddBookDelegate> delegate;

@end
