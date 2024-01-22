//
//  ChristmasCountdownAppDelegate.m
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 10-07-05.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ChristmasCountdownAppDelegate.h"

#import "ChristmasCounterViewController.h"
#import "CCDAudioController.h"
#import "CCDCountdownHelper.h"

#import <UserNotifications/UserNotifications.h>

@interface ChristmasCountdownAppDelegate (hidden)

- (void)updateApplicationBadge;
- (void) scheduleLocalNotification;

@end

@implementation ChristmasCountdownAppDelegate

@synthesize audioController;
@synthesize rebuildNotifications;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)          application: (UIApplication *) application
didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
    // By default we do not want to rebuild notifications
    rebuildNotifications = NO;

	// Seed our random
	srandom((unsigned int)time(NULL));

	// If the 'enableBadgeUpdates' key does not already exist, then we will create it with a 'yes' for the default.
	if ( nil == [[NSUserDefaults standardUserDefaults] objectForKey: @"enableBadgeUpdates"] )
	{
		[[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"enableBadgeUpdates"];
	}

	// If the 'enableNotifications' key does not already exist, then we will create it with a 'yes' for the default.
	if ( nil == [[NSUserDefaults standardUserDefaults] objectForKey: @"enableNotifications"] )
    {
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"enableNotifications"];
        
        // Probably the first launch. We want to rebuild notifications and also give a reminder to the users, how to
        // change settings, etc.
        rebuildNotifications = YES;
    }

	// If we do not have any defaults set
	if ( 0 == [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeCount"] )
	{
		// Default our snowflake count to be 50
		[[NSUserDefaults standardUserDefaults] setInteger: 50 forKey:@"SnowflakeCount"];
	} // End of we do not have any defaults set
	
	// If we do not have any defaults set
	if ( 0 == [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeSize"] )
	{
		// Default our snowflake count to be 10
		[[NSUserDefaults standardUserDefaults] setInteger: 10 forKey:@"SnowflakeSize"];
	} // End of we do not have any defaults set
	
	if ( 0 == [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeSpeed"] )
	{
		// Default our snowflake count to be 50
		[[NSUserDefaults standardUserDefaults] setInteger: 5 forKey:@"SnowflakeSpeed"];
	} // End of we do not have any defaults set
	
	// If we do not have any defaults set
	if ( 0 == [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] length] )
	{
		// Default our snowflake count to be 50
		[[NSUserDefaults standardUserDefaults] setObject: @"White" forKey:@"SnowflakeColor"];
	} // End of we do not have any defaults set

	// If we do not have any defaults set
	if ( 0 == [[[NSUserDefaults standardUserDefaults] stringForKey:@"FontColor"] length] )
	{
		// Default our snowflake count to be 50
		[[NSUserDefaults standardUserDefaults] setObject: @"Black" forKey:@"FontColor"];
	} // End of we do not have any defaults set

	////////////////////////////////////////////////////////////////////////////////////////
	// Finished defaults
	////////////////////////////////////////////////////////////////////////////////////////

    
	// Initialize our audio controller
	audioController = [[CCDAudioController alloc] init];

    NSLog(@"Window is: %0.0fx%0.0f", window.frame.size.width, window.frame.size.height);
    NSLog(@"View is: %0.0fx%0.0f", viewController.view.frame.size.width, viewController.view.frame.size.height);

    [window addSubview: viewController.view];
    [window makeKeyAndVisible];

	// Update our application badge
	[self updateApplicationBadge];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	DLog ( @"Application became active!" );

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        NSUInteger notificationsScheduled = (unsigned long)[requests count];
        DLog(@"There are %lu notifications scheduled", notificationsScheduled);
    }];

    [viewController enableCountdown];

    [audioController resume];
} // End of applicationDidBecomeActive

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [audioController pause];

	DLog ( @"Application entered background" );
    [viewController disableCountdown];

	[self updateNotifications];
} // End of applicationDidEnterBackground

- (void)applicationWillTerminate:(UIApplication *)application
{
    DLog ( @"Application terminating" );
    [viewController disableCountdown];
} // End of applicationWillTerminate

- (void) updateApplicationBadge
{
	// If we have the badge enabled, then we will update it. Otherwise we just clear it.
	// Note: It would be nice if Apple let us actually see if the user selected the badge for push
	// notifications rather than our own hackery.
	if ( [self isBadgeEnabled] )
	{
        // Set our badge to be the number of days away from today (PLUS ONE so that it does not say 0 days, on the 24'th,
		// when it is really 0 days, 15 hours, etc
        [UIApplication sharedApplication].applicationIconBadgeNumber = [CCDCountdownHelper daysAwayFromDate: [NSDate date]];
	} // End of badge is enabled
	else
	{
		// Make sure the badge is blank
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	}
} // End of updateApplicationBadge

- (void) updateCustomImage
{
    [viewController updateCustomImage];
}

- (void) queueNotifications
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    BOOL enableNotifications = [[NSUserDefaults standardUserDefaults] boolForKey: @"enableNotifications"];
    BOOL showBadge = [self isBadgeEnabled];

    // First, clear any pending notifications
    [center removeAllPendingNotificationRequests];
    
    // If notifications are not enabled, that's it. Do nothing else.
    if (!enableNotifications) {
        return;
    }

    // Calculate the start date for notifications
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    
    // Using our current year, set it to be Christmas day
    NSDateComponents *christmasComponents = [[NSDateComponents alloc] init];
    christmasComponents.year = [components year];
    christmasComponents.month = 12; // December
    christmasComponents.day = 25; // Christmas Day
    
    // Calculate the start date (1 day after Christmas)
    NSDate *startDate = [calendar dateFromComponents:christmasComponents];
    startDate = [startDate dateByAddingTimeInterval:24 * 60 * 60]; // Add 1 day
    
    // Get the current date again
    now = [NSDate date];
    
    // Get the time interval between now and the start date
    NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:now];
    
    // Create up to 10 notifications
    for (NSInteger i = 0; i < 10; i++) {
        // If we wrap, then we need to re-calculate.
        if (timeInterval < 0) {
            timeInterval = 24 * 60 * 60; // 1 day
        }
        
        NSString *countdownString = nil;
        
        if (timeInterval > 1) {
            countdownString = [NSString stringWithFormat:@"There are %.0f Days Until Christmas.", timeInterval / (24 * 60 * 60)];
        } else if (timeInterval == 1) {
            countdownString = @"There is one day until Christmas.";
        } else if (timeInterval == 0) {
            countdownString = @"Merry Christmas!";
        }
        
        // Create a notification content
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.body = countdownString;
        content.sound = [UNNotificationSound defaultSound];
        
        // Create a notification trigger
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInterval repeats:NO];
        
        // Create a notification request
        NSString *identifier = [NSString stringWithFormat:@"ChristmasCountdownNotification%d", (int)i];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        
        // Schedule the notification
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error scheduling notification: %@", error);
            }
        }];
        
        DLog(@"Queued (%.0f)", timeInterval / (24 * 60 * 60));
        
        // Next day
        timeInterval -= 24 * 60 * 60;
    }
}

- (void) updateNotifications
{
    // Only rebuild the notifications if necessary (settings toggled) or there are less than 10 left
    if (rebuildNotifications)
    {
        [self queueNotifications];
    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            NSUInteger notificationsScheduled = (unsigned long)[requests count];
            if(notificationsScheduled < 10)
            {
                [self queueNotifications];
            }
        }];
    }
} // End of updateNotifications

static NSCalendar * gregorian = nil;
- (NSCalendar *) gregorianCalendar
{
	@synchronized ( self )
	{
		if ( nil == gregorian )
		{
            gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
		} // End of gregorian calendar was nil
	} // End of synchronized

	return gregorian;
} // End of gregorianCalendar

#pragma mark -
#pragma mark Misc

- (bool) isBadgeEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey: @"enableBadgeUpdates"];
} // End of isBadgeEnabled

+ (ChristmasCountdownAppDelegate*) instance
{
	return (ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (BOOL) iPad
{
	return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
} // End of current device is iPad

+ (BOOL) iPhone5
{
            return UIDevice.currentDevice.userInterfaceIdiom
            == UIUserInterfaceIdiomPhone
            && UIScreen.mainScreen.bounds.size.height
            * UIScreen.mainScreen.scale >= 1136;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

@end

