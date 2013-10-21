//
//  SGCluster.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/19/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGCluster.h"
#import <Underscore.m/Underscore.h>

#define _ Underscore

//  Divide each cluster into this many parts
#define NUM_DIVISIONS 3

@interface SGCluster()

@property (nonatomic, readwrite, strong) NSArray *points;
@property (nonatomic, readwrite, assign) NSInteger maxNorth;
@property (nonatomic, readwrite, assign) NSInteger maxSouth;
@property (nonatomic, readwrite, assign) NSInteger maxWest;
@property (nonatomic, readwrite, assign) NSInteger maxEast;

@end

@implementation SGCluster

- (id)initWithPoints:(NSArray *)points
{
    self = [super init];
    if (self) {
        _points = points;
        
        //  Intialize with default values
        _maxNorth = -1;
        _maxSouth = -1;
        _maxEast = -1;
        _maxWest = -1;
        
        for (NSValue *pointValue in points) {
            CGPoint point = [pointValue CGPointValue];
            
            if (_maxNorth == -1 || _maxNorth > point.y) {
                _maxNorth = point.y;
            } else if (_maxSouth == -1 || _maxSouth < point.y) {
                _maxSouth = point.y;
            } else if (_maxEast == -1 || _maxEast < point.x) {
                _maxEast = point.x;
            } else if (_maxWest == -1 || _maxWest > point.x) {
                _maxWest = point.x;
            }
        }
    }
    return self;
}

- (NSArray *)pointsOnMidline
{
    //  Ordered array of horizontal positions of this cluster
    NSMutableArray *horizontalPositions = [[NSMutableArray alloc] initWithObjects:@(_maxWest), nil];
    //  Fence post counting - need the max west and max east values as well as the mid position values (1 less than the number of divisions
    NSInteger divisionWidth = (_maxEast - _maxWest)/NUM_DIVISIONS;
    for (int i = 1; i < NUM_DIVISIONS; i++) {
        NSInteger midPosition = i * divisionWidth + _maxWest;
        [horizontalPositions addObject:@(midPosition)];
    }
    [horizontalPositions addObject:@(_maxEast)];
    
    //  Ordered array of vertical positions of this cluster that correspond to the horizontal positions
    NSMutableArray *verticalPositions = [[NSMutableArray alloc] init];
    for (NSNumber *horizontalPosition in horizontalPositions) {
        NSMutableArray *verticalPositionsToAverage = [[NSMutableArray alloc] init];
        for (NSValue *pointValue in _points) {
            if ([pointValue CGPointValue].x >= [horizontalPosition intValue] && [pointValue CGPointValue].x < [horizontalPosition intValue] + divisionWidth) {
                [verticalPositionsToAverage addObject:@([pointValue CGPointValue].y)];
            }
        }
        NSInteger sum = 0;
        for (NSNumber *verticalPosition in verticalPositionsToAverage) {
            sum += [verticalPosition intValue];
        }
        NSNumber *verticalPosition = @(sum/verticalPositionsToAverage.count);
        [verticalPositions addObject:verticalPosition];
    }
    
    NSMutableArray *midlinePoints = [[NSMutableArray alloc] init];
    for (int i = 0; i < horizontalPositions.count; i++) {
        CGPoint point = CGPointMake([horizontalPositions[i] floatValue], [verticalPositions[i] floatValue]);
        NSValue *pointValue = [NSValue valueWithCGPoint:point];
        [midlinePoints addObject:pointValue];
    }
    return midlinePoints;
}

@end
