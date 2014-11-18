//
//  SGDocument.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import <QuickLook/QuickLook.h>


@interface SGDocument : NSObject <NSCoding, QLPreviewItem>

@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic) NSUUID *uuid;
@property (readonly, strong, nonatomic) NSData *documentPDFData;
@property (readwrite, strong, nonatomic) NSURL *url;

//  QLPreviewItem Protocol
@property (readonly, strong) NSString *previewItemTitle;
@property (readonly, strong) NSURL *previewItemURL;

@property (readonly, assign, getter = isDrawingLines) BOOL drawingLines;
@property (readonly, assign) CGFloat drawingLinesProgress;

- (instancetype)initWithImages:(NSArray *)images title:(NSString *)title;
- (instancetype)initWithURL:(NSURL *)url;
//- (void)drawLinesCompletion:(void (^)(UIImage *imageWithLines, NSString *recognizedText, NSDictionary *recognizedRects))completion;

@end
