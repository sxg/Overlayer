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
@property (readwrite, strong, nonatomic) NSData *documentPDFData;

//  QLPreviewItem Protocol
@property (readwrite, strong, nonatomic) NSString *previewItemTitle;
@property (readwrite, strong, nonatomic) NSURL *previewItemURL;

@property (readwrite, assign, getter = isDrawingLines) BOOL drawingLines;
@property (readwrite, assign) CGFloat drawingLinesProgress;

@end

@implementation SGDocument

#pragma mark - Initialization

- (instancetype)initWithImages:(NSArray *)images title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.uuid = [[NSUUID alloc] init];
        self.title = title;
        self.documentPDFData = [self pdfDataFromImages:images];
        self.previewItemTitle = self.title;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        //  TODO
    }
    return self;
}

#pragma mark - Getters / Setters

- (void)setUrl:(NSURL *)url
{
    _url = url;
    self.previewItemURL = self.url;
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

- (NSData *)pdfDataFromImages:(NSArray *)images
{
    NSMutableData *pdfData = [NSMutableData data];
    
    CGSize pdfPageSize = ((UIImage *)images[0]).size;
    CGRect pdfPageRect = CGRectMake(0, 0, pdfPageSize.width, pdfPageSize.height);
    UIGraphicsBeginPDFContextToData(pdfData, pdfPageRect, nil);
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    for (UIImage *image in images) {
        UIGraphicsBeginPDFPage();
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView.layer renderInContext:pdfContext];
    }
    
    UIGraphicsEndPDFContext();
    return pdfData;
}

@end
