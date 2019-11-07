//
//  ChristmasImageViewController.h
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-11-07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChristmasImageViewController : UIViewController
{
	IBOutlet UIImageView * imageView;
}

- (void) setImage:(UIImage*)image;
+ (UIImage*) loadCustomImage;
+ (BOOL) isCustomImageSet;

@end
