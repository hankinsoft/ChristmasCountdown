//
//  ChristmasImageViewController.m
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-11-07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChristmasImageViewController.h"

@interface ChristmasImageViewController()

@end


@implementation ChristmasImageViewController

- (void) setImage:(UIImage*)image
{
	// Update our image
	[imageView setImage: image];
}

+ (BOOL) isCustomImageSet
{
	// Check to see if the user has selected a custom image to use.
	// If the user has not, then we will display the default avatar image,
	// otherwise we will display the image that they have selected.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"UserImage.png"];
    
	DLog ( @"Want to load custom image from: %@", filePath );
    
	UIImage * tempImage = [UIImage imageWithContentsOfFile: filePath];
    
    return nil != tempImage;
}

+ (UIImage*) loadCustomImage
{
	// Check to see if the user has selected a custom image to use.
	// If the user has not, then we will display the default avatar image,
	// otherwise we will display the image that they have selected.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"UserImage.png"];

	DLog ( @"Want to load custom image from: %@", filePath );

	UIImage * tempImage = [UIImage imageWithContentsOfFile: filePath];

	if ( nil == tempImage )
	{
        DLog ( @"Custom image does not exists." );
        return [UIImage imageNamed: @"Avatar.png"];
	}

    DLog ( @"Custom image exists." );
    return tempImage;
} // End of loadCustomImage

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
