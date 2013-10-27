//
//  Collection.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

@import QuartzCore;
@import CoreGraphics;

#import "SGCollection.h"
#import "SGLineDrawing.h"
#import "UIImage+Transform.h"

@interface SGCollection()

@property (nonatomic, readwrite, strong) NSMutableArray *documents;

@end

@implementation SGCollection

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
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

- (void)deleteCollection
{
    [[NSFileManager defaultManager] removeItemAtPath:[self savePath] error:nil];
}

- (NSString *)savePath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentsDirectory stringByAppendingPathComponent:_title];
}

- (NSString *)pdfPath
{
    return [self hasPDF] ? [[self savePath] stringByAppendingPathComponent:@"PDF.pdf"] : nil;
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

- (void)deleteDocumentWithTitle:(NSString *)documentTitle
{
    for (SGDocument *document in [_documents copy]) {
        if ([document.title isEqualToString:documentTitle]) {
            [_documents removeObject:document];
            NSString *documentPath = [[[self savePath] stringByAppendingPathComponent:documentTitle] stringByAppendingPathExtension:@"png"];
            [[NSFileManager defaultManager] removeItemAtPath:documentPath error:nil];
        }
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
        //  Ignore PDF files
        if (![[documentFileName pathExtension] isEqualToString:@"pdf"]) {
            NSString *documentPath = [[self savePath] stringByAppendingPathComponent:documentFileName];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:documentPath];
            SGDocument *document = [[SGDocument alloc] initWithImage:image title:[documentFileName stringByDeletingPathExtension]];
            [_documents addObject:document];
        }
    }
}

- (void)drawLinesWithLineWidth:(CGFloat)lineWidth
{
    [[_documents copy] enumerateObjectsUsingBlock:^(SGDocument *document, NSUInteger idx, BOOL *stop) {
        [document drawLinesWithLineWidth:lineWidth];
        NSString *path = [[self savePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", document.title]];
        if (![UIImagePNGRepresentation(document.image) writeToFile:path atomically:YES]) {
            NSLog(@"Failed to save image");
        }
    }];
    
    if ([self hasPDF]) {
        NSString *pdfPath = [[self savePath] stringByAppendingPathComponent:@"PDF.pdf"];
        [[NSFileManager defaultManager] removeItemAtPath:pdfPath error:nil];
    }
}

- (void)createPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    
    CGSize pdfPageSize = ((SGDocument *)_documents[0]).image.size;
    CGRect pdfPageRect = CGRectMake(0, 0, pdfPageSize.width, pdfPageSize.height);
    UIGraphicsBeginPDFContextToData(pdfData, pdfPageRect, nil);
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    for (SGDocument *document in _documents) {
        UIGraphicsBeginPDFPage();
        
        UIImageView *documentImageView = [[UIImageView alloc] initWithImage:document.image];
        [documentImageView.layer renderInContext:pdfContext];
    }
    UIGraphicsEndPDFContext();
    
    NSString *pdfPath = [[self savePath] stringByAppendingPathComponent:@"PDF.pdf"];
    [pdfData writeToFile:pdfPath atomically:YES];
}

- (BOOL)hasPDF
{
    NSString *pdfPath = [[self savePath] stringByAppendingPathComponent:@"PDF.pdf"];
    return [[NSFileManager defaultManager] fileExistsAtPath:pdfPath];
}

@end
