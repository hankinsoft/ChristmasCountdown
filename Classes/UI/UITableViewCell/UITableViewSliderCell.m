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

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle: style
                    reuseIdentifier: reuseIdentifier])
	{
		slider = [[UISlider alloc] initWithFrame: CGRectMake(150, 13, 150, 10)];
		[self addSubview: slider];
    }

    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	// No selection
    [super setSelected:NO animated:animated];
}

@end
