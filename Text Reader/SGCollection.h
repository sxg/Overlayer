//
//  SGSGCollection.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGDocument.h"

@interface SGCollection : NSObject

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, strong) NSMutableArray *documents;
@property (nonatomic, readonly, assign) BOOL hasLinesDrawn;

- (id)initWithTitle:(NSString *)title;
- (NSString *)savePath;
- (void)addDocument:(SGDocument *)document;
- (void)deleteDocumentWithTitle:(NSString *)documentTitle;
- (void)reloadData;
- (void)drawLines;
- (void)deleteCollection;

@end
