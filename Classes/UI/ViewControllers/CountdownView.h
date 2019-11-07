//
//  CountdownView.h
//  ChristmasCounter
//
//  Created by Kyle Hankinson on 04/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CountdownView : UIView
{
	NSDate		* christmasDay;
	BOOL		countdownEnabled;
}

- (void) disableCountdown;
- (void) enableCountdown;
+ (NSString*) countdownStringWithNewlines: (BOOL) enableNewline;

@end
