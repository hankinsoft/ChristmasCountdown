//
//  UIScrollViewTouch.m
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-11-07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UIScrollViewTouch.h"
#import "Snowflake.h"

@interface UIScrollViewTouch()

- (void)initSnowflakes;

@end

@implementation UIScrollViewTouch

@synthesize touchDelegate;

- (void) initTimer
{
	// Create a schedule which we will use for updating our snowflakes
	[NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void) initSnowflakes
{
	// Create our snowflakes array
	snowflakes = [[NSMutableArray alloc] initWithCapacity: [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeCount"]];
    
    NSInteger snowflakeCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeCount"];
    DLog ( @"Loading %ld snowflakes", snowflakeCount );
	for ( int i = 0; i < snowflakeCount; ++i )
	{
		// Create our snowflake and add it to our array
		Snowflake * snowflake = [[Snowflake alloc] init];
		[snowflakes addObject: snowflake];
		[self addSubview: snowflake];
        [self bringSubviewToFront: snowflake];
	} // End of snowflake loop
} // End of initSnowflakes

- (void)updateTimer:(id)sender
{
	// Loop though our snowflakes
	for ( int i = 0; i < [snowflakes count]; ++i )
	{
		// Update our timer
		[(Snowflake*)[snowflakes objectAtIndex: i] update];
	}
} // End of updateTimer

- (void) updateSnowflakes
{
    // Delete all of our snowflakes
	while ( [snowflakes count] > 0 )
	{
		Snowflake * snowflake = (Snowflake*)[snowflakes lastObject];
        [snowflake removeFromSuperview];
        [snowflakes removeLastObject];
	}

    // Init our snowflakes
    [self initSnowflakes];
} // End of updateSnowflakes

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];

	// We only support single touches, so anyObject retrieves just that touch from touches
	UITouch *touch = [[event allTouches] anyObject];

    if ([touch tapCount] == 1)
    {
        [touchDelegate singleTapped];
    }
	else if ([touch tapCount] == 2)
	{
        [touchDelegate doubleTapped];
    }
}


@end
