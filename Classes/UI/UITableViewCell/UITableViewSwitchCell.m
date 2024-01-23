//
//  UITableViewSwitchCell.m
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 2024-01-22.
//

#import "UITableViewSwitchCell.h"

@implementation UITableViewSwitchCell
{
    UISwitch        * theSwitch;
}

- (id) initWithStyle: (UITableViewCellStyle) style
     reuseIdentifier: (NSString *) reuseIdentifier
{
    if (self = [super initWithStyle: style
                    reuseIdentifier: reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        theSwitch = [[UISwitch alloc] initWithFrame: CGRectMake(150, 13, 150, 10)];

        // Disable autoresizing mask translation
        theSwitch.translatesAutoresizingMaskIntoConstraints = NO;

        // Add the slider to the cell's content view
        [self.contentView addSubview: theSwitch];

        // Set constraints
        [self setupSliderConstraints];
        [theSwitch sizeToFit];
/*
        theSwitch.layer.borderColor = UIColor.redColor.CGColor;
        theSwitch.layer.borderWidth = 1;
*/
    }

    return self;
}

- (void) setupSliderConstraints
{
    // Constraints for the slider
    [NSLayoutConstraint activateConstraints:@[
        // Horizontal position, 150 points from leading margin
        [theSwitch.trailingAnchor constraintEqualToAnchor: self.contentView.trailingAnchor constant: -20],
        // Vertical centering in the cell
        [theSwitch.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor],
        // Optional: Set the slider height
        // [slider.heightAnchor constraintEqualToConstant:10],
    ]];
}

- (void) addTarget: (id) target
            action: (SEL) action
{
    [theSwitch addTarget: target
                  action: action
        forControlEvents: UIControlEventValueChanged];
}

- (void) setEnabled: (BOOL) enabled
{
    [theSwitch setEnabled: enabled];
    if(!enabled)
    {
        [theSwitch setOn: NO];
    }
} // End of setEnabled:

- (void) setIsOn: (BOOL) isOn
{
    [theSwitch setOn: isOn];
}

- (void) setSelected: (BOOL) selected
            animated: (BOOL) animated
{
    // No selection
    [super setSelected:NO animated:animated];
}

@end
