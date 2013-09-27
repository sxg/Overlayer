//
//  UIImage+Rotate.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/26/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "UIImage+Rotate.h"

@implementation UIImage (Rotate)

static inline double radians (double degrees) {return degrees * M_PI/180;}
- (UIImage *)rotateToOrientation:(UIImageOrientation)orientation
{
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationUp)
    {
        CGContextRotateCTM (context, radians(180));
        CGContextTranslateCTM(context, -self.size.width, -self.size.height);
    }
    else if (orientation == UIImageOrientationLeft)
    {
        CGContextRotateCTM (context, radians(-90));
        CGContextTranslateCTM(context, -self.size.width, 0);
    }
    else if (orientation == UIImageOrientationDown)
    {
        // NOTHING
    }
    else if (orientation == UIImageOrientationRight)
    {
        CGContextRotateCTM (context, radians(90));
        CGContextTranslateCTM(context, 0, -self.size.height);
    }
    
    [self drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

@end
