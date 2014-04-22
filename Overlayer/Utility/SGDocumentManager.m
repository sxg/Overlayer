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


@interface SGDocumentManager ()

@property (readwrite, strong, nonatomic, setter = saveDocuments:) NSArray *documents;

@end

@implementation SGDocumentManager

@synthesize documents = _documents;

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

- (void)saveDocument:(SGDocument *)document
{
    NSMutableArray *allDocuments = [@[document] mutableCopy];
    if (self.documents) {
        [allDocuments addObjectsFromArray:self.documents];
    }
    [self saveDocuments:allDocuments];
}

- (void)saveDocuments:(NSArray *)documents
{
    //  Converting to a set and back to an array creates an array of unique objects
    _documents = [[NSOrderedSet orderedSetWithArray:documents] array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSKeyedArchiver archiveRootObject:_documents toFile:[[NSFileManager defaultManager] pathForPublicFile:@"documents"]];
    });
}

- (NSArray *)documents
{
    if (!_documents) {
        _documents = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSFileManager defaultManager] pathForPublicFile:@"documents"]];
    }
    return _documents;
}

@end
