//
//  CCDSettingsViewController.m
//  Christmas Countdown HD
//
//  Created by Kyle Hankinson on 10-07-05.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ChristmasCountdownAppDelegate.h"
#import "ChristmasCounterViewController.h"
#import "CCDSettingsViewController.h"
#import "UITableViewSliderCell.h"
#import "ColorPickerViewController.h"
#import "MusicPickerViewController.h"
#import "CustomImageViewController.h"
#import "CCDCountdownView.h"

#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>

@import StoreKit;

#define				SECTION_SNOWFLAKES		@"Snowflakes"
#define				SECTION_NOTIFICATIONS	@"Notifications"
#define				SECTION_OTHER			@"General"
#define				SECTION_MORE            @"More"

#define SnowflakeSection	0
#define NotificationSection 1
#define MiscSection			2
#define ShareSection        3

@interface CCDSettingsViewController ()<MFMailComposeViewControllerDelegate>
{
    // Advertisement stuff
    BOOL                    bannerIsVisible;
}

- (int) valueForSliderField: (NSString*) field inSection: (NSString*) section;

@property (nonatomic, retain) NSDictionary			* settingsCells;

@end

@implementation CCDSettingsViewController
{
    SLComposeViewController * mySLComposeViewController;
}

static NSString *SettingsCellIdentifier = @"SettingsCell";

@synthesize settingsCells, christmasCounterViewController;

+ (void) postSnowflakesNeedUpdate
{
    [NSNotificationCenter.defaultCenter postNotificationName: kSnowflakesNeedUpdate
                                                      object: nil];
} // End of postSnowflakesNeedUpdate

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Set our title
	[self setTitle: @"Settings"];

    // Add our done bar button item
    UIBarButtonItem * doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Done"
                                                                           style: UIBarButtonItemStyleDone
                                                                          target: self
                                                                          action: @selector(settingsViewDone:)];
    self.navigationItem.leftBarButtonItem = doneBarButtonItem;

    self.preferredContentSize = CGSizeMake(320.0, 400.0);

	NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] init];

    // Create our cache options
	NSMutableArray	* cellArray = [[NSMutableArray alloc] init];
	
	UITableViewSliderCell *sliderCell;

	sliderCell = [[UITableViewSliderCell alloc] initWithStyle: UITableViewCellStyleDefault
                                              reuseIdentifier: SettingsCellIdentifier];
	[sliderCell.slider setMinimumValue:3];
	[sliderCell.slider setMaximumValue:25];
	[sliderCell.slider setValue: [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeSize"]];
	[sliderCell.slider addTarget:self action:@selector(sizeSliderAction:) forControlEvents:UIControlEventValueChanged];
	[[sliderCell textLabel] setText: @"Size"];
	[cellArray addObject: sliderCell];
	
    sliderCell = [[UITableViewSliderCell alloc] initWithStyle: UITableViewCellStyleDefault
                                              reuseIdentifier: SettingsCellIdentifier];
	[sliderCell.slider setMinimumValue:3];
	[sliderCell.slider setMaximumValue:30];
	[sliderCell.slider setValue: [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeSpeed"]];
	[sliderCell.slider addTarget:self action:@selector(speedSliderAction:) forControlEvents:UIControlEventValueChanged];
	[[sliderCell textLabel] setText: @"Speed"];
	[cellArray addObject: sliderCell];
	
    sliderCell = [[UITableViewSliderCell alloc] initWithStyle: UITableViewCellStyleDefault
                                              reuseIdentifier: SettingsCellIdentifier];
	[sliderCell.slider setMinimumValue:25];
	[sliderCell.slider setMaximumValue:125];
	[sliderCell.slider setValue: [[NSUserDefaults standardUserDefaults] integerForKey:@"SnowflakeCount"]];
	[sliderCell.slider addTarget:self action:@selector(countSliderAction:) forControlEvents:UIControlEventValueChanged];
	[[sliderCell textLabel] setText: @"Count"];
	[cellArray addObject: sliderCell];

    UITableViewCell *cell;

	// Color cell
	cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:SettingsCellIdentifier];
	[[cell textLabel] setText: @"Color"];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[cellArray addObject: cell];
	
	[settingsDictionary setObject: cellArray forKey: SECTION_SNOWFLAKES];
	
    // Create our miscellaneous options
    cellArray= [[NSMutableArray alloc] init];
    
    
    // Notifications
	
	// Add the Badge cell (with switch), unselectable
	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SettingsCellIdentifier];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
	[cell setAccessoryType: UITableViewCellAccessoryNone];
	[[cell textLabel] setText: @"Enable Notifications"];
	UISwitch * badgeSwitch = [[UISwitch alloc] initWithFrame: CGRectMake(200, 10, 0, 0)];
	badgeSwitch.on = [[NSUserDefaults standardUserDefaults] integerForKey: @"enableNotifications"];
	badgeSwitch.tag = 1;
	[badgeSwitch addTarget:self action:@selector(toggleNotifications:) forControlEvents:UIControlEventValueChanged];
    badgeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
	[cell addSubview: badgeSwitch];
    [badgeSwitch.centerYAnchor constraintEqualToAnchor: cell.centerYAnchor].active = YES;
    [badgeSwitch.rightAnchor constraintEqualToAnchor: cell.rightAnchor
                                            constant: -20.f].active = YES;
    [badgeSwitch sizeToFit];

	[cellArray addObject: cell];
	
	// Add the Badge cell
	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SettingsCellIdentifier];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
	[cell setAccessoryType: UITableViewCellAccessoryNone];
	[[cell textLabel] setText: @"Enable Badge"];

	// Add our badge switch
	badgeSwitch = [[UISwitch alloc] initWithFrame: CGRectMake(200, 10, 0, 0)];
	badgeSwitch.on = [[ChristmasCountdownAppDelegate instance] isBadgeEnabled];
	badgeSwitch.tag = 1;
	[badgeSwitch addTarget:self action:@selector(toggleBadge:) forControlEvents:UIControlEventValueChanged];
    badgeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
	[cell addSubview: badgeSwitch];
    [badgeSwitch.centerYAnchor constraintEqualToAnchor: cell.centerYAnchor].active = YES;
    [badgeSwitch.rightAnchor constraintEqualToAnchor: cell.rightAnchor
                                            constant: -20.f].active = YES;
    [badgeSwitch sizeToFit];
	[cellArray addObject: cell];
	
	[settingsDictionary setObject: cellArray forKey: SECTION_NOTIFICATIONS];
	
    // Create our miscellaneous options
    cellArray = [[NSMutableArray alloc] init];

	// Add the music cell
	cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:SettingsCellIdentifier];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[[cell textLabel] setText: @"Music"];
	[cellArray addObject: cell];

	// Add the custom image cell
	cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:SettingsCellIdentifier];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[[cell textLabel] setText: @"Custom Image"];
	[cellArray addObject: cell];

	// Custom image font cell
	cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:SettingsCellIdentifier];
	[[cell textLabel] setText: @"Font Color"];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[cellArray addObject: cell];

	[settingsDictionary setObject: cellArray forKey: SECTION_OTHER];
    

    
    

    // Create our miscellaneous options
    cellArray = [[NSMutableArray alloc] init];
	// Add the rate cell
	cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:SettingsCellIdentifier];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[[cell textLabel] setText: @"Rate"];
	[cellArray addObject: cell];

    [settingsDictionary setObject: cellArray forKey: SECTION_MORE];

	// Add the Email cell
	cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:SettingsCellIdentifier];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	[[cell textLabel] setText: @"Share"];
	[cellArray addObject: cell];

	[settingsDictionary setObject: cellArray forKey: SECTION_MORE];

	[self setSettingsCells: settingsDictionary];
}

- (void) toggleBadge: (UISwitch*) sender
{
	[[NSUserDefaults standardUserDefaults] setBool: [sender isOn] forKey: @"enableBadgeUpdates"];
    [[ChristmasCountdownAppDelegate instance] updateApplicationBadge];
    [[ChristmasCountdownAppDelegate instance] setRebuildNotifications: YES];
	
	DLog ( @"toggleBadge: sender = %ld, isOn %d",  (long)[sender tag], [sender isOn] );
}

- (void) toggleNotifications: (UISwitch*) sender
{
    // Toggle our notifications, but we will not do any work until the app is closeing
	[[NSUserDefaults standardUserDefaults] setBool: [sender isOn] forKey: @"enableNotifications"];
    [[ChristmasCountdownAppDelegate instance] setRebuildNotifications: YES];
	
	DLog ( @"toggleNotifications: sender = %ld, isOn %d",  (long)[sender tag], [sender isOn] );
}

- (void)sizeSliderAction:(UISlider*)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger: [sender value] forKey:@"SnowflakeSize"];
	NSLog ( @"SizeSliderAction: %f", [sender value] );

    [CCDSettingsViewController postSnowflakesNeedUpdate];
}

- (void)speedSliderAction:(UISlider*)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger: [sender value] forKey:@"SnowflakeSpeed"];
	NSLog ( @"SpeedSliderAction: %f", [sender value] );

    [CCDSettingsViewController postSnowflakesNeedUpdate];
}

- (void)countSliderAction:(UISlider*)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger: [sender value] forKey:@"SnowflakeCount"];
	NSLog ( @"CountSliderAction: %f", [sender value] );

    [CCDSettingsViewController postSnowflakesNeedUpdate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [tableView reloadData];
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    // Return the number of sections.
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch ( section )
	{
		case SnowflakeSection:
		{
			return SECTION_SNOWFLAKES;
		}
        case NotificationSection:
        {
            return SECTION_NOTIFICATIONS;
        }
		case MiscSection:
		{
			return SECTION_OTHER;
		}
        case ShareSection:
        {
            return SECTION_MORE;
        }
		default:
		{
			return @"";
		}
	} // End of section switch
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	NSString * key = [self tableView: aTableView titleForHeaderInSection: section];
	NSArray * cells = [self.settingsCells objectForKey: key];
	
    // Return the number of rows in the section.
    return [cells count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * key = [self tableView: aTableView titleForHeaderInSection: indexPath.section];
	NSArray * cells = [self.settingsCells objectForKey: key];
	
	UITableViewCell * cell = [cells objectAtIndex: indexPath.row];
	
	// If it is the color cell
	if ( [[[cell textLabel] text] isEqual: @"Color"] )
	{
		// Set our detail text label
		[[cell detailTextLabel] setText: [[NSUserDefaults standardUserDefaults] stringForKey:@"SnowflakeColor"]];
	} // End of color cell
    else if([cell.textLabel.text isEqualToString: @"Font Color"])
    {
		// Set our detail text label
		[[cell detailTextLabel] setText: [[NSUserDefaults standardUserDefaults] stringForKey:@"FontColor"]];
    }
	// Music cell
	else if ( [[[cell textLabel] text] isEqual: @"Music"] )
	{
		NSString * music = [[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] songName];
		if ( [music length] > 20 )
		{
			// Set our detail text label
			[[cell detailTextLabel] setText: [NSString stringWithFormat: @"%@...", [music substringToIndex: 20]]];
		}
		else
		{
			// Set our detail text label
			[[cell detailTextLabel] setText: music];
		}
	}
	
	// Return our cell
	return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)      tableView: (UITableView *) aTableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
	// Deselect the row
	[aTableView deselectRowAtIndexPath: [aTableView indexPathForSelectedRow]
                              animated: YES];

    // Get the cell they are clicking on
    UITableViewCell * cell = [aTableView cellForRowAtIndexPath: indexPath];
	
	// The color row
	if ( [[[cell textLabel] text] isEqual: @"Color"] )
	{
		ColorPickerViewController *colorPickerViewController = [[ColorPickerViewController alloc]initWithNibName:@"ColorPickerViewController" bundle: [NSBundle mainBundle]];

        colorPickerViewController.title = @"CCDSnowflake Color";
        colorPickerViewController.property = @"SnowflakeColor";

        colorPickerViewController.generalArray = 	[[NSArray alloc] initWithObjects: @"White", @"Blue", @"Pink", @"Yellow", @"Green", @"Purple", @"Rainbow", nil];
        colorPickerViewController.holidayArray =    [[NSArray alloc] initWithObjects:
                                                     @"Halloween",
                                                     @"Valentine's Day",
                                                     @"St. Patrick's Day",
                                                     nil];

        [[self navigationController] pushViewController:colorPickerViewController animated:YES];
	} // End of color row
    // Font color
	else if ( [[[cell textLabel] text] isEqual: @"Font Color"] )
	{
		ColorPickerViewController *colorPickerViewController = [[ColorPickerViewController alloc]initWithNibName:@"ColorPickerViewController" bundle: [NSBundle mainBundle]];
        
        colorPickerViewController.title = @"Font Color";
        colorPickerViewController.property = @"FontColor";
        colorPickerViewController.generalArray = 	[[NSArray alloc] initWithObjects: @"Black", @"White", @"Red", @"Blue", @"Green", @"Yellow", nil];

        [[self navigationController] pushViewController:colorPickerViewController animated:YES];
	} // End of color row
	// Music
    else if ( [[[cell textLabel] text] isEqual: @"Music"] )
	{
		UIViewController *musicPickerViewController = [[MusicPickerViewController alloc] initWithNibName:@"MusicPickerViewController" 
																								  bundle:[NSBundle mainBundle]];
		
		[[self navigationController] pushViewController:musicPickerViewController animated:YES];
	} // End of music
	// Custom image
	else if ( [[[cell textLabel] text] isEqual: @"Custom Image"] )
	{
		UIViewController *customImageViewController = [[CustomImageViewController alloc] initWithNibName: @"CustomImageViewController" bundle:[NSBundle mainBundle]];

		[[self navigationController] pushViewController: customImageViewController
                                               animated: YES];
	}

    // Sharing section
	// The rate row
    else if ( [[[cell textLabel] text] isEqual: @"Rate"] )
	{
        if(@available(iOS 10.3, *))
        {
            [SKStoreReviewController requestReview];
        } // End of iOS 10.3 and above
	} // End of Rate
    else if ( [[[cell textLabel] text] isEqual: @"Share"] )
	{
        NSArray * dataToShare = @[self.christmasCounterViewController.screenshot];
        UIActivityViewController * activityViewController = [[UIActivityViewController alloc] initWithActivityItems: dataToShare
                                                                                              applicationActivities: nil];

        if(activityViewController.popoverPresentationController)
        {
            activityViewController.popoverPresentationController.sourceView = cell;
            activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        } // End of we have a popoverPresentationController

        activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
        [self presentViewController: activityViewController
                           animated: YES
                         completion: nil];
        
        [activityViewController setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

            if(activityError)
            {
                return;
            }
        }];
	} // End of Rate
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if ( NotificationSection == section )
	{
		return @"If you are using iOS 5 or above, Christmas Countdown "
            @"must be enabled in the Notification Center.";
	}
	else
	{
		return @"";
	}
}

/// <Summary>
/// Loops though our cached items trying to find one with the proper field and section, returning
/// the value of the slider.
/// </Summary>
- (int) valueForSliderField: (NSString*) field inSection: (NSString*) section
{
	NSArray * cells = [self.settingsCells objectForKey: section];
	if ( !cells )
	{
		return 0;
	}

	for ( int i = 0; i < [cells count]; ++i )
	{
		UITableViewCell * cell = [cells objectAtIndex: i];
		if ( [cell.textLabel.text isEqualToString: field] )
		{
			return ((UITableViewSliderCell*) cell).slider.value;
		}
	} // End of for loop
	
	return 0;
} // End of stringForTextField

- (void) settingsViewDone:(id) sender
{
	// Update our settings
	[[NSUserDefaults standardUserDefaults] setInteger: [self valueForSliderField: @"Size" inSection:SECTION_SNOWFLAKES] forKey:@"SnowflakeSize"];
	[[NSUserDefaults standardUserDefaults] setInteger: [self valueForSliderField: @"Speed" inSection:SECTION_SNOWFLAKES] forKey:@"SnowflakeSpeed"];
	[[NSUserDefaults standardUserDefaults] setInteger: [self valueForSliderField: @"Count" inSection:SECTION_SNOWFLAKES] forKey:@"SnowflakeCount"];

    // Close the settings view
	[self dismissViewControllerAnimated: YES
                             completion: ^{}];
} // End of settingsViewDone

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated: YES
                             completion: ^{}];
}

@end

