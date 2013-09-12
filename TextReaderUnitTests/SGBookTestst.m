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
    
    context(@"on init", ^{
        
        it(@"should accept and set a title", ^{
            SGBook *book = [[SGBook alloc] initWithTitle:@"A Great Book"];
            [[[book title] should] equal:@"A Great Book"];
        });
        
        it(@"should setup its pages", ^{
            SGBook *book = [[SGBook alloc] initWithTitle:@"Another Book"];
            [[[book pages] should] beNonNil];
            [[[book pages] should] beKindOfClass:[NSMutableArray class]];
        });
        
    });
    
});

SPEC_END