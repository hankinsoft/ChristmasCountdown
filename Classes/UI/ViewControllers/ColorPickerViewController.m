//
//  ColorPickerViewController.m
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-10-04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChristmasCountdownAppDelegate.h"
#import "ColorPickerViewController.h"
#import "CCDSettingsViewController.h"
#import "CCDUnlockHelper.h"

@implementation ColorPickerViewController

@synthesize property;
@synthesize generalArray;
@synthesize holidayArray;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark Table view methods

- (NSString*) tableView: (UITableView *) tableView
titleForHeaderInSection: (NSInteger) section
{
    if(nil == holidayArray)
    {
        return nil;
    }

    if(0 == section)
    {
        return @"General";
    }
    else
    {
        return @"Holiday Theamed";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(nil == holidayArray)
    {
        return 1;
    }

    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(nil == holidayArray || 0 == section)
    {
        return [generalArray count];
    }
    
    return holidayArray.count;
}

- (BOOL) isIndexPathLocked: (NSIndexPath*) indexPath
{
    if(CCDUnlockHelper.isUnlocked)
    {
        return NO;
    } // End of our indexPath is locked

    if(0 == indexPath.section)
    {
        if(NSOrderedSame == [generalArray[indexPath.row] caseInsensitiveCompare: @"rainbow"])
        {
            return YES;
        }
    }
    else
    {
        // This is a <other holiday> color. We are locked.
        return YES;
    }

    return NO;
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *)tableView
          cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Check if we are locked
    BOOL locked = [self isIndexPathLocked: indexPath];

    NSArray * targetArray;
    if(0 == indexPath.section)
    {
        targetArray = generalArray;
    }
    else
    {
        targetArray = holidayArray;
    }

    NSString * colorName = (NSString*)[targetArray objectAtIndex: indexPath.row];

	// Grab the name of the cell from the array
	[cell.textLabel setText: colorName];

    if(locked)
    {
        UIImage *image = [UIImage systemImageNamed: @"lock"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
        cell.accessoryView = imageView;
    } // End of we are locked
    else
    {
        cell.accessoryView = nil;

        // If this is our selected color, then checkmark it
        if ( [[[NSUserDefaults standardUserDefaults] stringForKey: property] isEqual: [[cell textLabel] text]] )
        {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
        }
        else
        {
            [cell setAccessoryType: UITableViewCellAccessoryNone];
        }
    }

    return cell;
}

- (void)      tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
	// Deselect the row
	[tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow]
                             animated: YES];

    // Check if we are locked
    BOOL locked = [self isIndexPathLocked: indexPath];
    if(locked)
    {
        [CCDUnlockHelper displayUnlockPopup];
        return;
    } // End of we are locked

    NSArray * targetArray;
    if(0 == indexPath.section)
    {
        targetArray = generalArray;
    }
    else
    {
        targetArray = holidayArray;
    }

    NSString * selectedColor = [targetArray objectAtIndex: indexPath.row];

	// Update our color value
	[[NSUserDefaults standardUserDefaults] setObject: selectedColor
                                              forKey: property];

    [colorTableView reloadData];

    [CCDSettingsViewController postSnowflakesNeedUpdate];
}

@end

