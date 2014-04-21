//
//  SGDocument.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGDocument.h"

//  Frameworks
#import <StandardPaths/StandardPaths.h>


@interface SGDocument ()

@property (readwrite, strong, nonatomic) NSString *title;
@property (readwrite, strong, nonatomic) NSString *localPath;
@property (readwrite, strong, nonatomic) UIImage *documentImage;

@end

@implementation SGDocument

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title
{
    self = [super init];
    if (self) {
        NSAssert(title, @"The title is nil");
        
        self.documentImage = image;
        self.title = title;
    }
    return self;
}

- (NSString *)localPath
{
    return [[NSFileManager defaultManager] pathForPublicFile:[NSString stringWithFormat:@"%@.png", self.title]];
}

- (UIImage *)documentImage
{
    if (!self.documentImage) {
        self.documentImage = [[UIImage alloc] initWithContentsOfFile:self.localPath];
    }
    return self.documentImage;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.localPath = [aDecoder decodeObjectForKey:@"localPath"];
        self.documentImage = [aDecoder decodeObjectForKey:@"documentImage"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.localPath forKey:@"localPath"];
    [aCoder encodeObject:self.documentImage forKey:@"documentImage"];
}

@end
