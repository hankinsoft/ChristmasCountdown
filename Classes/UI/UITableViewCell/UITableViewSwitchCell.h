//
//  UITableViewSwitchCell.h
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 2024-01-22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewSwitchCell : UITableViewCell

- (void) addTarget: (id) target
            action: (SEL) action;

- (void) setEnabled: (BOOL) enabled;
- (void) setIsOn: (BOOL) isOn;

@end

NS_ASSUME_NONNULL_END
