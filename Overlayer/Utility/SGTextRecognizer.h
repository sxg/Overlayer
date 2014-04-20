//
//  SGTextRecognizer.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/9/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

//  Frameworks
#import <TesseractOCR/TesseractOCR.h>


@interface SGTextRecognizer : NSObject <TesseractDelegate>

+ (SGTextRecognizer *)sharedClient;

- (void)recognizeTextOnImage:(UIImage *)image update:(void (^)(CGFloat progress))update completion:(void (^)(NSString *recognizedText, NSArray *recognizedCharacterRects))completion;

@end
