//
//  CCDAudioController.m
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-12-22.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CCDAudioController.h"


@implementation CCDAudioController
{
    AVAudioPlayer                    * player;
    MPMusicPlayerController            * musicPlayer;
    bool                            playingCustomMusic;
    
    NSTimeInterval                  playbackTime;

    NSNumber                        * mediaItemPropertyPersistentID;
}

@synthesize playingCustomMusic, musicPlayer, mediaItemPropertyPersistentID;

- (id) init
{
	// If no music is set, then default to jingle bells
	if ( 0 == [[[NSUserDefaults standardUserDefaults] stringForKey:@"Music"] length] )
	{
		// Default our song to be jingle-bells
		[[NSUserDefaults standardUserDefaults] setObject: @"Jingle Bells"
                                                  forKey: @"Music"];
	}

	if ( self = [super init] )
	{
		// Restart our song
		[self restart];
	}

    // Register for the 'enter background' notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    // Register for the 'enter foreground' notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

	return self;
} // End of init

- (void) restart
{
#if !TARGET_IPHONE_SIMULATOR
	// Update our music value
	mediaItemPropertyPersistentID = [[NSUserDefaults standardUserDefaults] objectForKey:@"MPMediaItemPropertyPersistentID"];
	
	if ( nil != mediaItemPropertyPersistentID )
	{
		// We are playing custom music
		playingCustomMusic = YES;

		MPMediaPropertyPredicate *persistendIDPredicate =
		[MPMediaPropertyPredicate predicateWithValue: mediaItemPropertyPersistentID forProperty: MPMediaItemPropertyPersistentID];
		
		MPMediaQuery *persistentIDQuery = [[MPMediaQuery alloc] init];
		[persistentIDQuery addFilterPredicate: persistendIDPredicate];
		
		// Init our mediaItemCollection with the songs we found
		MPMediaItemCollection * mediaItemCollection = [[MPMediaItemCollection alloc] initWithItems: [persistentIDQuery items]];
		
		self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
		[self.musicPlayer setQueueWithItemCollection: mediaItemCollection];
		
		// start playing from the beginning of the queue
		[self.musicPlayer play];

		// Do not let continue
		return;
	} // End of using_iPodMusicLibrary
#endif
	
	// Not playing custom music
	playingCustomMusic = NO;
	
	// If we have a player, stop it and release it
	if ( nil != player )
	{
		[player stop];
        player = nil;
	}

	NSString *resourcePath = [CCDAudioController pathForAudio: [[NSUserDefaults standardUserDefaults] stringForKey:@"Music"]];
	DLog(@"Path to play: %@", resourcePath);
    if(nil == resourcePath)
    {
        DLog(@"Song is not available for play.");
        return;
    } // End of file does not exist

	NSError* err;

	//Initialize our player pointing to the path to our resource
	player = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:resourcePath] error:&err];
	
	// Loop forever
	[player setNumberOfLoops: -1];

	if( err )
	{
		//bail!
		NSLog(@"Failed with reason: %@", [err localizedDescription]);
	}
	else
	{
		// Start the playback
		[player play];
	}
}

- (void) setSong: (NSString*) songName
{
	// Update our music value
	[[NSUserDefaults standardUserDefaults] setObject: songName forKey:@"Music"];
	// Make sure our media item is cleared, so that we do not use it
	[[NSUserDefaults standardUserDefaults] setObject: nil forKey:@"MPMediaItemPropertyPersistentID"];
	// Not playing custom music
	playingCustomMusic = NO;
	// No media item property persistent id
	mediaItemPropertyPersistentID = nil;
}

- (void) setSongMediaItem: (MPMediaItem*) mediaItem
{
	// Clear our music item
	[[NSUserDefaults standardUserDefaults] setObject: nil
                                              forKey: @"Music"];
	// Get our media item property persistent id
	mediaItemPropertyPersistentID = [mediaItem valueForProperty: MPMediaItemPropertyPersistentID];
	// Set our mediaItem
	[[NSUserDefaults standardUserDefaults] setObject: mediaItemPropertyPersistentID forKey:@"MPMediaItemPropertyPersistentID"];

	// Playing our custom music
	playingCustomMusic = YES;
}

- (NSString*) songName
{
	// If we are playing custom music, then we will find and return the song title
	if ( playingCustomMusic )
	{
		// Find the name of the song we were playing via ipod
		MPMediaPropertyPredicate *persistendIDPredicate =
		[MPMediaPropertyPredicate predicateWithValue: mediaItemPropertyPersistentID forProperty: MPMediaItemPropertyPersistentID];
		
		MPMediaQuery *persistentIDQuery = [[MPMediaQuery alloc] init];
		[persistentIDQuery addFilterPredicate: persistendIDPredicate];

		// Init our mediaItemCollection with the songs we found
		MPMediaItemCollection * mediaItemCollection = [[MPMediaItemCollection alloc] initWithItems: [persistentIDQuery items]];

		return [[[mediaItemCollection items] objectAtIndex: 0] valueForProperty: MPMediaItemPropertyTitle];
	}
	else
	{
		// Song name is from nsdefaults
		return [[NSUserDefaults standardUserDefaults] stringForKey:@"Music"];
	}

}

+ (NSString*) pathForAudio: (NSString*) songName
{
	NSString *resourcePath = [[NSBundle mainBundle] pathForResource: songName ofType:@"mp3"];
    
    // Check and see if the file exists in our resource path
    if([[NSFileManager defaultManager] fileExistsAtPath: resourcePath])
    {
        return resourcePath;
    } // End of the file existed

    // First check to see if it already exists in the documents path
    resourcePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    resourcePath = [resourcePath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.mp3", songName]];

    // If it does, we will use that path.
    if([[NSFileManager defaultManager] fileExistsAtPath: resourcePath])
    {
        return resourcePath;
    }

    // Lastly, use the cache path (this is where it will be downloaded as well)
    resourcePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    resourcePath = [resourcePath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.mp3", songName]];

    return resourcePath;
} // End of pathForAudit

- (void) pause
{
    playbackTime = 0;
    if(!playingCustomMusic) return;

    playbackTime = [musicPlayer currentPlaybackTime];
}

- (void) resume
{
    if(!playingCustomMusic) return;

    //musicPlayer
    if(playbackTime != 0)
    {
        [self.musicPlayer setCurrentPlaybackTime: playbackTime];
    }

    [self.musicPlayer play];
}

- (void)appDidEnterBackground:(NSNotification *)notification {
    // Pause the music when the app enters the background
    if (playingCustomMusic) {
        [musicPlayer pause];
    } else if (player) {
        [player pause];
    }
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    // Resume the music when the app enters the foreground
    if (playingCustomMusic) {
        [musicPlayer play];
    } else if (player) {
        [player play];
    }
}

- (void) dealloc
{
    // Unregister all notifications for this object
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
