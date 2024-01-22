//
//  MusicPickerViewController.m
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-10-31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChristmasCountdownAppDelegate.h"
#import "MusicPickerViewController.h"


@implementation MusicPickerViewController

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

    self.preferredContentSize = CGSizeMake(320.0, 600.0);

	// We are on the music page
	[self setTitle: @"Music"];

	musicArray = [[NSArray alloc] initWithObjects:
                  @"Angels We Have Heard",
                  @"Christmas Rap",
                  @"Deck the Halls (Slow)",
                  @"Deck the Halls (Fast)",
				  @"Jingle Bells",
				  @"Oh Christmas Tree",
				  @"Oh Holy Night",
                  @"Silent Night",
                  @"Up on a Housetop",
                  @"We Wish You a Merry Christmas",
				  @"What Child is This",
				  nil];
}

- (void)viewWillAppear:(BOOL)animated
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	switch ( section )
	{
			// First section is the iPod list
		case 0: return 1;
			// Second section is the iPod list
		case 1: return [musicArray count];
			// Default shouldnt happen
		default: return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
		if ( 0 == indexPath.section )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		}
		else
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
    }

	if ( 0 == indexPath.section )
	{
		// Set up the cell...
		[[cell textLabel] setText: @"Select a song..."];
		[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];

		if ( nil != [[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] mediaItemPropertyPersistentID] )
		{
			MPMediaPropertyPredicate *persistendIDPredicate =
			[MPMediaPropertyPredicate predicateWithValue: [[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] mediaItemPropertyPersistentID]
											 forProperty: MPMediaItemPropertyPersistentID];

			MPMediaQuery *persistentIDQuery = [[MPMediaQuery alloc] init];
			[persistentIDQuery addFilterPredicate: persistendIDPredicate];

			// Init our mediaItemCollection with the songs we found
			MPMediaItemCollection * mediaItemCollection = [[MPMediaItemCollection alloc] initWithItems: [persistentIDQuery items]];
			MPMediaItem * mediaItem = [[mediaItemCollection items] objectAtIndex: 0];

			// Set our detail to be the song title
			[[cell detailTextLabel] setText: [mediaItem valueForProperty: MPMediaItemPropertyTitle]];
		} // End of mediaItemPropertyPersistentID exists
	}
	// If we are the 'classic' section, then list our music in the array
	else if ( 1 == indexPath.section )
	{
		// Set up the cell...
		[[cell textLabel] setText: [musicArray objectAtIndex: indexPath.row]];

		// If this is our selected Music, then checkmark it
		if ( nil == [[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] mediaItemPropertyPersistentID] && 
			[[[NSUserDefaults standardUserDefaults] stringForKey:@"Music"] isEqual: [musicArray objectAtIndex: indexPath.row]])
		{
			[cell setAccessoryType: UITableViewCellAccessoryCheckmark];
			checkedCell = cell;
		}
	}

    return cell;
}

- (NSString *)tableView: (UITableView *)aTableView
titleForHeaderInSection: (NSInteger)section
{
	if ( 0 == section )
	{
		return @"MUSIC LIBRARY";
	}
	else
	{
		return @"Christmas Classics";
	}
}

- (NSString *) tableView: (UITableView *) aTableView
 titleForFooterInSection: (NSInteger) section
{
	if ( 1 == section )
	{
		return @"Christmas Classics by: Kevin MacLeod\r\nhttp://incompetech.com";
	}
	else
	{
		return @"";
	}
}

- (void)tableView:(UITableView *)aTableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Deselect the row
	[aTableView deselectRowAtIndexPath: [aTableView indexPathForSelectedRow]
                              animated: YES];

	// If we are picking from the iPod library
	if ( 0 == indexPath.section )
	{
// The simulator does not support access to the music library. So instead of trying to show
// the dialog, we will display a message to the developer.
#if !TARGET_IPHONE_SIMULATOR
		MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
		mediaPicker.delegate = self;
		mediaPicker.allowsPickingMultipleItems = NO; // this is the default   

		// Deselect the row
		[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];

		[self presentViewController: mediaPicker
                           animated: YES
                         completion: ^{}];
#else
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Simulator Error"
                                                                                 message:@"Unable to launch the media picker when using the simulator."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
#endif
	} // End of picking from the iPod library
	// If the user is picking from the classics section
	else if ( 1 == indexPath.section )
	{
        // Uncheck the current checked cell
        [checkedCell setAccessoryType: UITableViewCellAccessoryNone];
        
        // Update our checked call
        checkedCell = [aTableView cellForRowAtIndexPath:indexPath];
        [checkedCell setAccessoryType: UITableViewCellAccessoryCheckmark];

        // If the audio does not exist, try downloading it
        if ( ![[NSFileManager defaultManager] fileExistsAtPath: [CCDAudioController pathForAudio: [musicArray objectAtIndex: indexPath.row]]] )
        {
            // The hud will dispable all input on the view
            progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
            progressHUD.label.text = @"Downloading Music";
            progressHUD.mode = MBProgressHUDModeIndeterminate;

            // Add HUD to screen
            [self.navigationController.view addSubview: progressHUD];

            // Show the progress HUD
            [progressHUD showAnimated: NO];

            [self performSelectorInBackground:@selector(downloadMusic:) withObject: [musicArray objectAtIndex: indexPath.row]];
        } // End of audio does not exist
        else
        {
            // Set our sond & restart the music
            [[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] setSong: [musicArray objectAtIndex: indexPath.row]];
            [[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] restart];
        } // End of audio does exist
	} // End of classics
}

- (void) downloadMusic: (id) target
{
    @autoreleasepool
    {
        NSString * songName = (NSString*)target;
        NSString * musicPath = [NSString stringWithFormat: @"https://christmas-countdown-hankinsoft.s3.us-west-1.amazonaws.com/%@.mp3",
                                [songName stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];

        NSError * error = nil;
        NSData * data = [NSData dataWithContentsOfURL: [NSURL URLWithString: musicPath]
                                              options: 0
                                                error: &error];

        #pragma unused(error)

        dispatch_async(dispatch_get_main_queue(), ^{
            if(nil == data)
            {
                UIAlertController *alertController = nil;
                alertController = [UIAlertController alertControllerWithTitle: @"Failed to Download"
                                                                      message: @"The selected song was unable to be downloaded. Please make sure you have an active network connection the first time a song is selected."
                                                               preferredStyle: UIAlertControllerStyleAlert];

                UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"OK"
                                                                   style: UIAlertActionStyleDefault
                                                                 handler: nil];

                [alertController addAction:okAction];
                [self presentViewController: alertController
                                   animated: YES
                                 completion: nil];
            }
            else
            {
                // Save our data and play the music
                [data writeToFile: [CCDAudioController pathForAudio: songName] atomically:YES];

                // Set our sond & restart the music
                [[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] setSong: songName];
                [[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] restart];
            } // End of file was saved

            [self->progressHUD hideAnimated: YES];
        });
    }
}

#pragma mark Media Picker delegates

// Media picker delegate methods
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker
  didPickMediaItems: (MPMediaItemCollection *)mediaItemCollection
{
	// We need to dismiss the picker
	[self dismissViewControllerAnimated: YES
                             completion: ^{}];

	MPMediaItem * mediaItem = [[mediaItemCollection items] objectAtIndex: 0];

	// Set our sond & restart the music
	[[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] setSongMediaItem: mediaItem];
	[[(ChristmasCountdownAppDelegate *)[[UIApplication sharedApplication] delegate] audioController] restart];

	// Reload our table
	[tableView reloadData];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    // User did not select anything
    // We need to dismiss the picker
    [self dismissViewControllerAnimated: YES
                             completion: ^{}];
}

@end

