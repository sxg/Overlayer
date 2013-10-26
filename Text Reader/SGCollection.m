//
//  Collection.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGCollection.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SGLineDrawing.h"

@interface SGCollection()

@property (nonatomic, readwrite, strong) NSMutableArray *documents;

@end

@implementation SGCollection

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _hasLinesDrawn = NO;
        _title = title;
        _documents = [[NSMutableArray alloc] init];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self savePath]]) {
            [self reloadData];
        }
        else {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:[self savePath] withIntermediateDirectories:YES attributes:nil error:nil]) {
                NSLog(@"Failed to create collection directory");
            }
        }
    }
    return self;
}

- (void)destroy
{
    [[NSFileManager defaultManager] removeItemAtPath:[self savePath] error:nil];
}

- (NSString *)savePath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentsDirectory stringByAppendingPathComponent:_title];
}

- (void)addDocument:(SGDocument *)document
{
    [_documents addObject:document];
    
    NSString *imagePath = [[self savePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", (document.title)]];
    if (![UIImagePNGRepresentation(document.image) writeToFile:imagePath atomically:YES]) {
        NSLog(@"Failed to write image to disk");
    }
    
    [self reloadData];
}

- (void)reloadData
{
    NSMutableArray *documentFileNames = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self savePath] error:nil] mutableCopy];
    
    //  Sort document numbers so that 10 doesn't come before 2
    NSSortDescriptor *numericalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedStandardCompare:)];
    [documentFileNames sortUsingDescriptors:[NSArray arrayWithObject:numericalSort]];
    
    [_documents removeAllObjects];
    for (NSString *documentFileName in documentFileNames) {
        NSString *documentPath = [[self savePath] stringByAppendingPathComponent:documentFileName];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:documentPath];
        SGDocument *document = [[SGDocument alloc] initWithImage:image title:[documentFileName stringByDeletingPathExtension]];
        [_documents addObject:document];
    }
}

- (void)drawLines
{
    [[_documents copy] enumerateObjectsUsingBlock:^(SGDocument *document, NSUInteger idx, BOOL *stop) {
        [document drawLines];
        NSString *path = [[self savePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", document.title]];
        if (![UIImagePNGRepresentation(document.image) writeToFile:path atomically:YES]) {
            NSLog(@"Failed to save image");
        }
    }];
}

@end
