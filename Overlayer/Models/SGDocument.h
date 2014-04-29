//
//  SGDocument.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//


@interface SGDocument : NSObject <NSCoding>

@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic) UIImage *documentImage;
@property (readonly, strong, nonatomic) NSString *documentPDFPath;

@property (readonly, assign, getter = isDrawingLines) BOOL drawingLines;
@property (readonly, assign) CGFloat drawingLinesProgress;

+ (instancetype)createDocumentWithImage:(UIImage *)image title:(NSString *)title;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;
- (void)drawLinesCompletion:(void (^)(UIImage *imageWithLines, NSString *recognizedText, NSArray *recognizedCharacterRects))completion;
- (void)destroy;

@end
