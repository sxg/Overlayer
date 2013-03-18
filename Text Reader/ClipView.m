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

//  This overrides the normal hittest method. This way, the scrollview and the imageviews within it work as intended.
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* child = nil;
    if ((child = [super hitTest:point withEvent:event]) == self)
    {
        for (UIView *subview in self.scrollingPages.subviews)
        {
            CGPoint newPoint = [subview convertPoint:point fromView:self];
            if ([subview pointInside:newPoint withEvent:event])
            {
                return subview;
            }
        }
    	return self.scrollingPages;
    }
    return child;
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
