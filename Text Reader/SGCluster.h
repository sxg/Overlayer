//
//  SGCluster.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/19/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGCluster : NSObject

@property (nonatomic, readonly, strong) NSArray *points;
@property (nonatomic, readonly, assign) NSInteger maxNorth;
@property (nonatomic, readonly, assign) NSInteger maxSouth;
@property (nonatomic, readonly, assign) NSInteger maxWest;
@property (nonatomic, readonly, assign) NSInteger maxEast;

//  Takes an NSArray of CGPoints wrapped as NSValues
- (id)initWithPoints:(NSArray *)points;
- (NSArray *)pointsOnMidline;

@end
