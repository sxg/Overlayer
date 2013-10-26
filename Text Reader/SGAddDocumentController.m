//
//  SGAddDocumentController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/23/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGAddDocumentController.h"
#import "SGDocument.h"

@interface SGAddDocumentController ()

@property (nonatomic, readwrite, strong) IBOutlet UITextField *documentTitleTextField;

@end

@implementation SGAddDocumentController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI actions

- (IBAction)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addDocumentTitle:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [_delegate addDocumentController:self didAddDocumentWithTitle:_documentTitleTextField.text];
    }];
}

@end
