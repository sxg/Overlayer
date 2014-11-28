//
//  SGTableViewController.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 11/17/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGTableViewController.h"
#import "SGDocumentManager.h"
#import "SGDocument.h"
#import "SGAppDelegate.h"


NSString *SGTableViewControllerDidSelectDocumentNotification = @"SGTableViewControllerDidSelectDocumentNotification";
NSString *SGDocumentKey = @"SGDocumentKey";


@implementation SGTableViewController

static SGDocumentManager *_manager;

+ (void)initialize
{
    _manager = [[SGDocumentManager alloc] init];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_manager folders] count] + [[_manager documents] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SGDocumentCell"];
    if (indexPath.row < [[_manager folders] count]) {
        cell.textLabel.text = [_manager folders][indexPath.row];
    } else {
        NSString *documentFolderName = [_manager documents][[[_manager folders] count] + indexPath.row];
        SGDocument *document = [SGDocument documentWithContentsOfURL:[_manager.currentURL URLByAppendingPathComponent:documentFolderName isDirectory:YES]];
        cell.textLabel.text = document.title;
    }
    
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
            NSString *documentFolderName = [_manager documents][[[_manager folders] count] + indexPath.row];
            [_manager destroyDocumentAtURL:[_manager.currentURL URLByAppendingPathComponent:documentFolderName isDirectory:YES]];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case UITableViewCellEditingStyleInsert:
        case UITableViewCellEditingStyleNone:
        default:
            break;
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *documentFolderName = [_manager documents][[[_manager folders] count] + indexPath.row];
    SGDocument *document = [SGDocument documentWithContentsOfURL:[_manager.currentURL URLByAppendingPathComponent:documentFolderName isDirectory:YES]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SGTableViewControllerDidSelectDocumentNotification object:self userInfo:@{SGDocumentKey: document}];
}

@end
