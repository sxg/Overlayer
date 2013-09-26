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
        
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *bookPath = [documentsDirectory stringByAppendingPathComponent:_title];
        if (![[NSFileManager defaultManager] createDirectoryAtPath:bookPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"Failed to create book directory");
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
    [(NSMutableArray *)_pages addObject:image];
    
    int numSavedImages = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self savePath] error:nil].count;
    NSString *imagePath = [[self savePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png", (numSavedImages+1)]];
    if (![UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES]) {
        NSLog(@"Failed to write image to disk");
    }
}

//- (NSString *)savePath
//{
//    //  Save path is ".../Documents/Book Title.pdf"
//    NSString *fileName = [_title stringByAppendingString:@".pdf"];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    
//    return [documentsDirectory stringByAppendingPathComponent:fileName];
//}


//- (void)addPage:(UIImageView *)imageView
//{
//    //  Convert new image to PDF data
//    NSMutableData *newPDFData = [NSMutableData data];
//    
//    UIGraphicsBeginPDFContextToData(newPDFData, imageView.bounds, nil);
//    UIGraphicsBeginPDFPage();
//    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
//    [imageView.layer renderInContext:pdfContext];
//    UIGraphicsEndPDFContext();
//    
//    //  Convert the new PDF data to a CGPDFDocumentRef
//    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)newPDFData);
//    CGPDFDocumentRef newPDFDocument = CGPDFDocumentCreateWithProvider(provider);
//    
//    //  Get the CGContextRef for the existing PDF
//    CFURLRef pdfURL = (__bridge CFURLRef)[NSURL fileURLWithPath:[self savePath]];
//    CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURL, nil, nil);
//    
//    if (newPDFDocument) {
//        CGPDFPageRef newPDFPage = CGPDFDocumentGetPage(newPDFDocument, 1);
//        if (newPDFPage) {
//            CGRect pdfCropBoxRect = CGPDFPageGetBoxRect(newPDFPage, kCGPDFMediaBox);
//            
//            CGContextBeginPage(writeContext, &pdfCropBoxRect);
//            CGContextDrawPDFPage(writeContext, newPDFPage);
//        }
//    }
//    
//    CGPDFDocumentRelease(newPDFDocument);
//    CGDataProviderRelease(provider);
//    
//    [newPDFData writeToFile:[self savePath] atomically:YES];
//}

@end
