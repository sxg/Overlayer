//
//  SGDocumentManager.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

@class SGDocument;


@interface SGDocumentManager : NSObject

+ (void)saveDocument:(SGDocument *)document atURL:(NSURL *)url;
+ (void)destroyDocumentAtURL:(NSURL *)url completion:(void (^)(BOOL success))completion;
+ (void)moveDocumentFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL;
+ (NSArray *)documentsAtURL:(NSURL *)url;

@end
