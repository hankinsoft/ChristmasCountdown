//
//  CCDPageControl.h
//
//  Replacement for UIPageControl because that one only supports white dots.
//
//  Created by Morten Heiberg <morten@heiberg.net> on November 1, 2010.
//

#import <UIKit/UIKit.h>

@protocol PageControlDelegate;

@interface CCDPageControl : UIView 
{
@private
    NSInteger _currentPage;
    NSInteger _numberOfPages;
    UIColor *dotColorCurrentPage;
    UIColor *dotColorOtherPage;
    NSObject<PageControlDelegate> *delegate;
}

// Set these to control the CCDPageControl.
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger numberOfPages;

// Customize these as well as the backgroundColor property.
@property (nonatomic, retain) UIColor *dotColorCurrentPage;
@property (nonatomic, retain) UIColor *dotColorOtherPage;

// Optional delegate for callbacks when user taps a page dot.
@property (nonatomic, retain) NSObject<PageControlDelegate> *delegate;

@end

@protocol PageControlDelegate<NSObject>
@optional
- (void)pageControlPageDidChange:(CCDPageControl *)pageControl;
@end
