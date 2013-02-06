//
//  UIImage+LineDrawer.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/25/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Character.h"
#import "DrawingView.h"
#import "UIImage+LineDrawer.h"

@implementation UIImage (LineDrawer)

- (int)otsusMethod:(int*)histogram size:(int)numPixels
{
    float maxVar = 0;
    int threshold = 0;
    
    for (int t = 0; t < 256; t++)
    {
        float wb, wf, mub, muf;
        float sumb = 0;
        float sumf = 0;
        float weightedSumb = 0;
        float weightedSumf = 0;
        
        for (int b = 0; b < t; b++)
        {
            //sumb += [[histogram objectAtIndex:b] intValue];
            sumb += histogram[b];
            //weightedSumb += b * [[histogram objectAtIndex:b] intValue];
            weightedSumb += b * histogram[b];
        }
        wb = sumb / numPixels;
        mub = weightedSumb / sumb;
        
        for (int f = t; f < 256; f++)
        {
            //sumf += [[histogram objectAtIndex:f] intValue];
            sumf += histogram[f];
            //weightedSumf += f * [[histogram objectAtIndex:f] intValue];
            weightedSumf += f * histogram[f];
        }
        wf = sumf / numPixels;
        muf = weightedSumf / sumf;
        
        float var = wb * wf * (mub - muf) * (mub - muf);
        if (var > maxVar)
        {
            maxVar = var;
            threshold = t;
        }
    }
    
    return threshold;
}

// updated version of the black and white algorithm that takes into account adjacent pixels (original version is commented out above)
- (UIImage*)makeBlackAndWhiteWithbytesPerPixel:(int)bytesPerPixel bitsPerComponent:(int)bitsPerComponent
{
    UIImage *temp = [self rotateToOrientation:UIImageOrientationDown];
    CGImageRef imageRef = [temp CGImage];
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB(); //maybe make ...Gray();
    int size = CGImageGetHeight(imageRef) * CGImageGetWidth(imageRef) * 4;
    unsigned char *rawData = (unsigned char*) calloc(size, sizeof(unsigned char));
    CGContextRef context = CGBitmapContextCreate(rawData, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), bitsPerComponent, bytesPerPixel * CGImageGetWidth(imageRef), colorSpaceRef, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
    
    int bytesPerRow = bytesPerPixel * self.size.width;
    
    const int RED = 0;
    const int GREEN = 1;
    const int BLUE = 2;
    const int NORTH = -1 * bytesPerRow;
    const int WEST = -1 * bytesPerPixel;
    const int EAST = bytesPerPixel;
    const int SOUTH = bytesPerRow;
    const float BLACK_PIXEL = 0.0;
    const float WHITE_PIXEL = 255.0;
    
    //thresholds for considering the relative whiteness of two adjacent pixels; if the relative ratio is within the range, then the two pixels are considered to be the same relative level of white
    const float LOWER_THRESHOLD = 0.85;
    const float UPPER_THRESHOLD = 1.15;
    
    //NSMutableArray *histogram = [[NSMutableArray alloc] initWithCapacity:256];
    int *histogram = (int*) calloc(256, sizeof(int));
    for (int i = 0; i < 256; i++)
    {
        //[histogram addObject:[[NSNumber alloc] initWithInt:0]];
        histogram[i] = 0;
    }
    
    //duplicate the data to preserve the original...
    unsigned char *rawDataCopy = (unsigned char*) calloc(size, sizeof(unsigned char));
    for (int i = 0; i < size; i ++)
    {
        rawDataCopy[i] = rawData[i];
    }
    
    for (int y = 0; y < CGImageGetHeight(imageRef); y++)
    {
        for (int x = 0; x < CGImageGetWidth(imageRef); x++)
        {
            int byteIndex = (bytesPerRow * y) + (x * bytesPerPixel);
            int grayPixel = 0.3 * rawDataCopy[byteIndex + RED] + 0.59 * rawDataCopy[byteIndex + BLUE] + 0.11 * rawDataCopy[byteIndex + GREEN];
            
            //[histogram insertObject:([[NSNumber alloc] initWithInt:[[histogram objectAtIndex:grayPixel] intValue] + 1]) atIndex:grayPixel];
            histogram[grayPixel]++;
        }
    }
    
    const int THRESHOLD = [self otsusMethod:histogram size:(CGImageGetWidth(imageRef) * CGImageGetHeight(imageRef))];
    
    for (int y = 0; y < CGImageGetHeight(imageRef); y++)
    {
        for (int x = 0; x < CGImageGetWidth(imageRef); x++)
        {
            int byteIndex = (bytesPerRow * y) + (x * bytesPerPixel);
            CGFloat grayPixel = 0.3 * rawDataCopy[byteIndex + RED] + 0.59 * rawDataCopy[byteIndex + BLUE] + 0.11 * rawDataCopy[byteIndex + GREEN];
            
            if (byteIndex + NORTH + WEST >= 0 && byteIndex + SOUTH + EAST + bytesPerPixel < size)
            {
                if (grayPixel >= THRESHOLD) {
                    CGFloat grayNorth = 0.3 * rawDataCopy[byteIndex + NORTH + RED] + 0.59 * rawDataCopy[byteIndex + NORTH + BLUE] + 0.11 * rawDataCopy[byteIndex + NORTH + GREEN];
                    CGFloat grayWest = 0.3 * rawDataCopy[byteIndex + WEST + RED] + 0.59 * rawDataCopy[byteIndex + WEST + BLUE] + 0.11 * rawDataCopy[byteIndex + WEST + GREEN];
                    CGFloat grayEast = 0.3 * rawDataCopy[byteIndex + EAST + RED] + 0.59 * rawDataCopy[byteIndex + EAST + BLUE] + 0.11 * rawDataCopy[byteIndex + EAST + GREEN];
                    CGFloat graySouth = 0.3 * rawDataCopy[byteIndex + SOUTH + RED] + 0.59 * rawDataCopy[byteIndex + SOUTH + BLUE] + 0.11 * rawDataCopy[byteIndex + SOUTH + GREEN];
                    
                    CGFloat relativeNorth = grayNorth / grayPixel;
                    CGFloat relativeWest = grayWest / grayPixel;
                    CGFloat relativeEast = grayEast / grayPixel;
                    CGFloat relativeSouth = graySouth / grayPixel;
                    
                    if (relativeNorth > LOWER_THRESHOLD && relativeNorth < UPPER_THRESHOLD && relativeWest > LOWER_THRESHOLD && relativeWest < UPPER_THRESHOLD && relativeEast > LOWER_THRESHOLD && relativeEast < UPPER_THRESHOLD && relativeSouth > LOWER_THRESHOLD && relativeSouth < UPPER_THRESHOLD)
                    {
                        rawData[byteIndex + RED] = WHITE_PIXEL;
                        rawData[byteIndex + GREEN] = WHITE_PIXEL;
                        rawData[byteIndex + BLUE] = WHITE_PIXEL;
                    }
                    else
                    {
                        rawData[byteIndex + RED] = BLACK_PIXEL;
                        rawData[byteIndex + GREEN] = BLACK_PIXEL;
                        rawData[byteIndex + BLUE] = BLACK_PIXEL;
                    }
                }
                else if (grayPixel < THRESHOLD) {
                    rawData[byteIndex + RED] = BLACK_PIXEL;
                    rawData[byteIndex + GREEN] = BLACK_PIXEL;
                    rawData[byteIndex + BLUE] = BLACK_PIXEL;
                }
            }
        }
    }
    
    //draw the new image...
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpaceRef);
    free(rawData);
    
    UIImage *newImage = [UIImage imageWithCGImage:newCGImage];
    
    return newImage;
}

- (DrawingView*)identifyCharactersWithlineThickness:(int)lineThickness onView:(DrawingView*)view bytesPerPixel:(int)bytesPerPixel bitsPerComponent:(int)bitsPerComponent
{
    int bytesPerRow = bytesPerPixel * self.size.width;
    UIImage *blackAndWhiteImage = [self makeBlackAndWhiteWithbytesPerPixel:bytesPerPixel bitsPerComponent:bitsPerComponent];
    //blackAndWhiteImage = [self rotate:blackAndWhiteImage :UIImageOrientationRight];
    
    CGImageRef imageRef = blackAndWhiteImage.CGImage;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB(); //maybe make ...Gray();
    unsigned char *rawData = (unsigned char*) calloc(CGImageGetHeight(imageRef) * CGImageGetWidth(imageRef) * 4, sizeof(unsigned char));
    CGContextRef context = CGBitmapContextCreate(rawData, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), bitsPerComponent, bytesPerPixel * CGImageGetWidth(imageRef), colorSpaceRef, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
    
    
    const int LOWER_THRESHOLD = 20; //minimum number of adjacent black pixels that will define a character
    //const int UPPER_THRESHOLD = 1500; //maximum number of adjacent black pixels that will define a character
    
    //array of characters, which are arrays of pixel byte indexes
    NSMutableArray *characters = [[NSMutableArray alloc] init];
    
    for (int y = 0; y < CGImageGetHeight(imageRef); y++)
    {
        for (int x = 0; x < CGImageGetWidth(imageRef); x++)
        {
            int byteIndex = (bytesPerRow * y) + (x * bytesPerPixel);
            
            if (rawData[byteIndex] == 0.0)
            {
                Character *c = [self floodFill:rawData x:x y:y height:CGImageGetHeight(imageRef) width:CGImageGetWidth(imageRef) bytesPerPixel:bytesPerPixel bytesPerRow:bytesPerRow];
                if ([[c points] count] > LOWER_THRESHOLD)// && [tempArray count] < UPPER_THRESHOLD)
                {
                    [characters addObject:c];
                }
            }
            
        }
    }
    
    return [self drawCharacterLines:characters onView:view lineThickness:lineThickness bytesPerPixel:bytesPerPixel bitsPerComponent:bitsPerComponent];
}

- (DrawingView*)drawCharacterLines:(NSMutableArray*)characters onView:(DrawingView*)view lineThickness:(int)lineThickness bytesPerPixel:(int)bytesPerPixel bitsPerComponent:(int)bitsPerComponent
{
    for (int i = 0; i < [characters count]; i++)
    {
        Character *currentCharacter = [characters objectAtIndex:i];
        int roughStdDev = (currentCharacter.bottomY - currentCharacter.topY) / 8;
        UIBezierPath *path = [view path];
        [path setLineWidth:lineThickness];
        const int THRESHOLD_WIDTH = 25;
        NSArray *avgYValues;
        NSArray *xSplitPoints;
        int width = currentCharacter.rightX - currentCharacter.leftX;
        if (width > THRESHOLD_WIDTH)
        {
            avgYValues = [currentCharacter averageYValuesSplitCharacterInto:3];
            xSplitPoints = [currentCharacter xSplitPoints:3];
        }
        else
        {
            avgYValues = [currentCharacter averageYValuesSplitCharacterInto:2];
        }
        
        int y2 = [[avgYValues objectAtIndex:([avgYValues count] - 1)] intValue];
        int y1 = [[avgYValues objectAtIndex:0] intValue];
        int x2 = [currentCharacter rightX];
        int x1 = [currentCharacter leftX];
        float slope = (y2 - y1) / (x2 - x1);
        
        if (slope < 10 && slope > -10) {
            if (width > THRESHOLD_WIDTH)
            {
                [path moveToPoint:CGPointMake([[xSplitPoints objectAtIndex:0] intValue], [[avgYValues objectAtIndex:0] intValue] - roughStdDev)];
                [path addLineToPoint:CGPointMake([[xSplitPoints objectAtIndex:2] intValue], [[avgYValues objectAtIndex:1] intValue] - roughStdDev)];
                [path addLineToPoint:CGPointMake([[xSplitPoints objectAtIndex:4] intValue], [[avgYValues objectAtIndex:2] intValue] - roughStdDev)];
                
                [path moveToPoint:CGPointMake([[xSplitPoints objectAtIndex:0] intValue], [[avgYValues objectAtIndex:0] intValue] + roughStdDev)];
                [path addLineToPoint:CGPointMake([[xSplitPoints objectAtIndex:2] intValue], [[avgYValues objectAtIndex:1] intValue] + roughStdDev)];
                [path addLineToPoint:CGPointMake([[xSplitPoints objectAtIndex:4] intValue], [[avgYValues objectAtIndex:2] intValue] + roughStdDev)];
                [view setNeedsDisplay];
            }
            else
            {
                [path moveToPoint:CGPointMake(currentCharacter.leftX, [[avgYValues objectAtIndex:0] intValue] - roughStdDev)];
                [path addLineToPoint:CGPointMake(currentCharacter.rightX, [[avgYValues objectAtIndex:1] intValue] - roughStdDev)];
                
                [path moveToPoint:CGPointMake(currentCharacter.leftX, [[avgYValues objectAtIndex:0] intValue] + roughStdDev)];
                [path addLineToPoint:CGPointMake(currentCharacter.rightX, [[avgYValues objectAtIndex:1] intValue] + roughStdDev)];
                [view setNeedsDisplay];
            }
        }
    }
    
    return view;
}

- (Character*)floodFill:(unsigned char *)rawData x:(int)x y:(int)y height:(int)height width:(int)width bytesPerPixel:(int)bytesPerPixel bytesPerRow:(int)bytesPerRow
{
    //arrays of CGPoints...
    NSMutableArray *examList = [[NSMutableArray alloc] init];
    NSMutableArray *allPoints = [[NSMutableArray alloc] init];
    
    const int UPPER_THRESHOLD = 2500;
    
    CGPoint start = CGPointMake(x, y);
    [examList addObject:[NSValue valueWithCGPoint:start]];
    [allPoints addObject:[NSValue valueWithCGPoint:start]];
    
    while ([examList count] != 0)
    {
        
        CGPoint point = [[examList objectAtIndex:0] CGPointValue];
        int p = (bytesPerRow * point.y) + (point.x * bytesPerPixel);
        [examList removeObjectAtIndex:0];
        
        if ([allPoints count] < UPPER_THRESHOLD && (p >= 0 && p < (bytesPerRow * (height - 1)) + ((width - 1) * bytesPerPixel) && rawData[p] == 0.0))  //if the point is black and there are fewer than UPPER_THRESHOLD pixels
        {
            //add this point to list of all black points...
            [allPoints addObject:[NSValue valueWithCGPoint:point]];
            
            //change the color from black to whatever this is...
            rawData[p] = 255.0;
            
            //get and add adjacent pixels to the exam list...
            CGPoint west = CGPointMake(point.x - 1, point.y);
            CGPoint north = CGPointMake(point.x, point.y - 1);
            CGPoint east = CGPointMake(point.x + 1, point.y);
            CGPoint south = CGPointMake(point.x, point.y + 1);
            [examList addObject:[NSValue valueWithCGPoint:west]];
            [examList addObject:[NSValue valueWithCGPoint:north]];
            [examList addObject:[NSValue valueWithCGPoint:east]];
            [examList addObject:[NSValue valueWithCGPoint:south]];
        }
    }
    
    //return array of byte indices of adjacent black pixels including the one given at pixel location x, y
    Character *c = [[Character alloc] initWithPoints:allPoints];
    return c;
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
- (UIImage*)rotateToOrientation:(UIImageOrientation)orientation
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

- (UIImage *)imageScaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
