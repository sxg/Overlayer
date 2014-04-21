//
//  SGDocument.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//


@interface SGDocument : NSObject <NSCoding>

@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic) NSString *localPath;
@property (readonly, strong, nonatomic) UIImage *documentImage;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;

@end
