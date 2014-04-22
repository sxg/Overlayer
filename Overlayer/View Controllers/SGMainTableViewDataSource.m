//
//  SGMainTableViewDataSource.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 4/21/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGMainTableViewDataSource.h"

//  Frameworks
#import <StandardPaths/StandardPaths.h>

//  Utilities
#import "SGDocumentManager.h"


@implementation SGMainTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[SGDocumentManager sharedManager] documents] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SGDocumentCell"];
    cell.textLabel.text = [[[SGDocumentManager sharedManager] documents][indexPath.row] title];
    return cell;
}

@end
