//
//  UIImage+LineDrawer.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/25/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Character.h"
#import "DrawingView.h"
#import <UIKit/UIKit.h>

@interface UIImage (LineDrawer)

- (UIImage*)makeBlackAndWhiteWithbytesPerPixel:(int)bytesPerPixel bitsPerComponent:(int)bitsPerComponent;
- (DrawingView*)identifyCharactersWithlineThickness:(int)lineThickness onView:(DrawingView*)view bytesPerPixel:(int)bytesPerPixel bitsPerComponent:(int)bitsPerComponent;
- (UIImage*)rotateToOrientation:(UIImageOrientation)orientation;
- (UIImage*)imageScaledToSize:(CGSize)newSize;

@end
