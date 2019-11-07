//
//  ChristmasCounterViewController.m
//  ChristmasCounter
//
//  Created by Kyle Hankinson on 04/08/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ChristmasCounterViewController.h"
#import "ChristmasCountdownAppDelegate.h"
#import "UIScrollViewTouch.h"

#define CUSTOM_IMAGE_PAGE   4

@interface ChristmasCounterViewController ()

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (void) updateImageView: (ChristmasImageViewController *) imageView forPage: (NSInteger) page;
- (void) fixScrollPosition;

- (void) fadeUIOut;
- (void) fadeUIIn;

@property (nonatomic, retain) NSDate * lastUpdatedTime;
@end

@implementation ChristmasCounterViewController

@synthesize lastUpdatedTime;
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

#define kNumberOfPages 5

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"View is: %0.0fx%0.0f", self.view.frame.size.width, self.view.frame.size.height);

    scrollView.touchDelegate = self;

    pageControl = [[PageControl alloc] initWithFrame: CGRectMake(0, self.view.bounds.size.height - 30, self.view.bounds.size.width, 20)];
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.delegate = self;
    pageControl.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:pageControl];
    [pageControl.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = YES;
    [pageControl.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = YES;
    [pageControl.heightAnchor constraintEqualToConstant: 20.0f].active = YES;
    [pageControl.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor
                                             constant: -30.f].active = YES;

	NSBundle *bundle = [NSBundle mainBundle]; 
	NSDictionary *info = [bundle infoDictionary]; 
	// If the SignerIdentity exists (aka, we are cracked)
	if ([info objectForKey: @"SignerIdentity"] != nil) 
	{
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Cracked Version" message: @"Hello. I see you are using a cracked version of Christmas Countdown. If you like this application, please support me by purchasing it." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
	}

    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }

    viewControllers = controllers;

    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;

    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage: 0];
    [self loadScrollViewWithPage: 1];
    [self loadScrollViewWithPage: 2];
    [self loadScrollViewWithPage: 3];
    [self loadScrollViewWithPage: 4];

	// Set our page
	{
		CGFloat pageWidth = scrollView.frame.size.width;
		NSInteger currentPage = [[NSUserDefaults standardUserDefaults] integerForKey: @"ScrollPage"];

        pageControl.currentPage = currentPage;

		// Change our offset
		[scrollView setContentOffset: CGPointMake ( currentPage * pageWidth, 0 )];
	}

	// Create & add the countdown view
	countdownView = [[CountdownView alloc] initWithFrame: CGRectZero];

	// No user interaction
	[countdownView setUserInteractionEnabled: NO];
    
    countdownView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: countdownView];
    [countdownView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = YES;
    [countdownView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = YES;

    if(@available(iOS 11.0, *))
    {
        [countdownView.topAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.topAnchor
                                                constant: 20.0f].active = YES;
    }
    else
    {
        [countdownView.topAnchor constraintEqualToAnchor: self.view.topAnchor
                                                constant: 20.0f].active = YES;
    }

    [countdownView.heightAnchor constraintEqualToConstant: 200.0f].active = YES;

    // Init our timer
    [scrollView initTimer];

    timerEnabled = YES;
    
    self.lastUpdatedTime = nil;

    // Update once a second
    [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                     target: self
                                   selector: @selector(updateControls:)
                                   userInfo: nil
                                    repeats: YES];

    [NSNotificationCenter.defaultCenter addObserver: self
                                           selector: @selector(onSnowflakesNeedUpdate)
                                               name: kSnowflakesNeedUpdate
                                             object: nil];
} // End of viewDidLoad:

- (void) dealloc
{
} // End of dealloc

- (void) onSnowflakesNeedUpdate
{
    [scrollView updateSnowflakes];
} // End of onSnowflakesNeedUpdate

- (void) viewWillAppear: (BOOL) animated
{
    [scrollView updateSnowflakes];
    self.lastUpdatedTime = [NSDate date];
    [self fadeUIIn];
    
    [[UIApplication sharedApplication] setStatusBarHidden: YES];
    [super viewWillAppear: animated];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    [super viewWillDisappear: animated];
}

#pragma mark CountdownView

- (void) disableCountdown
{
	[countdownView disableCountdown];
    timerEnabled = NO;
}

- (void) enableCountdown
{
	[countdownView enableCountdown];
    timerEnabled = YES;
}

#pragma mark UIScrollView

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0) return;
    if (page >= kNumberOfPages) return;

    // replace the placeholder if necessary
    ChristmasImageViewController *controller = [viewControllers objectAtIndex:page];

    if ((NSNull *)controller == [NSNull null])
	{
        controller = [[ChristmasImageViewController alloc]
					  initWithNibName: @"ChristmasImageViewController"
					  bundle: [NSBundle mainBundle]];
        [viewControllers replaceObjectAtIndex:page withObject:controller];
    }

    // add the controller's view to the scroll view
    if (nil == controller.view.superview)
	{
        [self updateImageView: controller forPage:page];

		// Add the view to the scrollview
        [scrollView addSubview:controller.view];
    } // End of controller not loaded
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.

    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];

    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    CGFloat pageWidth = aScrollView.frame.size.width;
    int page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    [[NSUserDefaults standardUserDefaults] setInteger:page forKey:@"ScrollPage"];
    pageControl.currentPage = page;

    // Display the info until it goes away
    [self fadeUIIn];
}

- (void)pageControlPageDidChange:(PageControl *)aPageControl
{
	// Set our page
	CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger newPage = aPageControl.currentPage;

	// Change our offset
	[scrollView setContentOffset: CGPointMake ( newPage * pageWidth, 0 )];

    [self fadeUIIn];
} // End of pageControlPageDidChange

// Override to allow orientations other than the default portrait orientation.
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Just portrait
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog ( @"Rotated with new size: %fx%f", self.view.frame.size.width, self.view.frame.size.height );

    int scrollViewY = 0;

    // Only show ads in portrait
    if(bannerIsVisible && ( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) )
    {
        scrollViewY -= [adView frame].size.height;
    }

	if ( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
	{
		// Size adjusted for navigation bar
		scrollView.frame = CGRectMake ( 0, scrollViewY, self.view.frame.size.width, self.view.frame.size.height );

		// Reposition the countdown view
		countdownView.frame = CGRectMake ( 0, 70, [[UIScreen mainScreen] applicationFrame].size.width, 300 );

        if(bannerIsVisible)
        {
            CGRect newFrame = [adView frame];
            newFrame.origin.y = self.view.frame.size.height - [adView frame].size.height;
            [adView setFrame: newFrame];
        }
	}
    // Vertical
	else
	{
		// Size adjusted for navigation bar
		scrollView.frame = CGRectMake ( 0, scrollViewY, self.view.frame.size.width, self.view.frame.size.height );
		countdownView.frame = CGRectMake ( 0, 10, [[UIScreen mainScreen] applicationFrame].size.width, 300 );
	}

	// Update our content size
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    
	[self updateImageView: [viewControllers objectAtIndex: 0] forPage: 0];
	[self updateImageView: [viewControllers objectAtIndex: 1] forPage: 1];
	[self updateImageView: [viewControllers objectAtIndex: 2] forPage: 2];
	[self updateImageView: [viewControllers objectAtIndex: 3] forPage: 3];
    
	// Fix our scroll position
	[self fixScrollPosition];
}

- (void) fixScrollPosition
{
	CGFloat pageWidth = scrollView.frame.size.width;
	NSInteger currentPage = [[NSUserDefaults standardUserDefaults] integerForKey: @"ScrollPage"];
    pageControl.currentPage = currentPage;
    
	// Change our offset
	[scrollView setContentOffset: CGPointMake ( currentPage * pageWidth, 0 )];
}

- (void) updateImageView: (ChristmasImageViewController *) imageView forPage: (NSInteger) page
{
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;

    imageView.view.frame = frame;
    UIImage * image = nil;

    switch ( page )
    {
        default:
        {
            // Fallthrough. Default should do the same as case zero.
        }
        case 0:
        {
            if([ChristmasCountdownAppDelegate iPad])
            {
                image = [UIImage imageNamed: @"Snowman-iPad.png"];
            }
            else if([ChristmasCountdownAppDelegate iPhone5])
            {
                image = [UIImage imageNamed: @"Snowman-568h@2x.png"];
            }
            else
            {
                image = [UIImage imageNamed: @"Snowman.png"];
            }
            break;
        }
        case 1:
        {
            if([ChristmasCountdownAppDelegate iPad])
            {
                image = [UIImage imageNamed: @"Santa-iPad.png"];
            }
            else if([ChristmasCountdownAppDelegate iPhone5])
            {
                image = [UIImage imageNamed: @"Santa-568h@2x.png"];
            }
            else
            {
                image = [UIImage imageNamed: @"Santa.png"];
            }
            break;
        }
        case 2:
        {
            if([ChristmasCountdownAppDelegate iPad])
            {
                image = [UIImage imageNamed: @"Reindeer-iPad.png"];
            }
            else if([ChristmasCountdownAppDelegate iPhone5])
            {
                image = [UIImage imageNamed: @"Reindeer-568h@2x.png"];
            }
            else
            {
                image = [UIImage imageNamed: @"Reindeer.png"];
            }
            break;
        }
        case 3:
        {
            if([ChristmasCountdownAppDelegate iPad])
            {
                image = [UIImage imageNamed: @"Elf-iPad.png"];
            }
            else if([ChristmasCountdownAppDelegate iPhone5])
            {
                image = [UIImage imageNamed: @"Elf-568h@2x.png"];
            }
            else
            {
                image = [UIImage imageNamed: @"Elf.png"];
            }
            break;
        }
        case CUSTOM_IMAGE_PAGE:
        {
            // Load our custom image
            image = [ChristmasImageViewController loadCustomImage];
            break;
        } // End of custom
    } // End of page switch

    // Set our imageName
    [imageView setImage: image];
} // End of updateImageView

- (void) updateCustomImage
{
	[self updateImageView: [viewControllers objectAtIndex: CUSTOM_IMAGE_PAGE] forPage: CUSTOM_IMAGE_PAGE];
} // End of updateCustomImage

#pragma mark -
#pragma mark ADBannerView

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	DLog ( @"Banner did load" );

	if (!bannerIsVisible)
	{
		DLog ( @"Was not visible" );

        // Only display the banner if we are in portrait
        if ( ( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) )
        {
            [UIView beginAnimations:@"animateAdBannerOn" context:NULL];

            CGRect newFrame = banner.frame;
            newFrame.origin.y = self.view.frame.size.height - banner.frame.size.height;
            banner.frame = newFrame;

            CGRect scrollFrame = scrollView.frame;
            scrollFrame.origin.y = -banner.frame.size.height;
            scrollView.frame = scrollFrame;

            [UIView commitAnimations];
        }
		bannerIsVisible = YES;
	}
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	DLog ( @"Failed to load the banner: %@", [error localizedDescription] );

	if (bannerIsVisible)
	{
		DLog ( @"And was visible" );
		[UIView beginAnimations:@"animateAdBannerOff" context:NULL];

		// banner is visible and we move it out of the screen, due to connection issue
		banner.frame = CGRectOffset(banner.frame, 0, self.view.frame.size.height + 50);

		CGRect scrollFrame = scrollView.frame;
        scrollFrame.origin.y = 0;
		scrollView.frame = scrollFrame;

		[UIView commitAnimations];
		bannerIsVisible = NO;
	}
}

#pragma mark -

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction) onInfo: (id) sender
{
    SettingsViewController * settingsViewController = [[SettingsViewController alloc] initWithNibName: @"SettingsViewController" bundle: [NSBundle mainBundle]];
    
    [settingsViewController setChristmasCounterViewController: self];
    UINavigationController *tableNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    tableNavController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController: tableNavController
                       animated: YES
                     completion: ^{}];
}

- (UIImage*) screenshot
{
	// Take a screenshot so that we can use it on the 'Share' link
	UIGraphicsBeginImageContext(CGSizeMake(320,460));
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return viewImage;
}

- (void) singleTapped
{
    NSLog(@"Single tapped");
    [self fadeUIIn];
}

- (void)doubleTapped
{
	SettingsViewController * settingsViewController = [[SettingsViewController alloc] initWithNibName: @"SettingsViewController" bundle: [NSBundle mainBundle]];
        
	[settingsViewController setChristmasCounterViewController: self];

	UINavigationController *tableNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
        
	tableNavController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:tableNavController animated:YES];
}

- (void)updateControls:(id)sender
{
	if ( timerEnabled )
	{
        // Try to fade out
		[self fadeUIOut];
	}
}

- (void) fadeUIOut
{
    if(nil == self.lastUpdatedTime) return;

    // Check to see if we should fade out
    NSTimeInterval secondsElapsed =     [[NSDate date] timeIntervalSinceDate: self.lastUpdatedTime];
    if(secondsElapsed < 4 || infoButton.alpha != 1.0) return;

    // End of fade UI
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.50];  //.25 looks nice as well.

    // Fade the info button
	infoButton.alpha = 0.0;
    pageControl.alpha = 0.0;
	[UIView commitAnimations];
}

- (void) fadeUIIn
{
    // Update is now
    self.lastUpdatedTime = [NSDate date];

    // End of fade UI
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.50];  //.25 looks nice as well.

    // Fade the info button
	infoButton.alpha = 1.0;
    pageControl.alpha = 1.0;
	[UIView commitAnimations];
}

@end
