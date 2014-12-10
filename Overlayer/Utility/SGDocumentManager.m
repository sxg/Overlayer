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
        self.currentURL = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]];
    }
    return self;
}

- (void)moveToSubfolder:(NSString *)subfolderName
{
    NSURL *newURL = [self.currentURL URLByAppendingPathComponent:subfolderName isDirectory:YES];
    BOOL isDir = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[newURL path] isDirectory:&isDir]) {
        self.currentURL = newURL;
    }
}

- (void)moveToParentFolder
{
    //  If the current folder isn't the Documents directory, then move up to the parent folder
    NSString *documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    if (![documentsDirectoryPath isEqualToString:[self.currentURL path]]) {
        self.currentURL = [self.currentURL URLByDeletingLastPathComponent];
    }
}

- (void)createFolder:(NSString *)folderName
{
    NSError *err;
    NSURL *newFolderURL = [self.currentURL URLByAppendingPathComponent:folderName isDirectory:YES];
    if (![[NSFileManager defaultManager] createDirectoryAtURL:newFolderURL withIntermediateDirectories:YES attributes:nil error:&err] || err) {
        NSLog(@"Failed to create folder %@ %@", newFolderURL, err);
    }
}

- (void)destroyFolder:(NSString *)folderName
{
    NSError *err;
    NSURL *folderToDestroyURL = [self.currentURL URLByAppendingPathComponent:folderName isDirectory:YES];
    if (![[NSFileManager defaultManager] removeItemAtURL:folderToDestroyURL error:&err] || err) {
        NSLog(@"Failed to destroy folder %@ %@", folderToDestroyURL, err);
    }
}

- (void)saveDocument:(SGDocument *)document
{
    //  Create the document directory
    NSString *documentDirectoryName = [[document.uuid UUIDString] stringByAppendingPathExtension:@"overlayer"];
    NSURL *documentDirectoryURL = [self.currentURL URLByAppendingPathComponent:documentDirectoryName isDirectory:YES];
    NSError *err;
    [[NSFileManager defaultManager] createDirectoryAtURL:documentDirectoryURL withIntermediateDirectories:NO attributes:nil error:&err];
    if (err) {
        NSLog(@"Failed to create directory at URL: %@ error: %@", documentDirectoryURL, err);
    } else {
        //  Write the document PDF data
        NSURL *pdfDataURL = [documentDirectoryURL URLByAppendingPathComponent:@"pdf.pdf"];
        if (![document.pdfData writeToFile:[pdfDataURL path] atomically:YES]) {
            NSLog(@"Failed to save document: %@ to URL: %@", document, pdfDataURL);
        } else {
            //  Set the document's URL and write the archive
            document.url = documentDirectoryURL;
            NSURL *archiveURL = [documentDirectoryURL URLByAppendingPathComponent:@"archive"];
            [NSKeyedArchiver archiveRootObject:document toFile:[archiveURL path]];
        }
    }
}

- (void)destroyDocumentAtURL:(NSURL *)url
{
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtURL:url error:&err];
    if (err) {
        NSLog(@"Failed to destroy document at URL: %@ error: %@", url, err);
    }
}

- (void)moveDocument:(SGDocument *)document
{
    [self destroyDocumentAtURL:document.url];
    document.url = self.currentURL;
    [self saveDocument:document];
}

- (NSArray *)documents
{
    NSError *err;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.currentURL path] error:&err];
    if (err) {
        NSLog(@"%@", err);
    }
    return [contents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *pathItem, NSDictionary *bindings) {
        return [pathItem containsString:@".overlayer"] ? YES : NO;
    }]];
}

- (NSArray *)folders
{
    NSError *err;
    NSMutableArray *contents = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.currentURL path] error:&err] mutableCopy];
    if (err) {
        NSLog(@"%@", err);
    }
    [contents removeObjectsInArray:[self documents]];
    [contents removeObject:@".DS_Store"];
    [contents removeObject:@"Inbox"];
    return contents;
}

@end
