//
//  PageListViewCell.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/9/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

#import "PageListViewCell.h"

@implementation PageListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _isProcessing = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)resizeAndAddLoadingIndicator:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    }
    
    [self.label setCenter:CGPointMake(190, self.label.center.y)];
    
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingIndicator setFrame:CGRectMake(10, self.label.frame.origin.y, 20, 20)];
    [self addSubview:_loadingIndicator];
    [_loadingIndicator startAnimating];
}

- (void)resizeAndRemoveLoadingIndicator:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    }
    
    [self.label setCenter:CGPointMake(170, self.label.center.y)];
    
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    [_loadingIndicator stopAnimating];
    [_loadingIndicator removeFromSuperview];
}

@end
