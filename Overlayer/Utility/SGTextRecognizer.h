//
//  SGTextRecognizer.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/9/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//


@interface SGTextRecognizer : NSObject <NSURLSessionTaskDelegate>

+ (void)recognizeTextOnImages:(NSArray *)images completion:(void (^)(NSData *pdfWithRecognizedText, NSArray *recognizedText, NSArray *recognizedRects))completion;

@end
