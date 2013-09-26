//
//  SYNBookTests.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/11/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Kiwi.h"
#import "SGBook.h"

SPEC_BEGIN(SYNBookTests)

describe(@"A book", ^{
    
    __block SGBook *book;
    
    beforeEach(^{
        book = [[SGBook alloc] initWithTitle:@"Book"];
    });
    
    afterEach(^{
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *bookPath = [documentsDirectory stringByAppendingPathComponent:book.title];
        [[NSFileManager defaultManager] removeItemAtPath:bookPath error:nil];
        
        book = nil;
    });
    
    context(@"on init", ^{
        
        it(@"should accept and set a title", ^{
            [[[book title] should] equal:@"Book"];
        });
        
        it(@"should setup its pages", ^{
            [[[book pages] should] beNonNil];
            [[[book pages] should] beKindOfClass:[NSMutableArray class]];
        });
        
        it(@"should create a folder with the book title", ^{
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *bookPath = [documentsDirectory stringByAppendingPathComponent:book.title];
            BOOL isDir;
            BOOL bookPathExists = [[NSFileManager defaultManager] fileExistsAtPath:bookPath isDirectory:&isDir];
            [[theValue(bookPathExists) should] equal:theValue(true)];
            [[theValue(isDir) should] equal:theValue(true)];
        });
        
        it(@"should have a save path that points to its folder", ^{
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *bookPath = [documentsDirectory stringByAppendingPathComponent:book.title];
            [[[book savePath] should] equal:bookPath];
        });
        
    });
    
    context(@"on destroy", ^{
        
        it(@"should remove the folder", ^{
            [book destroy];
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *bookPath = [documentsDirectory stringByAppendingPathComponent:book.title];
            BOOL bookPathExists = [[NSFileManager defaultManager] fileExistsAtPath:bookPath isDirectory:nil];
            [[theValue(bookPathExists) should] equal:theValue(false)];
        });
        
    });
    
    context(@"on adding a page", ^{
        
        __block UIImage *image;
        
        beforeEach(^{
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *imagePath = [bundle pathForResource:@"icon" ofType:@"png"];
            image = [UIImage imageWithContentsOfFile:imagePath];
        });
        
        afterEach(^{
            image = nil;
        });
        
        it(@"should be added to the book's pages array", ^{
            int numPages = book.pages.count;
            [book addPage:image];
            [[theValue(book.pages.count) should] equal:theValue(numPages + 1)];
            [[[book.pages lastObject] should] equal:image];
        });
        
        it(@"should be saved to the book's directory", ^{
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *bookPath = [documentsDirectory stringByAppendingPathComponent:book.title];
            int numSavedImagesBefore = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bookPath error:nil].count;
            [book addPage:image];
            int numSavedImagesAfter = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bookPath error:nil].count;
            
            [[theValue(numSavedImagesAfter) shouldNot] equal:theValue(0)];
            [[theValue(numSavedImagesBefore) should] equal:theValue(numSavedImagesAfter - 1)];
            
            BOOL isDir;
            BOOL bookPathExists = [[NSFileManager defaultManager] fileExistsAtPath:bookPath isDirectory:&isDir];
            [[theValue(bookPathExists) should] equal:theValue(true)];
            [[theValue(isDir) should] equal:theValue(true)];
        });
        
    });
    
});

SPEC_END