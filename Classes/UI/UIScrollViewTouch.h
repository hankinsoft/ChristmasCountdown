//
//  UIScrollViewTouch.h
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-11-07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIScrollViewTouchDelegate <NSObject>

- (void) doubleTapped;
- (void) singleTapped;

@end

@interface UIScrollViewTouch : UIScrollView
{
    id<UIScrollViewTouchDelegate>     touchDelegate;

	NSMutableArray		* snowflakes;
}

- (void) initTimer;
- (void) updateSnowflakes;

@property(nonatomic,retain) id<UIScrollViewTouchDelegate>     touchDelegate;

@end
