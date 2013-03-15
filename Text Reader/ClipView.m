//
//  ClipView.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/15/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "ClipView.h"

@implementation ClipView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event])
    {
        return _scrollingPages;
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
