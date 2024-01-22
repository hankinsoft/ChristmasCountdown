//
//  CCDSettingsViewController.h
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 10-07-05.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSnowflakesNeedUpdate       @"snowflakesNeedUpdate"

@class UITableViewSliderCell;
@class ColorPickerViewController;
@class MusicPickerViewController;
@class CustomImageViewController;

@class ChristmasCounterViewController;
@class FBLoginView;

@interface CCDSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	NSDictionary						* settingsCells;

	IBOutlet UITableView                * tableView;

    // For iPhone
	ChristmasCounterViewController		* christmasCounterViewController;
    FBLoginView                         * fbLoginView;
}

+ (void) postSnowflakesNeedUpdate;

@property (nonatomic, retain) ChristmasCounterViewController     * christmasCounterViewController;

@end
