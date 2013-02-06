//
//  DrawingView.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/27/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "DrawingView.h"

@implementation DrawingView

@synthesize path;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //Make sure initWithFrame: is called or else the path will not be initialized!
        path = [[UIBezierPath alloc] init];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect // (5)
{
    [[UIColor blueColor] setStroke];
    [path stroke];
}

- (void)drawStuff
{
    [path moveToPoint:CGPointMake(30, 30)];
    [path addLineToPoint:CGPointMake(50, 30)];
    [path addLineToPoint:CGPointMake(70, 50)];
    [self setNeedsDisplay];
}

@end
