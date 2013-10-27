//
//  SGDocument.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/25/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

@import Foundation;

@interface SGDocument : NSObject

@property (nonatomic, readonly, strong) UIImage *image;
@property (nonatomic, readonly, copy) NSString *title;

- (id)initWithImage:(UIImage *)image title:(NSString *)title;
- (void)drawLinesWithLineWidth:(CGFloat)lineWidth;

@end
