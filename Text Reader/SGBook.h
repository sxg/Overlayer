//
//  SGSGBook.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGBook : NSObject

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, strong) NSArray *pages;

- (id)initWithTitle:(NSString *)title;

@end
