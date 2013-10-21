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
@property (nonatomic, readonly, strong) NSMutableArray *pages;
@property (nonatomic, readonly, assign) BOOL hasLinesDrawn;

- (id)initWithTitle:(NSString *)title;
- (NSString *)savePath;
- (void)addPage:(UIImage *)image;
- (void)drawLines;
- (void)destroy;

@end
