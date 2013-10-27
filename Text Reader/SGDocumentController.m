//
//  SGDocumentController.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 10/25/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "SGDocumentController.h"
#import "SGDocumentsListController.h"
#import "SGCollectionsListController.h"
#import "SGSettingsController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SGCollection.h"

@interface SGDocumentController ()

@property (nonatomic, readwrite, strong) IBOutlet UIScrollView *documentScrollView;

@property (nonatomic, readonly, weak) SGCollection *collection;

@end

@implementation SGDocumentController

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
    
    SGDocumentsListController *docListVC = (SGDocumentsListController *)([self.splitViewController viewControllers][0]);
    _collection = docListVC.collection;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDocument:(SGDocument *)document
{
    _document = document;
    
    [self.navigationItem setTitle:document.title];
    UIImageView *documentImageView = [[UIImageView alloc] initWithImage:_document.image];
    
    [[_documentScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_documentScrollView addSubview:documentImageView];
    [_documentScrollView setContentSize:documentImageView.bounds.size];
}

#pragma mark - UI Actions

- (IBAction)drawLines:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud setLabelText:@"Drawing Lines"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
        
        NSNumber *lineWidth = [[NSUserDefaults standardUserDefaults] objectForKey:LINE_WIDTH_KEY];
        [_document drawLinesWithLineWidth:[lineWidth floatValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self setDocument:_document];
            NSString *path = [[[_collection savePath] stringByAppendingPathComponent:_document.title] stringByAppendingPathExtension:@"png"];
            [UIImagePNGRepresentation(_document.image) writeToFile:path atomically:YES];
        });
    });
}

@end
