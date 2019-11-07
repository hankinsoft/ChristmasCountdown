//
//  ChristmasCountdownAppDelegate.h
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 10-07-05.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"

//@class AudioController;

@class ChristmasImageViewController;
@class ChristmasCounterViewController;

@interface ChristmasCountdownAppDelegate : NSObject <UIApplicationDelegate>
{
    IBOutlet UIWindow                       * window;

    IBOutlet ChristmasCounterViewController * viewController;

	AudioController							* audioController;
    BOOL									rebuildNotifications;
}

@property (nonatomic, retain) AudioController					* audioController;
@property (nonatomic, assign) BOOL								rebuildNotifications;

+ (ChristmasCountdownAppDelegate*) instance;
+ (BOOL) iPad;
+ (BOOL) iPhone5;

- (void) updateCustomImage;
- (void) updateApplicationBadge;
- (void) updateNotifications;
- (bool) isBadgeEnabled;
- (NSCalendar *) gregorianCalendar;

@end
