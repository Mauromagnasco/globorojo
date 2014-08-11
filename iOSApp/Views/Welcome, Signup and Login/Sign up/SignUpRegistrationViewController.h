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
#import "SearchViewController.h"

@interface SignUpRegistrationViewController : UIViewController <UITextFieldDelegate> {
    
    CustomActivityIndicatorView *activityView;
    NSMutableData *recvData;
    
    NSString *name;
    NSString *photoUrl;
    NSString *userSnsId;
}


@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *usernameDeleteButton;

@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *photoUrl;
@property (nonatomic, retain) NSString *userSnsId;

- (IBAction)onBackButton:(id)sender;
- (IBAction)onEmailAddressDeleteButton:(id)sender;
- (IBAction)onPasswordDeleteButton:(id)sender;
- (IBAction)onNameDeleteButton:(id)sender;
- (IBAction)onUsernameDeleteButton:(id)sender;
- (IBAction)onConfirmButton:(id)sender;



@end
