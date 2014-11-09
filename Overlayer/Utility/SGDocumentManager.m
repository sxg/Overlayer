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

//  Models
#import "SGDocument.h"


@interface SGDocumentManager ()

@property (readwrite, strong, nonatomic) NSURL *currentURL;

@end

@implementation SGDocumentManager

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
        allDocuments = [self.documents mutableCopy];
        [allDocuments addObject:document];
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

- (void)destroyDocument:(SGDocument *)document completion:(void (^)(BOOL))completion
{
    //  The document must exist to be destroyed
    if ([self.documents containsObject:document]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //  Delete the document
            [document destroy];
            
            NSError *error;
            NSString *archivePath = [[NSFileManager defaultManager] pathForPublicFile:@"documents"];
            if (![[NSFileManager defaultManager] removeItemAtPath:archivePath error:&error]) {
                NSLog(@"%@", error);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //  Save all documents except the one to be removed
                NSMutableArray *mutableDocumentsArray = [self.documents mutableCopy];
                [mutableDocumentsArray removeObject:document];
                [self saveDocuments:mutableDocumentsArray];
                
                if (completion) {
                    error ? completion(NO) : completion(YES);
                }
            });
        });
    }
}

- (NSArray *)documents
{
    if (!_documents) {
        _documents = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSFileManager defaultManager] pathForPublicFile:@"documents"]];
    }
    return _documents;
}

- (void)moveToSubFolder:(NSString *)subFolder
{
    self.currentURL = [self.currentURL URLByAppendingPathComponent:subFolder isDirectory:YES];
}

- (void)moveToParentFolder
{
    self.currentURL = [self.currentURL URLByDeletingLastPathComponent];
}

@end
