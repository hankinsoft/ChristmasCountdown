//
//  CCCountdownHelper.m
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 2014-06-03.
//
//

#import "CCCountdownHelper.h"

@implementation CCCountdownHelper

static NSDate * christmasDay;

+ (void) initialize
{
    // Set christmasDay
    // We need to make sure that if we are past december 25 but before Jan 1, to use the next year,
    // so that we do not display -1, -2, etc days until christmas.
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];

    NSDateComponents *currentDateComponents =
        [gregorian components: ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay )
                     fromDate: [NSDate date]];
    
    NSInteger year = [currentDateComponents year];
    if ( 12 == [currentDateComponents month] && 25 < [currentDateComponents day] )
    {
        ++year;
    }
    
    // Using our current year, set it to be christmas day
    NSString *dateStr = [[NSString alloc] initWithFormat: @"%4ld1225", (long)year];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    christmasDay = [dateFormat dateFromString:dateStr];
} // End of initialize

+ (NSDate*) christmasDay
{
    return christmasDay;
}

+ (NSInteger) daysAwayFromDate: (NSDate*) targetDate
{
    // Figure out how far away it is
    NSTimeInterval timeInterval = [christmasDay timeIntervalSinceDate: targetDate];
    
    return ( floor(timeInterval / 86400) );
} // End of daysAwayFromDate

+ (NSString*) stringForDaysAway: (NSDate*) targetDate
{
    return [self stringForDaysAway: targetDate
                  includeLinebreak: NO];
}

+ (NSString*) stringForDaysAway: (NSDate*) targetDate
               includeLinebreak: (BOOL) inclueLinebreak
{
    // Get our days away (minus one to make up the fact it's sent at midnight)
    NSInteger daysAway = [self daysAwayFromDate: targetDate] - 1;
    NSString * countdownString = @"";

    // If we wrap, then we weed to re-calculate.
    if ( daysAway < 0 )
    {
        daysAway = [self daysAwayFromDate: targetDate];
    }
    
    if ( daysAway > 1 )
    {
        countdownString = [NSString stringWithFormat: @"There are %ld Days%@Until Christmas.",
                           (long)daysAway, inclueLinebreak ? @"\r\n" : @" "];
    }
    else if ( 1 == daysAway )
    {
        countdownString = [NSString stringWithFormat: @"There is one day%@until Christmas.",
                           inclueLinebreak ? @"\r\n" : @" "];
    }
    else if ( 0 == daysAway )
    {
        countdownString = @"Merry Christmas!";
    }

    return countdownString;
}

@end
