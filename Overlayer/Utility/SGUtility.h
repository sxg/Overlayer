//
//  SGUtility.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/10/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//


@interface SGUtility : NSObject

+ (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToWidth:(CGFloat)width;
+ (UIImage *)imageOrientedUpFromImage:(UIImage *)image;

@end
