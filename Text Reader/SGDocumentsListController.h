//
//  SGDocumentsListController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/23/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGCollection.h"
#import "SGAddDocumentController.h"

@interface SGDocumentsListController : UITableViewController <SGAddDocumentDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, readwrite, strong) SGCollection *collection;

@end
