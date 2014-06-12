//
//  SGDoubleStrikethroughView.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/11/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGDoubleStrikethroughView.h"
#import "NSString+LineHeight.h"


@interface SGDoubleStrikethroughView ()

@property (readwrite, strong, nonatomic) NSString *word;

@end

@implementation SGDoubleStrikethroughView

- (instancetype)initWithFrame:(CGRect)frame word:(NSString *)word
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.word = word;
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
    
    CGFloat topOffset = CGRectGetHeight(rect) * 0.333;
    if ([self.word containsAscender]) {
        topOffset *= 1.3;
    }
    CGFloat bottomOffset = CGRectGetHeight(rect) * 0.333;
    if ([self.word containsDescender]) {
        bottomOffset *= 1.3;
    }
    
    //  Draw the bottom line
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) + topOffset);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) + topOffset);
    
    //  Draw the top line
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - bottomOffset);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - bottomOffset);
    
    CGContextStrokePath(context);
}

@end
