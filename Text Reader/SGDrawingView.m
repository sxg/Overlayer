//
//  SGDrawingView.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/27/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

/*
    This is a subclass of UIView, and it serves as a sort of transparency upon which the strikethroughs can be drawn by the UIBezierPath.
    The processing of the picture will output sets of coordinates that describe where the strikethroughs should be drawn. In order to preserve
    the original image, the drawing will occur on this view.
 
    _path is the UIBezierPath that will draw all the strikethroughs
 */

#import "SGDrawingView.h"

@implementation SGDrawingView

@synthesize path;

- (id)init
{
    self = [super init];
    if (self) {
        //  Create the path and set the background of this view to be transparent
        path = [[UIBezierPath alloc] init];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //  Create the path and set the background of this view to be transparent
        path = [[UIBezierPath alloc] init];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //  Set the color of the path and draw it
    [[UIColor blackColor] setStroke];
    [path stroke];
}

@end
