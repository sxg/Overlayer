//
//  SGLineDrawing.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/26/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGLineDrawing.h"
#import "UIImage+Transform.h"
#import "SGCluster.h"
#import <GPUImage/GPUImage.h>

@implementation SGLineDrawing

+ (SGDrawingView *)identifyCharactersOnImage:(UIImage *)image lineThickness:(float)lineThickness
{
    const int bytesPerPixel = 4;
    const int bitsPerComponent = 8;
    int bytesPerRow = bytesPerPixel * image.size.width;
    
    //  Make black/white image of text
    //GPUImageAdaptiveThresholdFilter *filter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    GPUImageLuminanceThresholdFilter *filter = [[GPUImageLuminanceThresholdFilter alloc] init];
    UIImage *blackAndWhiteImage = [filter imageByFilteringImage:image];
    
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
    [UIImagePNGRepresentation(blackAndWhiteImage) writeToFile:path atomically:YES];
    
    //  Get the bitamp
    CGImageRef imageRef = blackAndWhiteImage.CGImage;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    unsigned char *bitmap = (unsigned char*) calloc(CGImageGetHeight(imageRef) * CGImageGetWidth(imageRef) * 4, sizeof(unsigned char));
    CGContextRef context = CGBitmapContextCreate(bitmap, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), bitsPerComponent, bytesPerPixel * CGImageGetWidth(imageRef), colorSpaceRef, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
    
    const int LOWER_THRESHOLD = 20; //minimum number of adjacent black pixels that will define a character
    const int UPPER_THRESHOLD = 7000; //maximum number of adjacent black pixels that will define a character
    
    //array of characters, which are arrays of pixel byte indexes
    NSMutableArray *characters = [[NSMutableArray alloc] init];
    
    for (int y = 0; y < CGImageGetHeight(imageRef); y++) {
        for (int x = 0; x < CGImageGetWidth(imageRef); x++) {
            int byteIndex = (bytesPerRow * y) + (x * bytesPerPixel);
            if (bitmap[byteIndex] == 0.0) {
                CGPoint startPoint = CGPointMake(x, y);
                CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
                SGCluster *cluster = [self floodFill:bitmap startPoint:startPoint imageSize:imageSize];
                if ([[cluster points] count] > LOWER_THRESHOLD && [[cluster points] count] < UPPER_THRESHOLD) {
                    [characters addObject:cluster];
                }
            }
            
        }
    }
    
    CGContextRelease(context);
    free(bitmap);
    return [self drawLinesOnImage:image characters:characters lineThickness:lineThickness bytesPerPixel:bytesPerPixel bitsPerComponent:bitsPerComponent];
}

+ (SGDrawingView *)drawLinesOnImage:(UIImage *)image characters:(NSMutableArray *)characters lineThickness:(float)lineThickness bytesPerPixel:(int)bytesPerPixel bitsPerComponent:(int)bitsPerComponent
{
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    SGDrawingView *view = [[SGDrawingView alloc] initWithFrame:frame];
    
    //  Iterate through every "cluster" of black pixels
    for (SGCluster *cluster in characters) {
        UIBezierPath *path = [view path];
        [path setLineWidth:lineThickness];
        int offset = sqrt((cluster.maxSouth - cluster.maxNorth));// roughStdDev * 2;

        NSArray *midlinePoints = [cluster pointsOnMidline];
        
        //  Draw the top line
        NSValue *startPointValue = midlinePoints[0];
        CGPoint startPoint = CGPointMake([startPointValue CGPointValue].x, [startPointValue CGPointValue].y - offset);
        [path moveToPoint:startPoint];
        for (NSValue *pointValue in midlinePoints) {
            CGPoint topPoint = CGPointMake([pointValue CGPointValue].x, [pointValue CGPointValue].y - offset);
            [path addLineToPoint:topPoint];
        }
        
        //  Draw the bottom line
        startPoint = CGPointMake([startPointValue CGPointValue].x, [startPointValue CGPointValue].y + offset);
        [path moveToPoint:startPoint];
        for (NSValue *pointValue in midlinePoints) {
            CGPoint bottomPoint = CGPointMake([pointValue CGPointValue].x, [pointValue CGPointValue].y + offset);
            [path addLineToPoint:bottomPoint];
        }
        
    }
    
    [view setNeedsDisplay];
    
    return view;
}

+ (SGCluster *)floodFill:(unsigned char *)bitmap startPoint:(CGPoint)startPoint imageSize:(CGSize)imageSize
{
    const int bytesPerPixel = 4;
    const int bytesPerRow = bytesPerPixel * imageSize.width;
    
    //arrays of CGPoints...
    NSMutableArray *examineList = [[NSMutableArray alloc] init];
    NSMutableArray *allPoints = [[NSMutableArray alloc] init];
    
    const int UPPER_THRESHOLD = 2500;
    
    [examineList addObject:[NSValue valueWithCGPoint:startPoint]];
    [allPoints addObject:[NSValue valueWithCGPoint:startPoint]];
    
    while ([examineList count] != 0) {
        CGPoint point = [[examineList objectAtIndex:0] CGPointValue];
        int p = (bytesPerRow * point.y) + (point.x * bytesPerPixel);
        [examineList removeObjectAtIndex:0];
        
        if ([allPoints count] < UPPER_THRESHOLD && (p >= 0 && p < (bytesPerRow * (imageSize.height - 1)) + ((imageSize.width - 1) * bytesPerPixel) && bitmap[p] == 0.0))  //if the point is black and there are fewer than UPPER_THRESHOLD pixels
        {
            //add this point to list of all black points...
            [allPoints addObject:[NSValue valueWithCGPoint:point]];
            
            //change the color from black to white
            bitmap[p] = 255.0;
            
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
    
    SGCluster *cluster = [[SGCluster alloc] initWithPoints:allPoints];
    return cluster;
}

@end
