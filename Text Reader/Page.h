//
//  Page.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Page : NSObject

@property NSString *pagePath;
@property NSUInteger pageNumber;

- (Page*)initWithPath:(NSString *)path andPageNumber:(NSUInteger)number;
- (UIImage*)pageImage;
- (NSString*)pageName;

@end
