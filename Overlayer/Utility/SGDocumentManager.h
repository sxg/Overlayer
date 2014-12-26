//
//  SGDocumentManager.h
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

@class SGDocument;


@interface SGDocumentManager : NSObject

@property (readonly, strong, nonatomic) NSURL *currentURL;

- (void)moveToSubfolder:(NSString *)subfolderName;
- (void)moveToParentFolder;
- (void)createFolder:(NSString *)folderName;
- (void)destroyFolder:(NSString *)folderName;

- (void)saveDocument:(SGDocument *)document;
- (void)saveDocument:(SGDocument *)document atURL:(NSURL *)url;
- (void)destroyDocumentAtURL:(NSURL *)url;
- (void)moveDocument:(SGDocument *)document;

- (NSArray *)documentNames;
- (NSArray *)folderNames;
- (NSArray *)contentsOfCurrentFolder;
- (NSArray *)documentFolderNames;

@end
