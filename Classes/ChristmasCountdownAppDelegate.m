//
//  ChristmasCountdownAppDelegate.m
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 10-07-05.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ChristmasCountdownAppDelegate.h"

#import "ChristmasCounterViewController.h"
#import "AudioController.h"
#import "CountdownHelper.h"

@interface ChristmasCountdownAppDelegate (hidden)

- (void)updateApplicationBadge;
- (void) scheduleLocalNotification;

@end

@implementation ChristmasCountdownAppDelegate

@synthesize audioController;
@synthesize rebuildNotifications;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
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

        UIAlertView *reminderAlert = [[UIAlertView alloc] initWithTitle: @"Don't Forget!"
                                                       message: @"You can tap the info button to launch the settings screen, which allows you "
                                      @"to change a variety of options including the snowflake colors and the background music.\r\n\r\nYou can also switch between backgrounds by sliding a finger on the main screen."
                                                      delegate: self
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles: nil];

        [reminderAlert show];
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
	audioController = [[AudioController alloc] init];

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
    DLog ( @"There are %lu notifications scheduled", [[[UIApplication sharedApplication] scheduledLocalNotifications] count] );

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
        [UIApplication sharedApplication].applicationIconBadgeNumber = [CountdownHelper daysAwayFromDate: [NSDate date]];
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

- (void) updateNotifications
{
#define DAY	( 86400 )

    // Only rebuild the notifications, if we have to for some reason (settings toggled), OR (see blew)
    if ( rebuildNotifications ||
        (
         // We have notifications enabled and there are less than 10 left
         [[NSUserDefaults standardUserDefaults] boolForKey: @"enableNotifications"]
         && [[[UIApplication sharedApplication] scheduledLocalNotifications] count] < 10 ) )
    {
        // No longer need to re-build notifications
        rebuildNotifications = NO;
        
        // First, clear any notifications
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        // If notifications are not enabled, then thats it. Do nothing else.
        if ( ![[NSUserDefaults standardUserDefaults] boolForKey: @"enableNotifications"] )
        {
            return;
        }
        
		// We need to make sure that if we are past december 25 but before Jan 1, to use the next year,
		// so that we do not display -1, -2, etc days until christmas.
		NSDateComponents *currentDateComponents = [[self gregorianCalendar] components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate: [NSDate date]];
        
		// Using our current year, set it to be christmas day
		NSString *dateStr = [[NSString alloc] initWithFormat: @"%4ld%0.2ld%0.2ld",
							 (long)[currentDateComponents year], (long)[currentDateComponents month], (long)[currentDateComponents day]];
        
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyyMMdd"];

		// Get our date
        NSDate * startDate = [[dateFormat dateFromString:dateStr] dateByAddingTimeInterval: DAY];

		BOOL showBadge = [self isBadgeEnabled];
        
        // Get our days away (minus one to make up the fact it's sent at midnight)
		NSInteger daysAway = [CountdownHelper daysAwayFromDate: startDate] - 1;
        
		// Create up to 65 notifications
		for ( NSInteger i = [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
			 i < 100;
			 ++i )
		{
            NSString * countdownString = nil;
            
            // If we wrap, then we weed to re-calculate.
            if ( daysAway < 0 )
            {
                daysAway = [CountdownHelper daysAwayFromDate: startDate];
            }
            
            if ( daysAway > 1 )
            {
                countdownString = [NSString stringWithFormat: @"There are %ld Days Until Christmas.", (long)daysAway ];
            }
            else if ( 1 == daysAway )
            {
                countdownString = @"There is one day until Christmas.";
            }
            else if ( 0 == daysAway )
            {
                countdownString = @"Merry Christmas!";
            }
            
			UILocalNotification * localNotification = [[UILocalNotification alloc] init];
			[localNotification setFireDate: startDate];
			[localNotification setAlertAction: nil];
			[localNotification setAlertBody: countdownString];
            
			// Badge is always one extra day
			[localNotification setApplicationIconBadgeNumber: ( showBadge ? daysAway : 0 )];
            
			[[UIApplication sharedApplication] scheduleLocalNotification: localNotification];
            DLog ( @"Queued (%ld)", daysAway );

			// Next day
			startDate = [startDate dateByAddingTimeInterval: DAY];
            daysAway--;
		}
	} // End of rebuildNotifications
} // End of updateNotifications

static NSCalendar * gregorian = nil;
- (NSCalendar *) gregorianCalendar
{
	@synchronized ( self )
	{
		if ( nil == gregorian )
		{
			gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
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

