//
//  NSString+LineHeight.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 6/11/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "NSString+LineHeight.h"


@implementation NSString (LineHeight)

static NSCharacterSet *ascenders;
static NSCharacterSet *descenders;

+ (void)initialize
{
    ascenders = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZbdfhklt0123456789"];
    descenders = [NSCharacterSet characterSetWithCharactersInString:@"gjpqy"];
}

- (BOOL)containsAscender
{
    return [self rangeOfCharacterFromSet:ascenders].location != NSNotFound;
}

- (BOOL)containsDescender
{
    return [self rangeOfCharacterFromSet:descenders].location != NSNotFound;
}

@end
