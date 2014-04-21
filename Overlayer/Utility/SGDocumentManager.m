//
//  SGDocumentManager.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGDocumentManager.h"

//  Frameworks
#import <StandardPaths/StandardPaths.h>


@implementation SGDocumentManager

static SGDocumentManager *sharedManager;

+ (SGDocumentManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SGDocumentManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)saveDocuments:(NSArray *)documents
{
    [NSKeyedArchiver archiveRootObject:documents toFile:[[NSFileManager defaultManager] pathForPublicFile:@"documents"]];
}

- (NSArray *)documents
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSFileManager defaultManager] pathForPublicFile:@"documents"]];
}

@end
