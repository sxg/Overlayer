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

@interface SGBook()

@property (nonatomic, readwrite, strong) NSMutableArray *pages;

@end

@implementation SGBook

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _title = title;
        _pages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)savePath
{
    //  Save path is ".../Documents/Book Title.pdf"
    NSString *fileName = [_title stringByAppendingString:@".pdf"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}


- (void)addPage:(UIImageView *)imageView
{
    //  Convert new image to PDF data
    NSMutableData *newPDFData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData(newPDFData, imageView.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    [imageView.layer renderInContext:pdfContext];
    UIGraphicsEndPDFContext();
    
    //  Convert the new PDF data to a CGPDFDocumentRef
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)newPDFData);
    CGPDFDocumentRef newPDFDocument = CGPDFDocumentCreateWithProvider(provider);
    
    //  Get the CGContextRef for the existing PDF
    CFURLRef pdfURL = (__bridge CFURLRef)[NSURL fileURLWithPath:[self savePath]];
    CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURL, nil, nil);
    
    if (newPDFDocument) {
        CGPDFPageRef newPDFPage = CGPDFDocumentGetPage(newPDFDocument, 1);
        if (newPDFPage) {
            CGRect pdfCropBoxRect = CGPDFPageGetBoxRect(newPDFPage, kCGPDFMediaBox);
            
            CGContextBeginPage(writeContext, &pdfCropBoxRect);
            CGContextDrawPDFPage(writeContext, newPDFPage);
        }
    }
    
    CGPDFDocumentRelease(newPDFDocument);
    CGDataProviderRelease(provider);
    
    [newPDFData writeToFile:[self savePath] atomically:YES];
}

@end
