//
//  SGLineDrawing.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/26/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawingView.h"

@interface SGLineDrawing : NSObject

+ (DrawingView *)identifyCharactersOnImage:(UIImage *)image lineThickness:(float)lineThickness bytesPerPixel:(int)bytesPerPixel bitsPerComponent:(int)bitsPerComponent;

@end
