//
//  UITableViewPickerCell.m
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-10-04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UITableViewPickerCell.h"


@implementation UITableViewPickerCell

@synthesize picker;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
		picker = [[UIPickerView alloc] initWithFrame: CGRectMake(150, 13, 150, 10)];
		[self addSubview: picker];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
