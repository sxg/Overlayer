//
//  Character.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/27/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Character : NSObject

@property NSMutableArray *points;
@property int topY;
@property int bottomY;
@property int leftX;
@property int rightX;

- (Character*)initWithPoints:(NSArray*)arrayOfPoints;
- (NSArray*)averageYValuesSplitCharacterInto:(int)splits;
- (NSArray*)xSplitPoints:(int)splits;
- (NSArray*)constructBestFitLines:(int)splits;

@end
