//
//  CustomImageController.m
//  ChristmasCountdown
//
//  Created by Kyle Hankinson on 09-12-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CustomImageViewController.h"
#import "ChristmasImageViewController.h"

@interface CustomImageViewController()<UIImagePickerControllerDelegate>

- (UIImage *)scaleAndRotateImage:(UIImage *)image;

@end

@implementation CustomImageViewController

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */


- (void)viewDidLoad
{
    [super viewDidLoad];

	[self setTitle: @"Custom Image"];

	// Set up the image picker controller and add it to the view
	imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Image Source";
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Three rows if our device has a camera, but only two if we dont
	if ( [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] )
	{
		return 3;
	}
	else
	{
		return 2;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomImageCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Default, no accessory
    [cell setAccessoryType: UITableViewCellAccessoryNone];

    // Set up the cell...
	switch ( indexPath.row )
	{
		case 0:
		{
            // If we do not have a custom image, then we will put a checkmark on our
            // "Default Image" cell.
            if(![ChristmasImageViewController isCustomImageSet])
            {
                [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
            }
			[[cell textLabel] setText: @"Default Image"];
			break;
		}
		case 1:
		{
			[[cell textLabel] setText: @"Library"];
			[cell setAccessoryType:	UITableViewCellAccessoryDisclosureIndicator];
			break;
		}
		case 2:
		{
			[[cell textLabel] setText: @"Camera"];
			[cell setAccessoryType:	UITableViewCellAccessoryDisclosureIndicator];
			break;
		}
	} // End of row switch

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Deselect the row
	[tableView deselectRowAtIndexPath: indexPath animated:YES];

    CGRect popoverRect = [tableView convertRect:[tableView rectForRowAtIndexPath:indexPath]
                                  toView:tableView];

	switch ( indexPath.row )
	{
		case 0:
		{
			// Just delete the image from our documents
			NSFileManager *fileManager = [NSFileManager defaultManager];

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"UserImage.png"];
			[fileManager removeItemAtPath:filePath error:NULL];

			// Load our image
            [[ChristmasCountdownAppDelegate instance] updateCustomImage];

            // Reload our data
            [self.tableView reloadData];

			break;
		}
		case 1:
		{
			// Picker from library
			imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                popover = [[UIPopoverController alloc] initWithContentViewController: imagePickerController];
                
                [popover presentPopoverFromRect: popoverRect
                                         inView: tableView
                       permittedArrowDirections: UIPopoverArrowDirectionAny
                                       animated:YES];
            }
            else
            {
                [self presentViewController: imagePickerController
                                   animated: YES
                                 completion: ^{}];
            }
			break;
		}
		case 2:
		{
			// Picker from camera
			imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                popover = [[UIPopoverController alloc] initWithContentViewController: imagePickerController];

                [popover presentPopoverFromRect: popoverRect
                                         inView: tableView
                       permittedArrowDirections: UIPopoverArrowDirectionAny
                                       animated: YES];
            }
            else
            {
                [self presentViewController: imagePickerController
                                   animated: YES
                                 completion: ^{}];
            }
            
			break;
		}
	}
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark Image Picker methods

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
    [popover dismissPopoverAnimated: YES];
	[picker dismissViewControllerAnimated: YES
                               completion: ^{}];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"UserImage.png"];

	NSData * imageData = [NSData dataWithData: UIImagePNGRepresentation([self scaleAndRotateImage: image])];
	[imageData writeToFile: filePath atomically:YES];

	// Load our image
	[[ChristmasCountdownAppDelegate instance] updateCustomImage];

    // Reload our data
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated: YES
                               completion: ^{}];
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image

{
    
    int kMaxResolution = 480; 
    
    
    CGImageRef imgRef = image.CGImage;
    
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) 
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;     
        default:
//            [NSException raise :NSInternalInconsistencyExceptionformat:@"Invalid image orientation"];
            break;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end

