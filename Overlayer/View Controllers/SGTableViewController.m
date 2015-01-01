//
//  SGTableViewController.m
//  Overlayer
//
//  Created by Satyam Ghodasara on 11/17/14.
//  Copyright (c) 2014 Satyam Ghodasara. All rights reserved.
//

#import "SGTableViewController.h"
#import "SGMainViewController.h"
#import "SGDocumentCell.h"
#import "SGNewDocumentCell.h"
#import "SGDocumentManager.h"
#import "SGDocument.h"
#import "SGAppDelegate.h"


NSString *SGTableViewControllerDidSelectDocumentNotification = @"SGTableViewControllerDidSelectDocumentNotification";
NSString *SGTableViewControllerDidNameNewDocumentNotification = @"SGTableViewControllerDidNameNewDocumentNotification";
NSString *SGTableViewControllerDidNameNewFolderNotification = @"SGTableViewControllerDidNameNewFolderNotification";

NSString *SGDocumentKey = @"SGDocumentKey";
NSString *SGDocumentNameKey = @"SGDocumentNameKey";
NSString *SGFolderNameKey = @"SGFolderNameKey";
NSString *SGURLKey = @"SGURLKey";

@interface SGTableViewController ()

@property (readwrite, strong, nonatomic) SGDocumentManager *manager;
@property (readwrite, assign) BOOL isCreatingNewDocument;
@property (readwrite, assign) BOOL isCreatingNewFolder;
@property (readwrite, assign) BOOL didNameNewDocument;
@property (readwrite, strong, nonatomic) NSString *theNewDocumentName;
@property (readwrite, assign) BOOL didTextFieldReturn;
@property (readwrite, weak, nonatomic) SGDocumentCell *processingDocumentCell;

@end

@implementation SGTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style URL:(NSURL *)url;
{
    self = [super initWithStyle:style];
    if (self) {
        self.manager = [[SGDocumentManager alloc] init];
        [self.manager moveToURL:url];
        self.navigationItem.title = [[self.manager.currentURL pathComponents] lastObject];
        self.navigationController.navigationBar.tintColor  = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    if (!self.manager) {
        self.manager = [[SGDocumentManager alloc] init];
    }
    self.isCreatingNewDocument = NO;
    self.didNameNewDocument = NO;
    self.theNewDocumentName = nil;
    self.didTextFieldReturn = NO;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    __block SGTableViewController *blockSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:SGMainViewControllerDidTapNewDocumentButtonNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        blockSelf.isCreatingNewDocument = YES;
        [blockSelf.tableView reloadData];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SGMainViewControllerDidStartCreatingDocumentNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        blockSelf.processingDocumentCell.activityIndicatorView.hidden = NO;
        [blockSelf.processingDocumentCell.activityIndicatorView startAnimating];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SGMainViewControllerDidFinishCreatingDocumentNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        blockSelf.isCreatingNewDocument = NO;
        blockSelf.didNameNewDocument = NO;
        blockSelf.theNewDocumentName = nil;
        blockSelf.didTextFieldReturn = NO;
        [blockSelf.processingDocumentCell.activityIndicatorView stopAnimating];
        blockSelf.processingDocumentCell.userInteractionEnabled = YES;
        [blockSelf.tableView reloadData];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SGMainViewControllerDidTapNewFolderButtonNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        blockSelf.isCreatingNewFolder = YES;
        [blockSelf.tableView reloadData];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:SGMainViewControllerDidFinishCreatingFolderNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        blockSelf.isCreatingNewFolder = NO;
        blockSelf.didTextFieldReturn = NO;
        [blockSelf.tableView reloadData];
    }];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger newCellCount = (self.isCreatingNewDocument || self.isCreatingNewFolder) ? 1 : 0;
    return [[self.manager contentsOfCurrentFolder] count] + newCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (((self.isCreatingNewDocument && !self.didNameNewDocument) || self.isCreatingNewFolder) && indexPath.row == [[self.manager contentsOfCurrentFolder] count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SGNewDocumentCell"];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"SGNewDocumentCell" bundle:nil] forCellReuseIdentifier:@"SGNewDocumentCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"SGNewDocumentCell"];
        }
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
        cell.userInteractionEnabled = NO;
    } else {
        if (indexPath.row < [[self.manager contentsOfCurrentFolder] count]) {
            if (indexPath.row < [[self.manager folderNames] count]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SGFolderCell"];
                if (!cell) {
                    [tableView registerNib:[UINib nibWithNibName:@"SGFolderCell" bundle:nil] forCellReuseIdentifier:@"SGFolderCell"];
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SGFolderCell"];
                }
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SGDocumentCell"];
                if (!cell) {
                    [tableView registerNib:[UINib nibWithNibName:@"SGDocumentCell" bundle:nil] forCellReuseIdentifier:@"SGDocumentCell"];
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SGDocumentCell"];
                }
            }
            cell.textLabel.text = [self.manager contentsOfCurrentFolder][indexPath.row];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SGDocumentCell"];
            if (!cell) {
                [tableView registerNib:[UINib nibWithNibName:@"SGDocumentCell" bundle:nil] forCellReuseIdentifier:@"SGDocumentCell"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"SGDocumentCell"];
            }
            cell.textLabel.text = self.theNewDocumentName;
            self.processingDocumentCell = (SGDocumentCell *)cell;
            self.processingDocumentCell.userInteractionEnabled = NO;
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        if (cell.highlighted) {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    cell.textLabel.font = [UIFont fontWithName:kSGFontAmoon size:[UIFont labelFontSize]];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            NSString *documentName = [self.manager contentsOfCurrentFolder][indexPath.row];
            NSString *documentFolderName = [documentName stringByAppendingString:@".overlayer"];
            [self.manager destroyDocumentAtURL:[self.manager.currentURL URLByAppendingPathComponent:documentFolderName isDirectory:YES]];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case UITableViewCellEditingStyleInsert:
        case UITableViewCellEditingStyleNone:
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  If selected a folder
    if (indexPath.row < [[self.manager folderNames] count]) {
        NSString *subfolderName = [self.manager folderNames][indexPath.row];
        NSURL *url = [self.manager.currentURL URLByAppendingPathComponent:subfolderName];
        SGTableViewController *tableVC = [[SGTableViewController alloc] initWithStyle:UITableViewStylePlain URL:url];
        [self.navigationController pushViewController:tableVC animated:YES];
    }
    //  If selected a document
    else {
        NSString *documentFolderName;
        if (indexPath.row >= [self tableView:tableView numberOfRowsInSection:indexPath.section]) {
            documentFolderName = self.theNewDocumentName;
        } else {
            documentFolderName = [self.manager contentsOfCurrentFolder][indexPath.row];
        }
        documentFolderName = [documentFolderName stringByAppendingString:@".overlayer"];
        SGDocument *document = [SGDocument documentWithContentsOfURL:[self.manager.currentURL URLByAppendingPathComponent:documentFolderName isDirectory:YES]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SGTableViewControllerDidSelectDocumentNotification object:self userInfo:@{SGDocumentKey: document}];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (((self.isCreatingNewDocument && !self.didNameNewDocument) || self.isCreatingNewFolder) && indexPath.row == [[self.manager contentsOfCurrentFolder] count]) {
        ((SGNewDocumentCell *)cell).textField.text = nil;
        ((SGNewDocumentCell *)cell).textField.delegate = self;
        [((SGNewDocumentCell *)cell).textField becomeFirstResponder];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.didTextFieldReturn = YES;
    if (self.isCreatingNewDocument) {
        self.didNameNewDocument = YES;
        self.isCreatingNewDocument = YES;
        self.theNewDocumentName = textField.text;
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:SGTableViewControllerDidNameNewDocumentNotification object:nil userInfo:@{SGDocumentNameKey: textField.text, SGURLKey: self.manager.currentURL}];
    } else if (self.isCreatingNewFolder) {
        self.isCreatingNewFolder = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SGTableViewControllerDidNameNewFolderNotification object:nil userInfo:@{SGFolderNameKey: textField.text, SGURLKey: self.manager.currentURL}];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!self.didTextFieldReturn) {
        self.didNameNewDocument = NO;
        self.isCreatingNewDocument = NO;
        self.isCreatingNewFolder = NO;
        self.theNewDocumentName = nil;
        [self.tableView reloadData];
    }
}

@end
