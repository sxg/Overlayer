//
//  DrawingView.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 1/27/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIView {
    UIBezierPath *path;
}

@property UIBezierPath *path;

- (void)drawStuff;

@end
