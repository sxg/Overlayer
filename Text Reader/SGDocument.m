//
//  SGDocument.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/25/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGDocument.h"
#import "SGLineDrawing.h"

@interface SGDocument()

@property (nonatomic, readwrite, strong) UIImage *image;
@property (nonatomic, readwrite, copy) NSString *title;

@end

@implementation SGDocument

- (id)initWithImage:(UIImage *)image title:(NSString *)title
{
    self = [super init];
    if (self) {
        _image = image;
        _title = title;
    }
    return self;
}

- (void)drawLinesWithLineWidth:(CGFloat)lineWidth
{
    _image = [SGLineDrawing identifyCharactersOnImage:_image lineThickness:lineWidth];
}

@end
