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

#import "SettingsViewController.h"
#import "Constants.h"
#import "UploadPictureViewController.h"
#import "AppDelegate.h"
#import "SBJson.h"
#import "UserController.h"
#import "ApplicationViewController.h"
#import "FindFriendsViewController.h"
#import "WelcomeViewController.h"
#import "AppSharedData.h"
#import "EmailsViewController.h"


#define REQUEST_FOR_DELETEPROFILE                   @"deleteProfile"
#define REQUEST_FOR_DELETEACCOUNT                   @"deleteAccount"
#define REQUEST_FOR_DELETEACCOUNT_SUCCESS           @"deleteAccountSuccess"
#define REQUEST_FOR_LOGOUT                          @"logout"
#define REQUEST_FOR_SAVEPROFILE                     @"saveProfile"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize nameTextField;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize emailAddressTextField;
@synthesize uploadPictureButton;
@synthesize deleteAccountButton;
@synthesize deletePictureButton;
@synthesize applicationsButton;
@synthesize findFriendsButton;
@synthesize logoutButton;
@synthesize saveSettingsButton;
@synthesize nameContentView;
@synthesize usernameContentView;
@synthesize passwordContentView;
@synthesize emailContentView;
@synthesize requestType;
@synthesize recvData;
@synthesize rb_email;
@synthesize rb_name;
@synthesize rb_username;
@synthesize emailsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    
    nameTextField.text = rb_name;
    emailAddressTextField.text = rb_email;
    usernameTextField.text = rb_username;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onNameDeleteButton:(id)sender {
    nameTextField.text = @"";
}

- (IBAction)onUsernameDeleteButton:(id)sender {
    usernameTextField.text = @"";
}

- (IBAction)onPasswordDeleteButton:(id)sender {
    passwordTextField.text = @"";
}

- (IBAction)onEmailDeleteButton:(id)sender {
    emailAddressTextField.text = @"";
}

- (IBAction)onUploadPictureButton:(id)sender {
    
    UploadPictureViewController *uploadPictureViewController = [[UploadPictureViewController alloc] initWithNibName:@"UploadPictureViewController" bundle:nil];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    [navigationController pushViewController:uploadPictureViewController animated:YES];
}

- (IBAction)onDeletePictureButton:(id)sender {
    
    requestType = REQUEST_FOR_DELETEPROFILE;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    [alert show];
}

- (IBAction)onApplicationsButton:(id)sender {
    
    ApplicationViewController *applicationViewController = [[ApplicationViewController alloc] initWithNibName:@"ApplicationViewController" bundle:nil];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    [navigationController pushViewController:applicationViewController animated:YES];
}

- (IBAction)onFindFriendsButton:(id)sender {
    
    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] initWithNibName:@"FindFriendsViewController" bundle:Nil];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    [navigationController pushViewController:findFriendsViewController animated:YES];
    
}

- (IBAction)onDeleteAccountButton:(id)sender {
    
    requestType = REQUEST_FOR_DELETEACCOUNT;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you would like to delete your account permanently?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    [alert show];
    
}

- (IBAction)onLogOutButton:(id)sender {
    
    requestType = REQUEST_FOR_LOGOUT;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (IBAction)onSaveSettingsButton:(id)sender {
    
    if ([nameTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input the name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    if ([usernameTextField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Username mustn't include space, special characters." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    
    if ([emailAddressTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input the Email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
    [self requestSaveProfileSettings];
}

- (IBAction)onEmailsButton:(id)sender {
    EmailsViewController *emailView = [[EmailsViewController alloc] initWithNibName:@"EmailsViewController" bundle:nil];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    [navigationController pushViewController:emailView animated:YES];
}


- (void) setStyle {
    
    [nameTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [usernameTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [passwordTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [emailAddressTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    
    [uploadPictureButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [deletePictureButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [applicationsButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [findFriendsButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [deleteAccountButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [logoutButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [saveSettingsButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [emailsButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    
    nameTextField.delegate = self;
    usernameTextField.delegate = self;
    passwordTextField.delegate = self;
    emailAddressTextField.delegate = self;
    
    
}

#pragma mark - 
#pragma mark UITextField Delegate Functions

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == nameTextField) {
        [usernameTextField becomeFirstResponder];
    }else if (textField == usernameTextField) {
        [passwordTextField becomeFirstResponder];
    }else if (textField == passwordTextField) {
        [emailAddressTextField becomeFirstResponder];
    }else {
        [emailAddressTextField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGPoint localPoint;
    
    if (textField == nameTextField) {
        localPoint = nameContentView.frame.origin;
    }else if (textField == usernameTextField) {
        localPoint = usernameContentView.frame.origin;
    }else if (textField == passwordTextField) {
        localPoint = passwordContentView.frame.origin;
    }else {
        localPoint = emailContentView.frame.origin;
    }
    
    CGPoint basePoint = [self.view convertPoint:localPoint toView:nil];
    
    NSLog(@"%f, %f", localPoint.x, localPoint.y);
    NSLog(@"%f, %f", basePoint.x, basePoint.y);
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (screenSize.height - basePoint.y - 90 < 220) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:basePoint.y + 90] forKey:@"CurrentPosition"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileViewHide" object:nil];
    }
    
    return YES;
}

#pragma mark-
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [alertView cancelButtonIndex]) {
        
        if ([requestType isEqualToString:REQUEST_FOR_DELETEPROFILE]) {
            [self requestDeleteProfile];
        }else if ([requestType isEqualToString:REQUEST_FOR_DELETEACCOUNT]) {
            
            [self requestDeleteAccount];
        }else if ([requestType isEqualToString:REQUEST_FOR_LOGOUT]) {
            
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            
            WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:Nil];
            
            UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
            
            [navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:welcomeViewController animated:YES];
            
        }
        
    }else {
        
        
        if ([requestType isEqualToString:REQUEST_FOR_DELETEACCOUNT_SUCCESS]) {
            
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            
            WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:Nil];
            
            UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
            
            [navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:welcomeViewController animated:YES];
            
        }
    }
}

#pragma mark - 
#pragma mark Request Functions

- (void) requestSaveProfileSettings {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SAVE_PROFILESETTINGS_URL];
    
    NSString *password = passwordTextField.text;
    if (password == Nil) {
        password = @"";
    }
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_NAME, nameTextField.text,
                      TAG_REQ_USERNAME, usernameTextField.text,
                      TAG_REQ_PASSWORD, password,
                      TAG_REQ_EMAIL, emailAddressTextField.text];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[key dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *timestr = [NSString stringWithFormat:@"%f", ti];
    NSString *skv = [AppSharedData base64String:[NSString stringWithFormat:@"%@-%@", timestr, APP_SECRET_KEY]];
    [request addValue:timestr forHTTPHeaderField:hv1];
    [request addValue:skv forHTTPHeaderField:hv2];
    
    // clear data
    self.recvData = [NSMutableData data];
    
    requestType = REQUEST_FOR_SAVEPROFILE;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) requestDeleteProfile {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, DELETE_PROFILEPICTURE_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID]];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[key dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *timestr = [NSString stringWithFormat:@"%f", ti];
    NSString *skv = [AppSharedData base64String:[NSString stringWithFormat:@"%@-%@", timestr, APP_SECRET_KEY]];
    [request addValue:timestr forHTTPHeaderField:hv1];
    [request addValue:skv forHTTPHeaderField:hv2];
    
    // clear data
    self.recvData = [NSMutableData data];
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) requestDeleteAccount {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, DELETE_PROFILEACCOUNT_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID]];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[key dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *timestr = [NSString stringWithFormat:@"%f", ti];
    NSString *skv = [AppSharedData base64String:[NSString stringWithFormat:@"%@-%@", timestr, APP_SECRET_KEY]];
    [request addValue:timestr forHTTPHeaderField:hv1];
    [request addValue:skv forHTTPHeaderField:hv2];
    
    // clear data
    self.recvData = [NSMutableData data];
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    
    
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    
    [self.recvData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%s", __FUNCTION__);
    /// This method is called when the receiving data is finished
    /*    NSString *text = [[[NSString alloc] initWithData:self.recvData encoding:NSUTF8StringEncoding] autorelease];
     self.textView.text = text;*/
    
    NSString *text = [[NSString alloc] initWithData:self.recvData encoding:NSUTF8StringEncoding];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    
    NSDictionary *dict;
    
    dict = (NSDictionary*)[jsonParser objectWithString:text];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:REQUEST_FOR_DELETEPROFILE]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteProfilePicture" object:Nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Picture deleted successfully." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [alert show];
        }else if ([requestType isEqualToString:REQUEST_FOR_DELETEACCOUNT]) {
            
            requestType = REQUEST_FOR_DELETEACCOUNT_SUCCESS;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Account deleted successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [alert show];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Profile updated successfully." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        if ([errorMsg isEqualToString:@""]) {
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [emailAddressTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [nameTextField resignFirstResponder];
    [usernameTextField resignFirstResponder];
}

@end
