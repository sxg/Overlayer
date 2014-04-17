//
//  SGCircleButton.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/17/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGCircleButton.h"


@implementation SGCircleButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    [super drawRect:rect];
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGRect rectInset = CGRectInset(rect, 3.0f, 3.0f);
//    
//    CGContextSetBlendMode(context, kCGBlendModeDarken);
//    CGContextSetLineWidth(context, 3.0f);
//    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.8f].CGColor);
//    CGPathRef path = CGPathCreateWithRoundedRect(rectInset, CGRectGetWidth(rectInset)/2, CGRectGetHeight(rectInset)/2, NULL);
//    CGContextAddPath(context, path);
//    CGContextStrokePath(context);
//}

@end
