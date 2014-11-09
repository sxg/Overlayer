//
//  SGDocument.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGDocument.h"

//  Frameworks
#import <StandardPaths/StandardPaths.h>

//  Utilities
#import "SGTextRecognizer.h"
#import "SGDocumentManager.h"
#import "SGUtility.h"


@interface SGDocument ()

@property (readwrite, strong, nonatomic) NSString *title;
@property (readwrite, strong, nonatomic) NSUUID *uuid;

@property (readwrite, assign, getter = isDrawingLines) BOOL drawingLines;
@property (readwrite, assign) CGFloat drawingLinesProgress;

@end

@implementation SGDocument

- (instancetype)initWithImages:(NSArray *)images title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.uuid = [[NSUUID alloc] init];
        self.title = title;
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
}

#pragma mark - Helpers

/*- (void)generatePDF
{
    NSMutableData *pdfData = [NSMutableData data];
    
    CGSize pdfPageSize = self.image.size;
    CGRect pdfPageRect = CGRectMake(0, 0, pdfPageSize.width, pdfPageSize.height);
    UIGraphicsBeginPDFContextToData(pdfData, pdfPageRect, nil);
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    UIGraphicsBeginPDFPage();
        
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    [imageView.layer renderInContext:pdfContext];
    
    UIGraphicsEndPDFContext();
    
    NSString *pdfFileName = [self.title stringByAppendingPathExtension:@"pdf"];
    NSString *pdfPath = [[NSFileManager defaultManager] pathForPublicFile:pdfFileName];
    if (![pdfData writeToFile:pdfPath atomically:YES]) {
        NSLog(@"Failed to write PDF file to disk");
    }
}*/

@end
