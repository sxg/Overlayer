//
//  PageListViewCell.m
//  Text Reader
//
//  Created by Satyam Ghodasara on 2/9/13.
//  Copyright (c) 2013 Satyam Ghodasara. All rights reserved.
//

/*
    This is a subclass of UITableViewCell, and it is used for PageListViewController's table. This custom cell contains a UILabel that can
    shift to the right and back to the original position with an animation to allow room for a UIActivityIndicator to indicate that the page
    the cell represents is currently being processed.
 
    _loadingIndicator is the UIActivityIndicator that will appear to the left of the UILabel when the cell's page is being processed
    _label is the UILabel that displays the name of the page this cell represents, and it can shift to make room for _loadingIndicator to the left
    _isProcessing is a boolean value that marks whether the current cell's page is processing
 */

#import "PageListViewCell.h"

@implementation PageListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //  The cell is never processing when first created
        _isProcessing = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public methods

//  Shift the UILabel to the right 20px and add an activity indicator in the newly created space. Animation is optional.
- (void)resizeAndAddLoadingIndicator:(BOOL)animated
{
    //  Setup the animation if desired
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    }
    
    //  Move the center of the label 20px to the right
    [self.label setCenter:CGPointMake(190, self.label.center.y)];
    
    //  Execute the animation if desired
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    //  Create, setup, and add the loading indicator to the cell, then start its animation
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingIndicator setFrame:CGRectMake(10, self.label.frame.origin.y, 20, 20)];
    [self addSubview:_loadingIndicator];
    [_loadingIndicator startAnimating];
}

//  Shift the UILabel back to the original position and remove the activity indicator. Animation is optional.
- (void)resizeAndRemoveLoadingIndicator:(BOOL)animated
{
    //  Setup the animation if desired
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    }
    
    //  Move the center of the label 20px to the left
    [self.label setCenter:CGPointMake(170, self.label.center.y)];
    
    //  Execute the animation if desired
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    //  Stop the activity indicator's animation and remove it from the cell
    [_loadingIndicator stopAnimating];
    [_loadingIndicator removeFromSuperview];
}

@end
