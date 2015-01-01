//
//  SGNavigationController.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 1/1/15.
//  Copyright (c) 2015 Satyam Ghodasara. All rights reserved.
//

#import "SGNavigationController.h"
#import "SGAppDelegate.h"


@interface SGNavigationController ()

@end

@implementation SGNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.navigationBar.titleTextAttributes = @{
                                               NSFontAttributeName: [UIFont fontWithName:kSGFontAmoon size:18.0f],
                                               NSForegroundColorAttributeName: [UIColor whiteColor]
                                               };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
