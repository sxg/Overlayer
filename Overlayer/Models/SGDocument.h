//
//  SGDocument.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import <QuickLook/QuickLook.h>


@interface SGDocument : NSObject <NSCoding, QLPreviewItem>

@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic) NSUUID *uuid;
@property (readonly, strong, nonatomic) NSData *pdfData;
@property (readwrite, strong, nonatomic) NSURL *url;

//  QLPreviewItem Protocol
@property (readonly, strong) NSString *previewItemTitle;
@property (readonly, strong) NSURL *previewItemURL;

+ (instancetype)loadFromURL:(NSURL *)url;

- (instancetype)initWithURL:(NSURL *)url pdfData:(NSData *)pdfData title:(NSString *)title;

@end
