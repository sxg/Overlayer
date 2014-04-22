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

//  Utilities
#import "SGTextRecognizer.h"
#import "SGDocumentManager.h"


@interface SGDocument ()

@property (readwrite, strong, nonatomic) NSString *title;
@property (readwrite, strong, nonatomic) UIImage *documentImage;

@property (readwrite, assign, getter = isDrawingLines) BOOL drawingLines;
@property (readwrite, assign) CGFloat drawingLinesProgress;

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
    if (!_documentImage) {
        self.documentImage = [[UIImage alloc] initWithContentsOfFile:self.localPath];
    }
    return _documentImage;
}

- (void)drawLinesCompletion:(void (^)(UIImage *, NSString *, NSArray *))completion
{
    self.drawingLines = YES;
    __block SGDocument *blockSelf = self;
    [[SGTextRecognizer sharedClient] recognizeTextOnImage:self.documentImage update:^(CGFloat progress) {
        blockSelf.drawingLinesProgress = progress;
    } completion:^(UIImage *imageWithLines, NSString *recognizedText, NSArray *recognizedCharacterRects) {
        blockSelf.documentImage = imageWithLines;
        blockSelf.drawingLines = NO;
        if (completion) {
            completion(imageWithLines, recognizedText, recognizedCharacterRects);
        }
        [[SGDocumentManager sharedManager] saveDocument:blockSelf];
    }];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.documentImage = [aDecoder decodeObjectForKey:@"documentImage"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.documentImage forKey:@"documentImage"];
}

@end
