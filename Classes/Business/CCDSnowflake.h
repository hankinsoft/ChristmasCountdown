//
//  CCDSnowflake.h
//  ChristmasCounter
//
//  Created by Kyle Hankinson on 04/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define			RADCOUNT	10

@interface CCDSnowflake : UIView
{
	NSUInteger		speedY;
	NSUInteger		frame;

	// Color values
	float	red;
	float	green;
	float   blue;
}

- (void) update;
- (void) updateColor;

@end
