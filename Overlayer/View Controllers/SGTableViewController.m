//
//  SGTableViewController.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 11/17/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGTableViewController.h"
#import "SGDocumentManager.h"
#import "SGAppDelegate.h"


@implementation SGTableViewController

static NSURL *_currentURL;

+ (void)initialize
{
    _currentURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
//    return [[SGDocumentManager documentsAtURL:_currentURL] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SGDocumentCell"];
//    cell.textLabel.text = [SGDocumentManager documentsAtURL:_currentURL][indexPath.row];
//    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.textLabel.font = [UIFont fontWithName:kSGFontAmoon size:[UIFont labelFontSize]];
//    cell.backgroundColor = [UIColor clearColor];
//    cell.textLabel.highlightedTextColor = [UIColor blackColor];
//    if (cell.highlighted) {
//        cell.backgroundColor = [UIColor whiteColor];
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
//            NSURL *documentURL = [_currentURL URLByAppendingPathComponent:[SGDocumentManager documentsAtURL:_currentURL][indexPath.row]];
//            [SGDocumentManager destroyDocumentAtURL:documentURL completion:^(BOOL success) {
//                if (success) {
//                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//                }
//            }];
            break;
        }
        case UITableViewCellEditingStyleInsert:
        case UITableViewCellEditingStyleNone:
        default:
            break;
    }
}

@end
