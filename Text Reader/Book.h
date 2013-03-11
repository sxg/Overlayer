//
//  Book.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property NSString *title;
@property NSUInteger numPages;
@property NSMutableArray *pages;
@property NSString *path;

- (Book*)initWithPath:(NSString*)path;

@end
