//
//  Character.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/27/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Character.h"
#import "Line.c"

@implementation Character

@synthesize points;
@synthesize topY;
@synthesize bottomY;
@synthesize leftX;
@synthesize rightX;

- (Character*)initWithPoints:(NSArray *)arrayOfPoints
{
    points = [[NSMutableArray alloc] initWithCapacity:[arrayOfPoints count]];
    for (int i = 0; i < [arrayOfPoints count]; i++)
    {
        [points addObject:[arrayOfPoints objectAtIndex:i]];
    }
    
    int currentTopY = -1;
    int currentBottomY = -1;
    int currentLeftX = -1;
    int currentRightX = -1;
    for (int i = 0; i < [points count]; i++)
    {
        CGPoint currentPoint = [[points objectAtIndex:i] CGPointValue];
        
        if (currentTopY == -1 || currentTopY > currentPoint.y)
        {
            currentTopY = currentPoint.y;
        }
        if (currentBottomY == -1 || currentBottomY < currentPoint.y)
        {
            currentBottomY = currentPoint.y;
        }
        if (currentLeftX == -1 || currentLeftX > currentPoint.x)
        {
            currentLeftX = currentPoint.x;
        }
        if (currentRightX == -1 || currentRightX < currentPoint.x)
        {
            currentRightX = currentPoint.x;
        }
    }
    
    [self setTopY:currentTopY];
    [self setBottomY:currentBottomY];
    [self setLeftX:currentLeftX];
    [self setRightX:currentRightX];
    
    return self;
}

- (NSArray*)averageYValuesSplitCharacterInto:(int)splits
{
    NSMutableArray *averageYValues = [[NSMutableArray alloc] initWithCapacity:splits];
    
    for (int currentSplitNumber = 0; currentSplitNumber < splits; currentSplitNumber++)
    {
        int sumY = 0;
        int numPointsObservedInRange = 0;
        int minX = (currentSplitNumber * ((rightX - leftX) / splits)) + leftX;
        int maxX = ((currentSplitNumber + 1) * ((rightX - leftX) / splits)) + leftX - 1;
        if (currentSplitNumber == 0)
        {
            minX = leftX;
        }
        else if (currentSplitNumber == splits - 1)
        {
            maxX = rightX;
        }
        
        for (int j = 0; j < [points count]; j++)
        {
            CGPoint currentPoint = [[points objectAtIndex:j] CGPointValue];
    
            if (currentPoint.x >= minX && currentPoint.x <= maxX)
            {
                sumY += currentPoint.y;
                numPointsObservedInRange++;
            }
        }
        
        int avgY = sumY / numPointsObservedInRange;
        [averageYValues addObject:[NSNumber numberWithInt:avgY]];
    }
    
    return averageYValues;
}

- (NSArray*)xSplitPoints:(int)splits
{
    NSMutableArray *splitPoints = [[NSMutableArray alloc] initWithCapacity:(splits + 2)];
    
    [splitPoints addObject:[NSNumber numberWithInt:leftX]];
    int splitLength = (rightX - leftX) / splits;
    for (int currentSplitNumber = 1; currentSplitNumber < splits + 1; currentSplitNumber++)
    {
        int x = (currentSplitNumber * splitLength) - (splitLength / 2) + leftX;
        [splitPoints addObject:[NSNumber numberWithInt:x]];
    }
    [splitPoints addObject:[NSNumber numberWithInt:rightX]];
    
    return splitPoints;
}

- (NSArray*)constructBestFitLines:(int)splits
{
    NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity:splits];
    
    for (int currentSplitNumber = 0; currentSplitNumber < splits; currentSplitNumber++)
    {
        int sumX = 0;
        int sumX2 = 0;
        int sumY = 0;
        int sumXY = 0;
        int count = 0;
        struct Line newLine;
        int minX = (currentSplitNumber * ((rightX - leftX) / splits)) + leftX;
        int maxX = ((currentSplitNumber + 1) * ((rightX - leftX) / splits)) + leftX - 1;
        if (currentSplitNumber == 0)
        {
            minX = leftX;
        }
        else if (currentSplitNumber == splits - 1)
        {
            maxX = rightX;
        }
        
        for (int j = 0; j < [points count]; j++)
        {
            CGPoint currentPoint = [[points objectAtIndex:j] CGPointValue];
            
            if (currentPoint.x >= minX && currentPoint.x <= maxX)
            {
                sumX += currentPoint.x;
                sumX2 += pow(currentPoint.x, 2);
                sumY += currentPoint.y;
                sumXY += currentPoint.x * currentPoint.y;
                count++;
            }
        }
        
        float xMean = (float)sumX / (float)count;
        float yMean = (float)sumY / (float)count;
        float slope = (float)(sumXY - (sumX * yMean)) / (float)(sumX2 - (sumX * xMean));
        int yInt = yMean - slope * xMean;
        
        newLine.m = slope;
        newLine.b = yInt;
        
        NSValue *newLineValue = [NSValue valueWithBytes:&newLine objCType:@encode(struct Line)];
        [lines addObject:newLineValue];
    }
    
    return lines;
}

@end