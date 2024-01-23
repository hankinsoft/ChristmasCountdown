//
//  CCDUnlockHelper.h
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 2024-01-22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCDUnlockHelper : NSObject

+ (BOOL) isUnlocked;
+ (void) displayUnlockPopup;

@end

NS_ASSUME_NONNULL_END
