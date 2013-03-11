//
//  Page.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Page.h"

@implementation Page

- (Page*)initWithPath:(NSString *)path andPageNumber:(NSUInteger)number
{
    self = [super init];
    if (self)
    {
        _pagePath = path;
        _pageNumber = number;
    }
    return self;
}

//  Get the UIImage associated at this page's path. nil if no path.
- (UIImage*)pageImage
{
    UIImage *image = nil;
    if (_pagePath != nil)
    {
        image = [UIImage imageWithContentsOfFile:_pagePath];
    }
    return image;
}

//  Returns the string "x.png" where x is the page number
- (NSString*)pageName
{
    return [NSString stringWithFormat:@"%ld.png", (long)_pageNumber];
}

@end
