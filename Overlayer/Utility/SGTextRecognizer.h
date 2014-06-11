//
//  SGTextRecognizer.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/9/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//


@interface SGTextRecognizer : NSObject <NSURLSessionTaskDelegate>

+ (SGTextRecognizer *)sharedClient;

- (void)recognizeTextOnImage:(UIImage *)image completion:(void (^)(UIImage *imageWithLines, NSString *recognizedText, NSDictionary *recognizedRects))completion;

@end
