/**
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 */

#import <UIKit/UIKit.h>
#import "CustomActivityIndicatorView.h"
#import "REMenu.h"
#import "NLImageCropperView.h"
#import "AppDelegate.h"
#import "SearchViewController.h"

@interface UploadPictureViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {

    NSString *userPhotoUrl;
    NSString *requestType;
    NSMutableData *recvData;
    
    UIImage *uploadImage;
    
    CustomActivityIndicatorView *activityView;
    REMenu *menu;
    NLImageCropperView *imageCropper;
}


@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *uploadPictureButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, retain) NSString *userPhotoUrl;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) REMenu *menu;
@property (nonatomic, retain) UIImage *uploadImage;
@property (nonatomic, retain) NLImageCropperView *imageCropper;



- (IBAction)onBackButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (IBAction)onUploadPictureButton:(id)sender;
- (IBAction)onConfirmButton:(id)sender;



@end
