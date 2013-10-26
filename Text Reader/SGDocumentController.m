//
//  SGDocumentController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/25/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGDocumentController.h"
#import "SGCollectionsListController.h"

@interface SGDocumentController ()

@property (nonatomic, readwrite, strong) IBOutlet UIScrollView *documentScrollView;

@end

@implementation SGDocumentController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDocument:(SGDocument *)document
{
    _document = document;
    UIImageView *documentImageView = [[UIImageView alloc] initWithImage:_document.image];
    [_documentScrollView addSubview:documentImageView];
    [_documentScrollView setContentSize:documentImageView.bounds.size];
}

@end
