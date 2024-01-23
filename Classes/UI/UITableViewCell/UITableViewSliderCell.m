//
//  UITableViewSliderCell.m
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-09-05.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UITableViewSliderCell.h"


@implementation UITableViewSliderCell
{
	UISlider		* slider;
}

@synthesize slider;

- (id) initWithStyle: (UITableViewCellStyle) style
     reuseIdentifier: (NSString *) reuseIdentifier
{
    if (self = [super initWithStyle: style
                    reuseIdentifier: reuseIdentifier])
	{
        self.selectionStyle = UITableViewCellSelectionStyleNone;

		slider = [[UISlider alloc] initWithFrame: CGRectMake(150, 13, 150, 10)];

        // Disable autoresizing mask translation
        slider.translatesAutoresizingMaskIntoConstraints = NO;

        // Add the slider to the cell's content view
        [self.contentView addSubview:slider];

        // Set constraints
        [self setupSliderConstraints];
    }

    return self;
}

- (void) setupSliderConstraints
{
    // Constraints for the slider
    [NSLayoutConstraint activateConstraints:@[
        // Horizontal position, 150 points from leading margin
        [slider.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant: -20],
        // Vertical centering in the cell
        [slider.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        // Set the slider width
        [slider.widthAnchor constraintEqualToConstant:150],
        // Optional: Set the slider height
        // [slider.heightAnchor constraintEqualToConstant:10],
    ]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	// No selection
    [super setSelected:NO animated:animated];
}

@end
