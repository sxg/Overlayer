//
//  UIImage+Rotate.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/26/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "UIImage+Transform.h"

@implementation UIImage (Rotate)

static inline double radians (double degrees) {return degrees * M_PI/180;}
+ (UIImage *)imageWithImage:(UIImage *)image rotatedToOrientation:(UIImageOrientation)orientation
{
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(180));
        CGContextTranslateCTM(context, -image.size.width, -image.size.height);
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
        CGContextTranslateCTM(context, -image.size.width, 0);
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
        CGContextTranslateCTM(context, 0, -image.size.height);
    }
    
    [image drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
