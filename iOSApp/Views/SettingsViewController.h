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

@interface SettingsViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {

    
    NSString *requestType;
    NSMutableData *recvData;
    
    NSString *rb_name;
    NSString *rb_username;
    NSString *rb_email;
}

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (strong, nonatomic) IBOutlet UIButton *uploadPictureButton;
@property (strong, nonatomic) IBOutlet UIButton *deletePictureButton;
@property (strong, nonatomic) IBOutlet UIButton *applicationsButton;
@property (strong, nonatomic) IBOutlet UIButton *findFriendsButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *saveSettingsButton;
@property (strong, nonatomic) IBOutlet UIView *nameContentView;
@property (strong, nonatomic) IBOutlet UIView *usernameContentView;
@property (strong, nonatomic) IBOutlet UIView *passwordContentView;
@property (strong, nonatomic) IBOutlet UIView *emailContentView;
@property (strong, nonatomic) IBOutlet UIButton *emailsButton;

@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *rb_name;
@property (nonatomic, retain) NSString *rb_username;
@property (nonatomic, retain) NSString *rb_email;



- (IBAction)onNameDeleteButton:(id)sender;
- (IBAction)onUsernameDeleteButton:(id)sender;
- (IBAction)onPasswordDeleteButton:(id)sender;
- (IBAction)onEmailDeleteButton:(id)sender;
- (IBAction)onUploadPictureButton:(id)sender;
- (IBAction)onDeletePictureButton:(id)sender;
- (IBAction)onApplicationsButton:(id)sender;
- (IBAction)onFindFriendsButton:(id)sender;
- (IBAction)onDeleteAccountButton:(id)sender;
- (IBAction)onLogOutButton:(id)sender;
- (IBAction)onSaveSettingsButton:(id)sender;
- (IBAction)onEmailsButton:(id)sender;



@end
