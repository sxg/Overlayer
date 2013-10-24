//
//  SYNCollectionTests.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/11/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "Kiwi.h"
#import "SGCollection.h"

SPEC_BEGIN(SYNCollectionTests)

describe(@"A collection", ^{
    
    __block SGCollection *collection;
    
    beforeEach(^{
        collection = [[SGCollection alloc] initWithTitle:@"Collection"];
    });
    
    afterEach(^{
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *CollectionPath = [documentsDirectory stringByAppendingPathComponent:collection.title];
        [[NSFileManager defaultManager] removeItemAtPath:CollectionPath error:nil];
        
        collection = nil;
    });
    
    context(@"on init", ^{
        
        it(@"should accept and set a title", ^{
            [[[collection title] should] equal:@"Collection"];
        });
        
        it(@"should setup its pages", ^{
            [[[collection pages] should] beNonNil];
            [[[collection pages] should] beKindOfClass:[NSMutableArray class]];
        });
        
        it(@"should create a folder with the collection title", ^{
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *CollectionPath = [documentsDirectory stringByAppendingPathComponent:collection.title];
            BOOL isDir;
            BOOL CollectionPathExists = [[NSFileManager defaultManager] fileExistsAtPath:CollectionPath isDirectory:&isDir];
            [[theValue(CollectionPathExists) should] equal:theValue(true)];
            [[theValue(isDir) should] equal:theValue(true)];
        });
        
        it(@"should have a save path that points to its folder", ^{
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *CollectionPath = [documentsDirectory stringByAppendingPathComponent:collection.title];
            [[[collection savePath] should] equal:CollectionPath];
        });
        
    });
    
    context(@"on destroy", ^{
        
        it(@"should remove the folder", ^{
            [collection destroy];
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *CollectionPath = [documentsDirectory stringByAppendingPathComponent:collection.title];
            BOOL CollectionPathExists = [[NSFileManager defaultManager] fileExistsAtPath:CollectionPath isDirectory:nil];
            [[theValue(CollectionPathExists) should] equal:theValue(false)];
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
        
        it(@"should be added to the Collection's pages array", ^{
            int numPages = collection.pages.count;
            [collection addPage:image];
            [[theValue(collection.pages.count) should] equal:theValue(numPages + 1)];
            [[[collection.pages lastObject] should] equal:image];
        });
        
        it(@"should be saved to the Collection's directory", ^{
            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *CollectionPath = [documentsDirectory stringByAppendingPathComponent:collection.title];
            int numSavedImagesBefore = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:CollectionPath error:nil].count;
            [collection addPage:image];
            int numSavedImagesAfter = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:CollectionPath error:nil].count;
            
            [[theValue(numSavedImagesAfter) shouldNot] equal:theValue(0)];
            [[theValue(numSavedImagesBefore) should] equal:theValue(numSavedImagesAfter - 1)];
            
            BOOL isDir;
            BOOL CollectionPathExists = [[NSFileManager defaultManager] fileExistsAtPath:CollectionPath isDirectory:&isDir];
            [[theValue(CollectionPathExists) should] equal:theValue(true)];
            [[theValue(isDir) should] equal:theValue(true)];
        });
        
    });
    
});

SPEC_END