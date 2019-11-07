//
//  UITableViewPickerCell.h
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-10-04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UITableViewPickerCell : UITableViewCell
{
	UIPickerView	* picker;
}

@property (nonatomic,retain) UIPickerView * picker;

@end
