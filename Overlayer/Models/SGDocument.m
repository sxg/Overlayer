//
//  SGDocument.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGDocument.h"


@interface SGDocument ()

@property (readwrite, strong, nonatomic) NSString *title;
@property (readwrite, strong, nonatomic) NSUUID *uuid;
@property (readwrite, strong, nonatomic) NSData *pdfData;

//  QLPreviewItem Protocol
@property (readwrite, strong, nonatomic) NSString *previewItemTitle;
@property (readwrite, strong, nonatomic) NSURL *previewItemURL;

@end

@implementation SGDocument

#pragma mark - Initialization

+ (instancetype)loadFromURL:(NSURL *)url
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[url absoluteString]];
}

- (instancetype)initWithURL:(NSURL *)url pdfData:(NSData *)pdfData title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.uuid = [[NSUUID alloc] init];
        self.title = title;
        self.pdfData = pdfData;
        self.url = url;
        self.previewItemTitle = self.title;
    }
    return self;
}

#pragma mark - Getters / Setters

- (void)setUrl:(NSURL *)url
{
    _url = url;
    self.previewItemURL = self.url;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.url forKey:@"url"];
}

@end
