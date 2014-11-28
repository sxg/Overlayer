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
@property (readwrite, strong, nonatomic, setter=setUUID:) NSUUID *uuid;
@property (readwrite, strong, nonatomic) NSData *pdfData;

//  QLPreviewItem Protocol
@property (readwrite, strong, nonatomic) NSString *previewItemTitle;
@property (readwrite, strong, nonatomic) NSURL *previewItemURL;

@end

@implementation SGDocument

#pragma mark - Initialization

+ (instancetype)documentWithContentsOfURL:(NSURL *)url
{
    NSURL *archiveURL = [url URLByAppendingPathComponent:@"archive"];
    SGDocument *document = [NSKeyedUnarchiver unarchiveObjectWithFile:[archiveURL path]];
    document.url = url;
    return document;
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

- (void)setURL:(NSURL *)url
{
    _url = url;
    self.previewItemURL = [[self.url URLByAppendingPathComponent:@"pdf"] URLByAppendingPathExtension:@"pdf"];
}

- (NSData *)pdfData
{
    if (!_pdfData) {
        _pdfData = [NSData dataWithContentsOfFile:[self.previewItemURL path]];
    }
    return _pdfData;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
}

@end
