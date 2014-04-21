//
//  SGUtility.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/10/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGUtility.h"


@implementation SGUtility

+ (UIImage *)imageWithImage:(UIImage *)image scaledByFactor:(CGFloat)scalingFactor
{
    CGSize newSize = CGSizeMake(image.size.width*scalingFactor, image.size.height*scalingFactor);
    
    //  UIGraphicsBeginImageContext(newSize);
    //  In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    //  Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageOrientedUpFromImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(image.size);
    [image drawAtPoint:CGPointZero];
    return UIGraphicsGetImageFromCurrentImageContext();
}

@end
