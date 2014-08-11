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

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate> {

    CustomActivityIndicatorView *activityView;
    NSMutableData *recvData;
    NSString *requestType;
    BOOL isEditing;
}

@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;

- (IBAction)onBackButton:(id)sender;
- (IBAction)onFBLoginButton:(id)sender;
- (IBAction)onTWLoginButton:(id)sender;
- (IBAction)onEmailAddressDeleteButton:(id)sender;
- (IBAction)onPasswordDeleteButton:(id)sender;
- (IBAction)onConfirmButton:(id)sender;
- (IBAction)onForgotPasswordButton:(id)sender;

@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *requestType;

@end
