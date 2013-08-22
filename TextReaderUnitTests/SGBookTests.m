//
//  SGBookTests.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 8/20/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGBookTests.h"
#import "SGBook.h"

@interface SGBookTests()

@property (nonatomic, readwrite, strong) SGBook *book;

@end

@implementation SGBookTests

- (void)setUp
{
    _book = [[SGBook alloc] initWithTitle:@"A Great Book"];
}

- (void)tearDown
{
    _book = nil;
}

#pragma mark - Tests

- (void)testBookCanBeInitializedWithTitle
{
    STAssertEqualObjects(_book.title, @"A Great Book", @"SGBook should be able to be initialized with a title");
}

- (void)testBookSavesToDocumentsDirectoryWithTitleAsFileName
{
    NSString *savePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"A Great Book.pdf"];
    STAssertEqualObjects([_book savePath], savePath, @"SGBook is saved with its title as the file name in the documents directory");
}

- (void)testBookCanAddPageWhenNoneExist
{
    UIImage *image = [UIImage imageNamed:@"collectionViewBackground.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [_book addPage:imageView];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[_book savePath]], @"Adding a page to an empty SGBook creates the book with the page");
}

@end
