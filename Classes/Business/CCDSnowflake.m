//
//  CCDSnowflake.m
//  ChristmasCounter
//
//  Created by Kyle Hankinson on 04/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CCDSnowflake.h"

#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))

@implementation CCDSnowflake

static float sine[360];

+ (void) initialize
{
	// Generate our sine wave
	for(int i=0;i<360;i++)
	{
		sine[i] = sin(M_PI/180 * i);
	}
}

- (id) init
{
    // No user interaction for snowflakes
    self.userInteractionEnabled = NO;

	NSUInteger baseSize =  [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeSize"];
	NSUInteger size = RANDOM_INT(baseSize - 1,baseSize + 1);

	NSUInteger x = RANDOM_INT(-10,(int)[UIScreen mainScreen].bounds.size.width + 10);
	NSUInteger y = RANDOM_INT(-10,(int)[UIScreen mainScreen].bounds.size.height);
	if ( self = [super initWithFrame: CGRectMake ( x, y, size, size )] )
	{
		// Make our control non-opaque
		[self setOpaque: NO];

		NSUInteger baseSpeed = [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeSpeed"];
		speedY = RANDOM_INT(baseSpeed - 2, baseSpeed + 2);

		// Set a starting frame (so that the snowflakes are not all moving the same sine wave)
		frame = RANDOM_INT(0,360);

		[self updateColor];
	} // End of super init

	return self;
}

- (void) updateColor
{
	float alpha = 1.0;

	NSUInteger baseSize =  [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeSize"];
	NSUInteger size = RANDOM_INT(baseSize - 1,baseSize + 1);

	[self setFrame: CGRectMake ( self.frame.origin.x, self.frame.origin.y, size, size )];

	NSUInteger baseSpeed = [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeSpeed"];
	speedY = RANDOM_INT(baseSpeed - 2, baseSpeed + 2);

	// White
	if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"White"] )
	{
		// Set our color
		red = 255;
		green = 255;
		blue = 255;
		alpha = (float)RANDOM_INT(80, 90)/100.0;
	}
	else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"Pink"] )
	{
		switch ( RANDOM_INT(0,2) )
		{
			case 0:
				red = 0xff;
				green = 0x1c;
				blue = 0xae;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
			case 1:
				red = 0xff;
				green = 0x1c;
				blue = 0xae;
				alpha = (float)RANDOM_INT(70, 80)/100.0;
				break;
			case 2:
				red = 0xff;
				green = 0x14;
				blue = 0x93;
				alpha = (float)RANDOM_INT(80, 95)/100.0;
				break;
		} // End of switch
	}
	else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"Blue"] )
	{
		switch ( RANDOM_INT(0,2) )
		{
			case 0:
				red = 0x00;
				green = 0x7f;
				blue = 0xff;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
			case 1:
				red = 0x00;
				green = 0xb2;
				blue = 0xee;
				alpha = (float)RANDOM_INT(70, 80)/100.0;
				break;
			case 2:
				red = 0x10;
				green = 0x4e;
				blue = 0x8b;
				alpha = (float)RANDOM_INT(80, 95)/100.0;
				break;
		} // End of switch
	} // End of Blue
	else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"Yellow"] )
	{
		switch ( RANDOM_INT(0,2) )
		{
			case 0:
				red = 0xFB;
				green = 0xEC;
				blue = 0x5D;
				alpha = (float)RANDOM_INT(80, 95)/100.0;
				break;
			case 1:
				red = 0xFF;
				green = 0xFF;
				blue = 0x00;
				alpha = (float)RANDOM_INT(80, 95)/100.0;
				break;
			case 2:
				red = 0xFF;
				green = 0xFF;
				blue = 0x7E;
				alpha = (float)RANDOM_INT(85, 95)/100.0;
				break;
		} // End of switch
	} // End of Yellow
	else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"Green"] )
	{
		switch ( RANDOM_INT(0,2) )
		{
			case 0:
				red   = 0x00;
				green = 0xff;
				blue  = 0x7f;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
			case 1:
				red   = 0x00;
				green = 0xee;
				blue  = 0xb2;
				alpha = (float)RANDOM_INT(70, 80)/100.0;
				break;
			case 2:
				red   = 0x10;
				green = 0x8b;
				blue  = 0x4e;
				alpha = (float)RANDOM_INT(80, 95)/100.0;
				break;
		} // End of switch
	} // End of Green
	else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"Purple"] )
	{
		switch ( RANDOM_INT(0,2) )
		{
			case 0:
				red   = 0x7F;
				green = 0x00;
				blue  = 0xFF;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
			case 1:
				red   = 0x91;
				green = 0x2C;
				blue  = 0xEE;
				alpha = (float)RANDOM_INT(70, 80)/100.0;
				break;
			case 2:
				red   = 0xD1;
				green = 0x5F;
				blue  = 0xEE;
				alpha = (float)RANDOM_INT(80, 95)/100.0;
				break;
		} // End of switch
	} // End of Green
	
	else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"Rainbow"] )
	{
		switch ( RANDOM_INT(0,6) )
		{
				// Red
			case 0:
				red = 0xEE;
				green = 0x00;
				blue = 0x00;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
				// Orange
			case 1:
				red = 0xFF;
				green = 0x33;
				blue = 0x00;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
				// Yellow
			case 2:
				red = 0xFC;
				green = 0xD1;
				blue = 0x16;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
				// Green
			case 3:
				red = 0x00;
				green = 0xEE;
				blue = 0x00;
				alpha = (float)RANDOM_INT(85, 90)/100.0;
				break;
				// Aqua
			case 4:
				red = 0x6E;
				green = 0xEC;
				blue = 0xC6;
				alpha = (float)RANDOM_INT(70, 90)/100.0;
				break;
				// Blue
			case 5:
				red = 0x00;
				green = 0x00;
				blue = 0xEE;
				alpha = (float)RANDOM_INT(70, 90)/100.0;
				break;
				// Purple
			case 6:
				red = 0x55;
				green = 0x1A;
				blue = 0x8B;
				alpha = (float)RANDOM_INT(70, 90)/100.0;
				break;
		} // End of switch
	} // End of Rainbow
	else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"Halloween"] )
	{
		switch ( RANDOM_INT(0,2) )
		{
				// Orange
			case 0:
				red = 220;
				green = 125;
				blue = 2;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
				// Black
			case 1:
				red = 0;
				green = 0;
				blue = 0;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
            case 2:
                red   = 235;
                green = 95;
                blue  = 34;
                alpha = (float)RANDOM_INT(80, 90)/100.0;
                break;
		} // End of switch
	} // End of Halloween
	else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"Valentine's Day"] )
	{
		switch ( RANDOM_INT(0,2) )
		{
			case 0:
				red   = 240;
				green = 128;
				blue  = 128;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
			case 1:
				red   = 250;
				green = 128;
				blue  = 114;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
            case 2:
                red   = 255;
                green = 20;
                blue  = 20;
                alpha = (float)RANDOM_INT(80, 90)/100.0;
                break;
		} // End of switch
	} // End of Valentine's Day
	else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"] isEqual: @"St. Patrick's Day"] )
	{
		switch ( RANDOM_INT(0,1) )
		{
			case 0:
				red   = 0;
				green = 128;
				blue  = 0;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
			case 1:
				red   = 50;
				green = 205;
				blue  = 50;
				alpha = (float)RANDOM_INT(80, 90)/100.0;
				break;
/*
            case 2:
                red   = 255;
                green = 20;
                blue  = 20;
                alpha = (float)RANDOM_INT(80, 90)/100.0;
                break;
*/
		} // End of switch
	} // End of Valentine's Day	
	
	// Give us a good alpha
	[self setAlpha: alpha];
}

- (float) sinValueForFrame:(NSInteger)targetFrame
{
	return sine [ targetFrame % 360 ];
}

- (void) update
{
	float newX = self.center.x + [self sinValueForFrame: frame++];

	int newY = self.center.y + speedY;

	if ( newY > self.superview.bounds.size.height )
	{
		newY = -10;
	}

    UIScrollView * scrollView = (UIScrollView*)self.superview;

	if ( newX < (int)scrollView.contentOffset.x - 5 ||
        newX > ( (int)scrollView.contentOffset.x + self.superview.bounds.size.width) + 10)
	{
//		newY = -10;
        newY = RANDOM_INT(-10,(int)[UIScreen mainScreen].bounds.size.height);
		newX = RANDOM_INT((int)scrollView.contentOffset.x - 10,
                          (int)self.superview.bounds.size.width + (int)scrollView.contentOffset.x + 10);
	}

	[self setCenter: CGPointMake ( newX, newY )];
}


- (void)drawRect:(CGRect)rect
{
	CGContextRef contextRef = UIGraphicsGetCurrentContext();

	// Clear the contents
    CGContextClearRect(contextRef, rect);

	// Draw our snowflake
    CGContextSetRGBFillColor(contextRef, red/255, green/255, blue/255, [self alpha]);
	CGContextFillEllipseInRect(contextRef, CGRectMake(0, 0, rect.size.width, rect.size.width));
}

@end
