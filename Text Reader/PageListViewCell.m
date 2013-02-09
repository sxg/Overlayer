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
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)resizeAndAddLoadingIndicator
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    //UILabel *label = (UILabel*) [self viewWithTag:100];
    [self.label setCenter:CGPointMake(self.label.center.x + 20, self.label.center.y)];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingIndicator setFrame:CGRectMake(10, self.label.frame.origin.y, 20, 20)];
    [self addSubview:_loadingIndicator];
    [_loadingIndicator startAnimating];
    
    [UIView commitAnimations];
}

- (void)resizeAndRemoveLoadingIndicator
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    //UILabel *label = (UILabel*) [self viewWithTag:100];
    [self.label setCenter:CGPointMake(self.label.center.x - 20, self.label.center.y)];
    
    [_loadingIndicator stopAnimating];
    [_loadingIndicator removeFromSuperview];
    
    [UIView commitAnimations];
}

@end
