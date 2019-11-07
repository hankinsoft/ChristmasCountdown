//
//  CountdownHelper.h
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 2014-06-03.
//
//

#import <Foundation/Foundation.h>

@interface CountdownHelper : NSObject

+ (NSInteger) daysAwayFromDate: (NSDate*) targetDate;
+ (NSDate*) christmasDay;
+ (NSString*) stringForDaysAway: (NSDate*) targetDate;
+ (NSString*) stringForDaysAway: (NSDate*) targetDate includeLinebreak: (BOOL) inclueLinebreak;

@end
