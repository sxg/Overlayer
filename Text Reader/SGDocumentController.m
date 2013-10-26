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

@property (nonatomic, weak) SGCollectionsListController *collectionListVC;

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
    
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController.parentViewController;
    _collectionListVC = (SGCollectionsListController *)[[[[splitVC viewControllers] objectAtIndex:0] viewControllers] lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
