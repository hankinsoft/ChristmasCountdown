//
//  MusicPickerViewController.h
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-10-31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"

@interface MusicPickerViewController : UIViewController <MPMediaPickerControllerDelegate, MBProgressHUDDelegate>
{
	// Could create a class to contain the music/artist, but that is to much work for this
	NSArray		* musicArray;
	UITableViewCell * checkedCell;

	MBProgressHUD                       * progressHUD;
    
    IBOutlet        UITableView         * tableView;
}

@end
