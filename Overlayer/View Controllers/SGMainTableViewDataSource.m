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


@implementation SGMainTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSFileManager defaultManager] publicDataPath] error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SGDocumentCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%li", (unsigned long)indexPath.row];
    return cell;
}

@end
