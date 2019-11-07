//
//  ColorPickerViewController.h
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-10-04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColorPickerViewController : UIViewController <UIAlertViewDelegate>
{
	NSArray		    * generalArray;
	NSArray		    * holidayArray;
//	UITableViewCell * checkedCell;

    NSString        * property;
    IBOutlet        UITableView * colorTableView;
}

@property(nonatomic, retain) NSString * property;
@property(nonatomic, retain) NSArray  * generalArray;
@property(nonatomic, retain) NSArray  * holidayArray;

@end

