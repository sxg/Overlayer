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
        
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *collectionPath = [documentsDirectory stringByAppendingPathComponent:_title];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:collectionPath]) {
            NSMutableArray *documentFileNames = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:collectionPath error:nil] mutableCopy];
            
            //  Sort document numbers so that 10 doesn't come before 2
            NSSortDescriptor *numericalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedStandardCompare:)];
            [documentFileNames sortUsingDescriptors:[NSArray arrayWithObject:numericalSort]];
            
            for (NSString *documentFileName in documentFileNames) {
                NSString *documentPath = [collectionPath stringByAppendingPathComponent:documentFileName];
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:documentPath];
                [_documents addObject:image];
            }
        }
        else {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:collectionPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                NSLog(@"Failed to create collection directory");
            }
        }
    }
    return self;
}

- (void)destroy
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *collectionPath = [documentsDirectory stringByAppendingPathComponent:_title];
    [[NSFileManager defaultManager] removeItemAtPath:collectionPath error:nil];
}

- (NSString *)savePath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentsDirectory stringByAppendingPathComponent:_title];
}

- (void)addDocumentImage:(UIImage *)documentImage
{
    [_documents addObject:documentImage];
    
    int numSavedImages = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self savePath] error:nil].count;
    NSString *imagePath = [[self savePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png", (numSavedImages+1)]];
    if (![UIImagePNGRepresentation(documentImage) writeToFile:imagePath atomically:YES]) {
        NSLog(@"Failed to write image to disk");
    }
}

- (void)drawLines
{
    [[_documents copy] enumerateObjectsUsingBlock:^(UIImage *document, NSUInteger idx, BOOL *stop) {
        document = [SGLineDrawing identifyCharactersOnImage:document lineThickness:1.5f];
        _documents[idx] = document;
        NSString *path = [[self savePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png", (idx+1)]];
        if (![UIImagePNGRepresentation(document) writeToFile:path atomically:YES]) {
            NSLog(@"Failed to save image");
        }
    }];
}

@end
