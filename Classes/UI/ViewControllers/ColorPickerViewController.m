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

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSArray * targetArray;
    if(0 == indexPath.section)
    {
        targetArray = generalArray;
    }
    else
    {
        targetArray = holidayArray;
    }

	// Grab the name of the cell from the array
	[cell.textLabel setText: (NSString*)[targetArray objectAtIndex: indexPath.row]];

	// If this is our selected color, then checkmark it
	if ( [[[NSUserDefaults standardUserDefaults] stringForKey: property] isEqual: [[cell textLabel] text]] )
	{
		[cell setAccessoryType: UITableViewCellAccessoryCheckmark];
	}
    else
    {
		[cell setAccessoryType: UITableViewCellAccessoryNone];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Deselect the row
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];

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

