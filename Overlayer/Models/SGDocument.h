//
//  SGDocument.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//


@interface SGDocument : NSObject <NSCoding>

@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic) NSUUID *uuid;
@property (readonly, strong, nonatomic) NSData *documentPDFData;

@property (readonly, assign, getter = isDrawingLines) BOOL drawingLines;
@property (readonly, assign) CGFloat drawingLinesProgress;

- (instancetype)initWithImages:(NSArray *)images title:(NSString *)title;
//- (void)drawLinesCompletion:(void (^)(UIImage *imageWithLines, NSString *recognizedText, NSDictionary *recognizedRects))completion;

@end
