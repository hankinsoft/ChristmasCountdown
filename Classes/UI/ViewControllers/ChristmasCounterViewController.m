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
{
    IBOutlet UIScrollViewTouch      * scrollView;

    // Our info button
    UIButton                        * infoButton;

    CCDCountdownView                   * countdownView;
    CCDPageControl                  * pageControl;
}

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (void) updateImageView: (ChristmasImageViewController *) imageView forPage: (NSInteger) page;
- (void) fixScrollPosition;

- (void) fadeUIOut;
- (void) fadeUIIn;

@property (nonatomic, retain) NSDate * lastUpdatedTime;

@end

@implementation ChristmasCounterViewController
{
    NSMutableArray      * viewControllers;

    BOOL                timerEnabled;
    NSDate              * lastUpdatedTime;
}

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

    pageControl = [[CCDPageControl alloc] initWithFrame: CGRectMake(0, self.view.bounds.size.height - 30, self.view.bounds.size.width, 20)];
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
        [self showCrackedWarning];
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
	countdownView = [[CCDCountdownView alloc] initWithFrame: CGRectZero];

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

    [countdownView.heightAnchor constraintEqualToConstant: 240.0f].active = YES;

    // Init our timer
    [scrollView initTimer];

    timerEnabled = YES;
    
    self.lastUpdatedTime = nil;

    // Create our info button
    [self createInfoButton];

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

- (void) showCrackedWarning
{
    UIAlertController *alertController = nil;
    alertController = [UIAlertController alertControllerWithTitle:@"Cracked Version"
                                                          message:@"Hello. I see you are using a cracked version of Christmas Countdown. If you like this application, please support me by purchasing it."
                                                   preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"OK"
                                                       style: UIAlertActionStyleDefault
                                                     handler: ^(UIAlertAction *action) {
                                                         // Handle OK action
                                                     }];

    [alertController addAction:okAction];

    // Present the alert from your view controller
    [self presentViewController:alertController animated:YES completion:nil];
}

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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self showFirstLaunchInfo];
}

- (void) showFirstLaunchInfo
{
    if([NSUserDefaults.standardUserDefaults boolForKey: @"ShownFirstLaunchInfo"])
    {
        return;
    }

    [NSUserDefaults.standardUserDefaults setBool: YES
                                          forKey: @"ShownFirstLaunchInfo"];

    UIAlertController *reminderAlertController = nil;
    reminderAlertController = [UIAlertController alertControllerWithTitle: @"Don't Forget!"
                                                                  message: @"You can switch between backgrounds by sliding a finger on the main screen.\r\n\r\nYou can tap the info button to open the settings screen, which allows you to change a variety of options including the snowflake colors and the background music."
                                                           preferredStyle: UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"OK"
                                                       style: UIAlertActionStyleDefault
                                                     handler: nil];

    [reminderAlertController addAction: okAction];

    // Present the alert controller on the root view controller
    [self presentViewController: reminderAlertController
                       animated: YES
                     completion: nil];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    [super viewWillDisappear: animated];
}

#pragma mark CCDCountdownView

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

- (void)createInfoButton {
    infoButton = [UIButton buttonWithType:UIButtonTypeSystem];

    // Set the button's frame
    infoButton.frame = CGRectZero;

    // Set the button's background color
    UIColor *buttonColor = [UIColor colorWithRed:50/255.0 green:79/255.0 blue:133/255.0 alpha:1.0];

    // Use the 'info.circle' SF Symbol as the button's image
    UIImage *infoImage = [UIImage systemImageNamed:@"info.circle"];
    [infoButton setImage:infoImage forState:UIControlStateNormal];

    // Optional: Adjust the image's rendering mode if you want to apply the button's tint color to the image
    [infoButton setTintColor: buttonColor];

    // Set the button's title color
    [infoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    // Add action for tapping the button
    [infoButton addTarget: self
                   action: @selector(onInfo:)
         forControlEvents: UIControlEventTouchUpInside];

    // Add the button to the view
    [self.view addSubview: infoButton];
    infoButton.translatesAutoresizingMaskIntoConstraints = NO;

    // Set button constraints
    [infoButton.widthAnchor constraintEqualToConstant: 20].active = YES;
    [infoButton.heightAnchor constraintEqualToConstant: 20].active = YES;
    [infoButton.leftAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.leftAnchor
                                          constant: 20].active = YES;
    [infoButton.centerYAnchor constraintEqualToAnchor: pageControl.centerYAnchor].active = YES;
}

#pragma mark UIScrollView

- (void) loadScrollViewWithPage: (int) page
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

- (void)pageControlPageDidChange:(CCDPageControl *)aPageControl
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

	if ( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
	{
		// Size adjusted for navigation bar
		scrollView.frame = CGRectMake ( 0, scrollViewY, self.view.frame.size.width, self.view.frame.size.height );

		// Reposition the countdown view
		countdownView.frame = CGRectMake ( 0, 70, [[UIScreen mainScreen] applicationFrame].size.width, 300 );
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

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void) showSettings
{
    CCDSettingsViewController * settingsViewController = [[CCDSettingsViewController alloc] initWithNibName: @"CCDSettingsViewController" bundle: [NSBundle mainBundle]];

    [settingsViewController setChristmasCounterViewController: self];
    UINavigationController *tableNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    tableNavController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController: tableNavController
                       animated: YES
                     completion: ^{}];
}

- (IBAction) onInfo: (id) sender
{
    [self showSettings];
}

#if OLD_CODE

- (UIImage*) screenshot
{
	// Take a screenshot so that we can use it on the 'Share' link
	UIGraphicsBeginImageContext(CGSizeMake(320,460));
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return viewImage;
}

#else

- (UIImage *)screenshot {
    // Get the screen size
    CGRect screenSize = [UIScreen mainScreen].bounds;

    // Assuming the status bar height is standard across devices (usually 20 points)
    // Adjust this value if needed for specific devices
    CGFloat statusBarHeight = 20.0;

    // Define the new image context size, excluding the status bar
    CGSize contextSize = CGSizeMake(screenSize.size.width, screenSize.size.height - statusBarHeight);

    // Begin new image context
    UIGraphicsBeginImageContext(contextSize);

    // Calculate the area to capture
    CGRect captureRect = CGRectMake(0, statusBarHeight, screenSize.size.width, screenSize.size.height - statusBarHeight);

    // Render the view to the image context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -captureRect.origin.x, -captureRect.origin.y);
    [self.view.layer renderInContext:context];

    // Get the image
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return viewImage;
}

#endif

- (void) singleTapped
{
    [self fadeUIIn];
}

- (void) doubleTapped
{
    [self showSettings];
} // End of doubleTapped

- (void) updateControls: (id) sender
{
	if ( timerEnabled )
	{
        // Try to fade out
		[self fadeUIOut];
	}
} // End of updateControls:

- (void) fadeUIOut
{
    if (nil == self.lastUpdatedTime) return;

    // Check to see if we should fade out
    NSTimeInterval secondsElapsed = [[NSDate date] timeIntervalSinceDate:self.lastUpdatedTime];
    if (secondsElapsed < 4 || infoButton.alpha != 1.0) return;

    // Fade out the UI
    [UIView animateWithDuration:0.50 // .25 also looks nice
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self->infoButton.alpha = 0.0;
                         self->pageControl.alpha = 0.0;
                     }
                     completion:nil];
}

- (void) fadeUIIn
{
    // Update is now
    self.lastUpdatedTime = [NSDate date];

    // Fade in the UI
    [UIView animateWithDuration:0.50 // .25 also looks nice
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self->infoButton.alpha = 1.0;
                         self->pageControl.alpha = 1.0;
                     }
                     completion:nil];
}

@end
