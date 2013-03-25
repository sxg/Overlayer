//
//  Book.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Book.h"
#import "Page.h"

@implementation Book

- (Book*)initWithPath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        _title = [[path pathComponents] lastObject];
        _pages = [[NSMutableArray alloc] init];
        _path = path;
        
        NSMutableArray *pageNames = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil] mutableCopy];
        [pageNames removeObject:@"small"];
        
        //  Sort names of pages numerically so that 10.png does not come before 2.png
        NSSortDescriptor *numericalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedStandardCompare:)];
        [pageNames sortUsingDescriptors:[NSArray arrayWithObject:numericalSort]];
        
        for (NSString *pageName in pageNames)
        {
            NSString *pagePath = [path stringByAppendingPathComponent:pageName];
            NSUInteger pageNumber = [[[pageName componentsSeparatedByString:@".png"] objectAtIndex:0] intValue];
            Page *page = [[Page alloc] initWithPath:pagePath andPageNumber:pageNumber];
            [_pages addObject:page];
        }
        
        _numPages = [_pages count];
    }
    return self;
}

@end
