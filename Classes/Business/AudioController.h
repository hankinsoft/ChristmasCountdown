//
//  AudioController.h
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-12-22.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioController : NSObject
{
	AVAudioPlayer					* player;
	MPMusicPlayerController			* musicPlayer;
	bool							playingCustomMusic;
    
    NSTimeInterval                  playbackTime;

	NSNumber						* mediaItemPropertyPersistentID;
}

+ (NSString*) pathForAudio: (NSString*) songName;
- (id) init;
- (void) restart;

- (void) setSong:(NSString*)songName;
- (void) setSongMediaItem:(MPMediaItem*)mediaItem;

- (NSString*) songName;

- (void) pause;
- (void) resume;

@property (nonatomic, assign) bool playingCustomMusic;
@property (nonatomic, retain) MPMusicPlayerController	* musicPlayer;
@property (nonatomic, retain) NSNumber					* mediaItemPropertyPersistentID;

@end
