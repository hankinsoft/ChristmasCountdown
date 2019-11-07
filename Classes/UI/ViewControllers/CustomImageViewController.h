//
//  CustomImageController.h
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-12-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChristmasCountdownAppDelegate.h"

@interface CustomImageViewController : UITableViewController <UIImagePickerControllerDelegate>
{
	UIImagePickerController     * imagePickerController;
    UIPopoverController         * popover;
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end
