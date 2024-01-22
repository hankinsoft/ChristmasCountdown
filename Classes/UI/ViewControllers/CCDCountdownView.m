//
//  CCDCountdownView.m
//  ChristmasCounter
//
//  Created by Kyle Hankinson on 04/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CCDCountdownView.h"
#import "ChristmasCountdownAppDelegate.h"
#import "CCDCountdownHelper.h"

@interface CCDCountdownView ()

- (void)updateTimer:(id)sender;

@property (nonatomic, assign) 	BOOL		countdownEnabled;

@end

@implementation CCDCountdownView

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
        [[[ChristmasCountdownAppDelegate instance] gregorianCalendar] components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ) fromDate: [NSDate date]];
		
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
	[[[ChristmasCountdownAppDelegate instance] gregorianCalendar] components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ) fromDate: [NSDate date]];
	
	NSString * countdownString;
	
	// If we are christmas day, then we do not need to display anything
	if ( 25 == [currentDateComponents day] && 12 == [currentDateComponents month] )
	{
		countdownString = @"\r\nMerry Christmas!";
	}
	else
	{
		// Figure out how far away it is
		NSTimeInterval timeInterval = [CCDCountdownHelper.christmasDay timeIntervalSinceNow];

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
- (UIColor *) colorForString: (NSString *) colorString
{
    NSDictionary *colorMap = @{
        @"White": [UIColor whiteColor],
        @"Black": [UIColor blackColor],
        @"Pink": [UIColor colorWithRed:1.0 green:0.0 blue:0.5 alpha:1.0],
        @"Red": [UIColor redColor],
        @"Blue": [UIColor blueColor],
        @"Yellow": [UIColor colorWithRed:251/255.0 green:236/255.0 blue:93/255.0 alpha:1.0],
        @"Green": [UIColor greenColor],
        @"Purple": [UIColor colorWithRed:141/255.0 green:50/255.0 blue:150/255.0 alpha:1.0]
    };

    return colorMap[colorString];
}

- (void) drawRect: (CGRect) rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();

    // Clear the contents
    CGContextClearRect(contextRef, rect);

    NSString *colorString = [[NSUserDefaults standardUserDefaults] stringForKey:@"FontColor"];
    UIColor *textColor = [self colorForString:colorString];

    if (!textColor) {
        NSLog(@"Unknown color: %@", colorString);
        return;
    }

    float fontSize = [ChristmasCountdownAppDelegate iPad] ? 20.0f : 15.0f;

    NSMutableDictionary *attributes = @{
        NSFontAttributeName: [UIFont fontWithName: @"zapfino" size: fontSize],
        NSForegroundColorAttributeName: textColor
    }.mutableCopy;

    NSString *countdownString = [CCDCountdownView countdownStringWithNewlines:YES];

    // Add a BOOL variable to enable/disable the letter border
    BOOL enableLetterBorder = NO; // Set this to YES to enable the border

    if (enableLetterBorder) {
        attributes = @{
            NSFontAttributeName: [UIFont fontWithName:@"zapfino" size:fontSize],
            NSForegroundColorAttributeName: textColor,
            NSStrokeWidthAttributeName: @-2.0, // This negative value creates a border around the lettering
            NSStrokeColorAttributeName: [UIColor blackColor] // Border color is black
        }.mutableCopy;
    }

    CGSize textSize = [countdownString sizeWithAttributes:attributes];
    CGRect textRect = CGRectMake((rect.size.width - textSize.width) / 2, (rect.size.height - textSize.height) / 2, textSize.width, textSize.height);

    // Center the text within the view
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;

    attributes[NSParagraphStyleAttributeName] = paragraphStyle;

    [countdownString drawInRect:textRect withAttributes:attributes];
}

@end
