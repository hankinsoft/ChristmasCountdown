//
//  CountdownView.m
//  ChristmasCounter
//
//  Created by Kyle Hankinson on 04/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CountdownView.h"
#import "ChristmasCountdownAppDelegate.h"
#import "CountdownHelper.h"

@interface CountdownView ()

- (void)updateTimer:(id)sender;

@property (nonatomic, assign) 	BOOL		countdownEnabled;

@end

@implementation CountdownView

@synthesize countdownEnabled;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
        // No user interaction
        self.userInteractionEnabled = NO;

		countdownEnabled = YES;
		
		// We need to make sure that if we are past december 25 but before Jan 1, to use the next year,
		// so that we do not display -1, -2, etc days until christmas.
		NSDateComponents *currentDateComponents =
		[[[ChristmasCountdownAppDelegate instance] gregorianCalendar] components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate: [NSDate date]];
		
		NSInteger year = [currentDateComponents year];
		if ( 12 == [currentDateComponents month] && 25 < [currentDateComponents day] )
		{
			++year;
		}
		
		// Make our control opaque
		[self setOpaque: NO];
		
		// Using our current year, set it to be christmas day
		NSString *dateStr = [[NSString alloc] initWithFormat: @"%4ld1225", (long)year];
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyyMMdd"];
		christmasDay = [dateFormat dateFromString:dateStr];
		
		// Update once a second
		[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    }
    return self;
}
- (void) disableCountdown
{
	countdownEnabled = NO;
}

- (void) enableCountdown
{
	countdownEnabled = YES;
}

- (void)updateTimer:(id)sender
{
	if ( countdownEnabled )
	{
		// Redraw
		[self setNeedsDisplay];
	}
}

+ (NSString*) countdownStringWithNewlines: (BOOL) enableNewline
{
	NSDateComponents *currentDateComponents =
	[[[ChristmasCountdownAppDelegate instance] gregorianCalendar] components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate: [NSDate date]];
	
	NSString * countdownString;
	
	// If we are christmas day, then we do not need to display anything
	if ( 25 == [currentDateComponents day] && 12 == [currentDateComponents month] )
	{
		countdownString = @"\r\nMerry Christmas!";
	}
	else
	{
		// Figure out how far away it is
		NSTimeInterval timeInterval = [CountdownHelper.christmasDay timeIntervalSinceNow];

		int days    = floor(timeInterval / 86400);
		int hours   = (int)floor(timeInterval / 3600)%24;
		int minutes = (int)floor(timeInterval / 60)%60;
		int seconds = (int)round(timeInterval - minutes * 60)%60;
		
		if ( enableNewline )
		{
            if([ChristmasCountdownAppDelegate iPad])
            {
                countdownString = [NSString stringWithFormat: @"There are %d Day%s, %d Hour%s\r\n%d Minute%s and %d Second%s Until Christmas",
                                   days, 1 == days ? "" : "s",
                                   hours, 1 == hours ? "" : "s",
                                   minutes, 1 == minutes ? "" : "s",
                                   seconds, 1 == seconds ? "" : "s"];
            } // End of iPad
            else
            {
                countdownString = [NSString stringWithFormat: @"There are\r\n%d Day%s, %d Hour%s\r\n%d Minute%s and %d Second%s\r\nUntil Christmas.",
                                   days, 1 == days ? "" : "s",
                                   hours, 1 == hours ? "" : "s",
                                   minutes, 1 == minutes ? "" : "s",
                                   seconds, 1 == seconds ? "" : "s"];
            } // End of iPhone
		} // End of enableNewLine
		else
		{
			countdownString = [NSString stringWithFormat: @"There are %d Day%s, %d Hour%s %d Minute%s and %d Second%s Until Christmas.",
							   days, 1 == days ? "" : "s",
							   hours, 1 == hours ? "" : "s",
							   minutes, 1 == minutes ? "" : "s",
							   seconds, 1 == seconds ? "" : "s"];			
		} // End of no !enableNewLine
	} // End of it is not christmas

	// Return our countdownString
	return countdownString;
} // End of countdownStringWithNewlines

- (void)drawRect:(CGRect)rect
{
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
	// Clear the contents
    CGContextClearRect(contextRef, rect);
    
    int red, green, blue;
    
    NSString * colorString = [[NSUserDefaults standardUserDefaults] stringForKey: @"FontColor"];
	// White
	if ( [colorString isEqualToString: @"White"] )
	{
		// Set our color
		red = 255;
		green = 255;
		blue = 255;
	}
	else if ( [colorString isEqualToString: @"Black"] )
	{
		// Set our color
		red   = 0;
		green = 0;
		blue  = 0;
	}
	else if ( [colorString isEqualToString: @"Pink"] )
	{
		red   = 255;
		green = 0;
        blue  = 128;
	}
	else if ( [colorString isEqualToString: @"Red"] )
	{
		red   = 255;
		green = 0;
		blue  = 0;
	} // End of Blue
	else if ( [colorString isEqualToString: @"Blue"] )
	{
		red   = 0;
		green = 0;
		blue  = 255;
	} // End of Blue
	else if ( [colorString isEqualToString: @"Yellow"] )
	{
		red = 251;
		green = 236;
		blue = 93;
	} // End of Yellow
	else if ( [colorString isEqualToString: @"Green"] )
	{
        red   = 0;
		green = 255;
		blue  = 0;
	} // End of Green
	else if ( [colorString isEqualToString: @"Purple"] )
	{
		red   = 141;
		green = 50;
        blue  = 150;
	} // End of Green
    else
    {
        NSLog(@"Unknown color: %@", colorString);
    }

	// Draw our snowflake
    CGContextSetRGBFillColor(contextRef, red/255.0, green/255., blue/255.0, 1.0f);

    float fontSize = 0;
    if([ChristmasCountdownAppDelegate iPad])
    {
        fontSize = 20.0f;
    }
    else
    {
        fontSize = 15.0f;
    }

    [[CountdownView countdownStringWithNewlines: YES] drawInRect: rect
                                                        withFont: [UIFont fontWithName: @"zapfino" size: fontSize]
                                                   lineBreakMode: UILineBreakModeWordWrap
                                                       alignment: UITextAlignmentCenter];
}

@end
