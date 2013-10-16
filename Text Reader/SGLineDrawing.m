//
//  SGLineDrawing.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/26/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGLineDrawing.h"
#import "UIImage+Rotate.h"
#import "Character.h"
#import <GPUImage/GPUImage.h>

@implementation SGLineDrawing

+ (DrawingView *)identifyCharactersOnImage:(UIImage *)image lineThickness:(float)lineThickness bytesPerPixel:(int)bytesPerPixel bitsPerComponent:(int)bitsPerComponent
{
    int bytesPerRow = bytesPerPixel * image.size.width;
    
    GPUImageAdaptiveThresholdFilter *adaptiveFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    UIImage *blackAndWhiteImage = [adaptiveFilter imageByFilteringImage:image];
    
    CGImageRef imageRef = blackAndWhiteImage.CGImage;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(CGImageGetHeight(imageRef) * CGImageGetWidth(imageRef) * 4, sizeof(unsigned char));
    CGContextRef context = CGBitmapContextCreate(rawData, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), bitsPerComponent, bytesPerPixel * CGImageGetWidth(imageRef), colorSpaceRef, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
    
    
    const int LOWER_THRESHOLD = 20; //minimum number of adjacent black pixels that will define a character
    const int UPPER_THRESHOLD = 7000; //maximum number of adjacent black pixels that will define a character
    
    //array of characters, which are arrays of pixel byte indexes
    NSMutableArray *characters = [[NSMutableArray alloc] init];
    
    for (int y = 0; y < CGImageGetHeight(imageRef); y++) {
        for (int x = 0; x < CGImageGetWidth(imageRef); x++) {
            int byteIndex = (bytesPerRow * y) + (x * bytesPerPixel);
            if (rawData[byteIndex] == 0.0) {
                Character *c = [self floodFill:rawData x:x y:y height:CGImageGetHeight(imageRef) width:CGImageGetWidth(imageRef) bytesPerPixel:bytesPerPixel bytesPerRow:bytesPerRow];
                if ([[c points] count] > LOWER_THRESHOLD && [[c points] count] < UPPER_THRESHOLD) {
                    [characters addObject:c];
                }
            }
            
        }
    }
    
    CGContextRelease(context);
    
    return [self drawLinesOnImage:image characters:characters lineThickness:lineThickness bytesPerPixel:bytesPerPixel bitsPerComponent:bitsPerComponent];
}

+ (DrawingView *)drawLinesOnImage:(UIImage *)image characters:(NSMutableArray *)characters lineThickness:(float)lineThickness bytesPerPixel:(int)bytesPerPixel bitsPerComponent:(int)bitsPerComponent
{
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    DrawingView *view = [[DrawingView alloc] initWithFrame:frame];
    
    //  Iterate through every "cluster" of black pixels
    for (int i = 0; i < [characters count]; i++)
    {
        Character *currentCharacter = [characters objectAtIndex:i];
        UIBezierPath *path = [view path];
        [path setLineWidth:lineThickness];
        NSArray *avgYValues;
        NSArray *xSplitPoints;
        int offset = sqrt((currentCharacter.bottomY - currentCharacter.topY));// roughStdDev * 2;
        
        //  Split words greater than the threshold into three parts, and split smaller words into two parts
        const int THRESHOLD_WIDTH = 25;
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
        
        //  Calculate the slope of the line to be drawn
        int y2 = [[avgYValues objectAtIndex:([avgYValues count] - 1)] intValue];
        int y1 = [[avgYValues objectAtIndex:0] intValue];
        int x2 = [currentCharacter rightX];
        int x1 = [currentCharacter leftX];
        float slope = (y2 - y1) / (x2 - x1);
        
        //  Ignore lines that have a slope greater than 10 or less than -10 since they probably aren't words, and draw the lines based on the width of the word as described earlier.
        if (slope < 10 && slope > -10) {
            if (width > THRESHOLD_WIDTH)
            {
                //  Draw the top line
                [path moveToPoint:CGPointMake([[xSplitPoints objectAtIndex:0] intValue], [[avgYValues objectAtIndex:0] intValue])];
                [path addLineToPoint:CGPointMake([[xSplitPoints objectAtIndex:2] intValue], [[avgYValues objectAtIndex:1] intValue])];
                [path addLineToPoint:CGPointMake([[xSplitPoints objectAtIndex:4] intValue], [[avgYValues objectAtIndex:2] intValue])];
                
                //  Draw the bottom line
                [path moveToPoint:CGPointMake([[xSplitPoints objectAtIndex:0] intValue], [[avgYValues objectAtIndex:0] intValue] + offset)];
                [path addLineToPoint:CGPointMake([[xSplitPoints objectAtIndex:2] intValue], [[avgYValues objectAtIndex:1] intValue] + offset)];
                [path addLineToPoint:CGPointMake([[xSplitPoints objectAtIndex:4] intValue], [[avgYValues objectAtIndex:2] intValue] + offset)];
                
                [view setNeedsDisplay];
            }
            else
            {
                //  Draw the top line
                [path moveToPoint:CGPointMake(currentCharacter.leftX, [[avgYValues objectAtIndex:0] intValue])];
                [path addLineToPoint:CGPointMake(currentCharacter.rightX, [[avgYValues objectAtIndex:1] intValue])];
                
                //  Draw the bottom line
                [path moveToPoint:CGPointMake(currentCharacter.leftX, [[avgYValues objectAtIndex:0] intValue] + offset)];
                [path addLineToPoint:CGPointMake(currentCharacter.rightX, [[avgYValues objectAtIndex:1] intValue] + offset)];
                
                [view setNeedsDisplay];
            }
        }
    }
    
    return view;
}

+ (Character*)floodFill:(unsigned char *)rawData x:(int)x y:(int)y height:(int)height width:(int)width bytesPerPixel:(int)bytesPerPixel bytesPerRow:(int)bytesPerRow
{
    //arrays of CGPoints...
    NSMutableArray *examineList = [[NSMutableArray alloc] init];
    NSMutableArray *allPoints = [[NSMutableArray alloc] init];
    
    const int UPPER_THRESHOLD = 2500;
    
    CGPoint start = CGPointMake(x, y);
    [examineList addObject:[NSValue valueWithCGPoint:start]];
    [allPoints addObject:[NSValue valueWithCGPoint:start]];
    
    while ([examineList count] != 0)
    {
        
        CGPoint point = [[examineList objectAtIndex:0] CGPointValue];
        int p = (bytesPerRow * point.y) + (point.x * bytesPerPixel);
        [examineList removeObjectAtIndex:0];
        
        if ([allPoints count] < UPPER_THRESHOLD && (p >= 0 && p < (bytesPerRow * (height - 1)) + ((width - 1) * bytesPerPixel) && rawData[p] == 0.0))  //if the point is black and there are fewer than UPPER_THRESHOLD pixels
        {
            //add this point to list of all black points...
            [allPoints addObject:[NSValue valueWithCGPoint:point]];
            
            //change the color from black to white
            rawData[p] = 255.0;
            
            //get and add adjacent pixels to the exam list...
            CGPoint west = CGPointMake(point.x - 1, point.y);
            CGPoint north = CGPointMake(point.x, point.y - 1);
            CGPoint east = CGPointMake(point.x + 1, point.y);
            CGPoint south = CGPointMake(point.x, point.y + 1);
            [examineList addObject:[NSValue valueWithCGPoint:west]];
            [examineList addObject:[NSValue valueWithCGPoint:north]];
            [examineList addObject:[NSValue valueWithCGPoint:east]];
            [examineList addObject:[NSValue valueWithCGPoint:south]];
        }
    }
    
    //return array of byte indices of adjacent black pixels including the one given at pixel location x, y
    Character *c = [[Character alloc] initWithPoints:allPoints];
    return c;
}

@end
