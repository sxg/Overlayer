//
//  SGDocumentManager.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

@class SGDocument;


@interface SGDocumentManager : NSObject

@property (readonly, strong, nonatomic) NSArray *documents;

+ (SGDocumentManager *)sharedManager;

- (void)saveDocument:(SGDocument *)document;

@end
