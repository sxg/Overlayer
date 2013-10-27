//
//  SGSettingsController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/27/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGSettingsController.h"

@interface SGSettingsController ()

@property (nonatomic, readwrite, weak) IBOutlet UITextField *lineWidthTextField;

@end

@implementation SGSettingsController

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
    
    _lineWidthTextField.text = [[[NSUserDefaults standardUserDefaults] objectForKey:LINE_WIDTH_KEY] stringValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Actions

- (IBAction)save:(id)sender
{
    CGFloat rawLineWidth = [_lineWidthTextField.text floatValue];
    if (rawLineWidth == 0.0) {
        rawLineWidth = 1.0f;
    }
    NSNumber *lineWidth = @([_lineWidthTextField.text floatValue]);
    [[NSUserDefaults standardUserDefaults] setObject:lineWidth forKey:LINE_WIDTH_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
