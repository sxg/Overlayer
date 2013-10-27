//
//  SGSGCollection.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 3/10/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

@import Foundation;
#import "SGDocument.h"

@interface SGCollection : NSObject

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, strong) NSMutableArray *documents;

- (id)initWithTitle:(NSString *)title;
- (NSString *)savePath;
- (NSString *)pdfPath;
- (void)addDocument:(SGDocument *)document;
- (void)deleteDocumentWithTitle:(NSString *)documentTitle;
- (void)reloadData;
- (void)drawLines;
- (void)deleteCollection;
- (void)createPDF;
- (BOOL)hasPDF;

@end
