//
//  SGDocumentController.h
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/25/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

@import UIKit;
#import "SGDocument.h"
#import "SGCollection.h"

@interface SGDocumentController : UIViewController

- (void)setDocument:(SGDocument *)document collection:(SGCollection *)collection;

@end
