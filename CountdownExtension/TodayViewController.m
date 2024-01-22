//
//  TodayViewController.m
//  CountdownExtension
//
//  Created by Kyle Hankinson on 2014-09-30.
//
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "CCDCountdownHelper.h"

@interface TodayViewController () <NCWidgetProviding>
{
    UILabel            * countdownDateLabel;
}
@end

@implementation TodayViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect: UIVibrancyEffect.widgetPrimaryVibrancyEffect];
    effectView.frame = self.view.bounds;
    effectView.autoresizingMask = self.view.autoresizingMask;

    // Set our effectView
    self.view = effectView;

    countdownDateLabel = [[UILabel alloc] init];
    countdownDateLabel.font = [UIFont fontWithName: @"zapfino"
                                              size: UIFont.systemFontSize];
    countdownDateLabel.textAlignment = NSTextAlignmentCenter;

    countdownDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [effectView.contentView addSubview: countdownDateLabel];
    [countdownDateLabel.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = YES;
    [countdownDateLabel.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = YES;
    [countdownDateLabel.centerYAnchor constraintEqualToAnchor: self.view.centerYAnchor].active = YES;
    [countdownDateLabel.heightAnchor constraintGreaterThanOrEqualToConstant: 10.0f].active = YES;
    countdownDateLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];

    [self updateDisplay];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIEdgeInsets) widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsMake(0,0,0,0);
}

- (void) updateDisplay
{
    countdownDateLabel.text = [CCDCountdownHelper stringForDaysAway: [NSDate date]
                                                includeLinebreak: NO];
    
    // Size to fit
    [countdownDateLabel sizeToFit];

    // Setup our contentSize
    self.preferredContentSize = countdownDateLabel.frame.size;
} // End of updateDisplay

- (void) widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    [self updateDisplay];
    
    completionHandler(NCUpdateResultNewData);
}

@end
