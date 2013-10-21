//
//  Book.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGBook.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SGLineDrawing.h"

@interface SGBook()

@property (nonatomic, readwrite, strong) NSMutableArray *pages;

@end

@implementation SGBook

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _hasLinesDrawn = NO;
        _title = title;
        _pages = [[NSMutableArray alloc] init];
        
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *bookPath = [documentsDirectory stringByAppendingPathComponent:_title];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:bookPath]) {
            NSMutableArray *pageFileNames = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:bookPath error:nil] mutableCopy];
            
            //  Sort page numbers so that 10 doesn't come before 2
            NSSortDescriptor *numericalSort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedStandardCompare:)];
            [pageFileNames sortUsingDescriptors:[NSArray arrayWithObject:numericalSort]];
            
            for (NSString *pageFileName in pageFileNames) {
                NSString *pagePath = [bookPath stringByAppendingPathComponent:pageFileName];
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:pagePath];
                [_pages addObject:image];
            }
        }
        else {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:bookPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                NSLog(@"Failed to create book directory");
            }
        }
    }
    return self;
}

- (void)destroy
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *bookPath = [documentsDirectory stringByAppendingPathComponent:_title];
    [[NSFileManager defaultManager] removeItemAtPath:bookPath error:nil];
}

- (NSString *)savePath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentsDirectory stringByAppendingPathComponent:_title];
}

- (void)addPage:(UIImage *)image
{
    [_pages addObject:image];
    
    int numSavedImages = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self savePath] error:nil].count;
    NSString *imagePath = [[self savePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png", (numSavedImages+1)]];
    if (![UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES]) {
        NSLog(@"Failed to write image to disk");
    }
}

- (void)drawLines
{
    [[_pages copy] enumerateObjectsUsingBlock:^(UIImage *page, NSUInteger idx, BOOL *stop) {
        page = [SGLineDrawing identifyCharactersOnImage:page lineThickness:1.5f];
        _pages[idx] = page;
        NSString *path = [[self savePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png", (idx+1)]];
        if (![UIImagePNGRepresentation(page) writeToFile:path atomically:YES]) {
            NSLog(@"Failed to save image");
        }
    }];
}

@end
