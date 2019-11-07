//
//  ChristmasCounterViewController.h
//  ChristmasCounter
//
//  Created by Kyle Hankinson on 04/08/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snowflake.h"
#import "CountdownView.h"
#import "SettingsViewController.h"
#import "ChristmasImageViewController.h"
#import <iAd/iAd.h>
#import "UIScrollViewTouch.h"
#import "PageControl.h"

@interface ChristmasCounterViewController : UIViewController <UIScrollViewDelegate, ADBannerViewDelegate, UIScrollViewTouchDelegate, PageControlDelegate>
{
	CountdownView		* countdownView;

    IBOutlet UIScrollViewTouch *scrollView;
    NSMutableArray *viewControllers;

    // Our info button
    IBOutlet UIButton   * infoButton;
    PageControl         * pageControl;

	// Advertisement stuff
	id                  adView;
	BOOL                bannerIsVisible;

    BOOL                timerEnabled;
    NSDate              * lastUpdatedTime;
}

- (void) disableCountdown;
- (void) enableCountdown;
- (UIImage*) screenshot;
- (void) updateCustomImage;

- (IBAction) onInfo: (id)sender;

@end

