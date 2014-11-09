//
//  SGDocumentManager.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

@class SGDocument;


@interface SGDocumentManager : NSObject

- (void)saveDocument:(SGDocument *)document atPath:(NSURL *)path;
- (void)destroyDocument:(SGDocument *)document completion:(void (^)(BOOL success))completion;
- (void)moveToSubFolder:(NSString *)subFolder;
- (void)moveToParentFolder;

@end
