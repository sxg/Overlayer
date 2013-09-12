//
//  SGBookViewController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 9/12/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGBookViewController.h"
#import "SGBookListViewController.h"

@interface SGBookViewController ()

@property (nonatomic, weak) SGBookListViewController *bookListVC;

@end

@implementation SGBookViewController

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
    
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController;
    _bookListVC = (SGBookListViewController *)[[[[splitVC viewControllers] objectAtIndex:0] viewControllers] lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
