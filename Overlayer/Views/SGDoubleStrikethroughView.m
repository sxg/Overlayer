//
//  SGDoubleStrikethroughView.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/11/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGDoubleStrikethroughView.h"


@implementation SGDoubleStrikethroughView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, CGRectGetHeight(rect)/20.0f);
    
    CGFloat oneThirdY = CGRectGetHeight(rect) * 0.333;
    
    //  Draw the bottom line
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) + oneThirdY);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) + oneThirdY);
    
    //  Draw the top line
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - oneThirdY);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - oneThirdY);
    
    CGContextStrokePath(context);
}

@end
