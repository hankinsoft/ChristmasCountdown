//
//  ChristmasCounterViewController.h
//  ChristmasCounter
//
//  Created by Kyle Hankinson on 04/08/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDSnowflake.h"
#import "CCDCountdownView.h"
#import "CCDSettingsViewController.h"
#import "ChristmasImageViewController.h"
#import <iAd/iAd.h>
#import "UIScrollViewTouch.h"
#import "CCDPageControl.h"

@interface ChristmasCounterViewController : UIViewController <UIScrollViewDelegate, UIScrollViewTouchDelegate, PageControlDelegate>

- (void) disableCountdown;
- (void) enableCountdown;
- (UIImage*) screenshot;
- (void) updateCustomImage;

- (IBAction) onInfo: (id)sender;

@end

