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

//  App Delegate
#import "SGAppDelegate.h"

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
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.textLabel.font = [UIFont fontWithName:kSGFontAmoon size:[UIFont labelFontSize]];
	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.highlightedTextColor = [UIColor blackColor];
	if (cell.highlighted) {
		cell.backgroundColor = [UIColor whiteColor];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (editingStyle) {
	case UITableViewCellEditingStyleDelete: {
		SGDocument *document = [[SGDocumentManager sharedManager] documents][indexPath.row];
		[[SGDocumentManager sharedManager] destroyDocument:document completion:^(BOOL success) {
            if (success) {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
		 }];
		break;
	}
	case UITableViewCellEditingStyleInsert:
	case UITableViewCellEditingStyleNone:
	default:
		break;
	}
}

@end
