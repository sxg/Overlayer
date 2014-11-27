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

@end

@implementation SGDocumentManager

+ (void)saveDocument:(SGDocument *)document atURL:(NSURL *)url
{
    //  Create the document directory
    NSError *err;
    [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&err];
    if (err) {
        NSLog(@"Failed to create directory at URL: %@ error: %@", url, err);
        
        //  Write the document PDF data
        NSURL *documentPDFDataURL = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", document.title]];
        if (![document.pdfData writeToFile:[documentPDFDataURL absoluteString] atomically:YES]) {
            NSLog(@"Failed to save document: %@ to URL: %@", document, documentPDFDataURL);
            
            //  Write the archive
            NSURL *archiveURL = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive", document.title]];
            [NSKeyedArchiver archiveRootObject:document toFile:[archiveURL absoluteString]];
            
            //  Set the document's URL
            document.url = url;
        }
    }
}

+ (void)destroyDocumentAtURL:(NSURL *)url completion:(void (^)(BOOL))completion
{
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtURL:url error:&err];
    if (err) {
        NSLog(@"Failed to destroy document at URL: %@ error: %@", url, err);
    }
}

+ (void)moveDocumentFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL
{
    
}

+ (NSArray *)documentsAtURL:(NSURL *)url
{
    NSError *err;
    NSArray *documentNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[url absoluteString] error:&err];
    if (err) {
        NSLog(@"%@", err);
    }
    return documentNames;
}

@end
