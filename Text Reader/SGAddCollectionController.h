//
//  SGAddCollectionController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/11/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGAddCollectionController;


@protocol SGAddCollectionDelegate <NSObject>

- (void)addCollectionController:(SGAddCollectionController *)addCollectionVC didAddCollectionWithTitle:(NSString *)title;

@end


@interface SGAddCollectionController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<SGAddCollectionDelegate> delegate;

@end
