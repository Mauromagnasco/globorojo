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

#import "LoginViewController.h"
#import "Constants.h"
#import "NSString+Validations.h"
#import "SBJson.h"
#import "UserController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "HomeViewController.h"
#import "SearchViewController.h"
#import "AppSharedData.h"
#import "AppDelegate.h"
#import "ForgotPasswordViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TWAPIManager.h"
#import "TWSignedRequest.h"
#import "OAuth+Additions.h"
#import <Twitter/TWRequest.h>

#define REQUEST_FACEBOOK_LOGIN         @"facebook"
#define REQUEST_TWITTER_LOGIN          @"twitter"
#define ERROR_TITLE_MSG @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings.app to use Twitter Login."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK @"OK"
#define REQUEST_SET_DEVTOKEN           @"devToken"


@interface LoginViewController () {
    ACAccount *twitterAccount;
}

@property (atomic, strong) ACAccount *twitterAccount;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation LoginViewController

@synthesize navTitleLabel;
@synthesize descriptionLabel;
@synthesize emailAddressTextField;
@synthesize passwordTextField;
@synthesize forgotPasswordButton;
@synthesize scrollView;

@synthesize activityView;
@synthesize recvData;
@synthesize viewLoading;
@synthesize requestType;
@synthesize mainContentView;

@synthesize twitterAccount = _twitterAccount;

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
    [self refreshTwitterAccounts];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setStyle {
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:22.f]];
    [descriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:18.f]];
    [emailAddressTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.f]];
    [passwordTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.f]];
    [forgotPasswordButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:13.f]];
    
    emailAddressTextField.delegate = self;
    passwordTextField.delegate = self;
    
    //add Activity Indicator View
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 100;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
    
    _accountStore = [[ACAccountStore alloc] init];
    _apiManager = [[TWAPIManager alloc] init];
}


- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
    
    NSLog(@"%@", [[session accessTokenData] accessToken]);
    
    NSString *accessToken = [[session accessTokenData] accessToken];
    [[AppSharedData sharedInstance] setFacebookToken:accessToken];
    
    switch (state) {
        case FBSessionStateOpen: {
            //Save the used SocialAccountType so it can be retrieved the next time the app is started.
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     
                     NSLog(@"%@",user);
                     
                     [[AppSharedData sharedInstance] setFacebookInfo:user];
                     
                     [self request_Facebook_Login];
                     
                 }}];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged out, we want them to be looking at the root view.
            //            [self.navigationController popToRootViewControllerAnimated:YES];
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Facebook Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)onBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onFBLoginButton:(id)sender {
    
    [self clearCookies];
    
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (IBAction)onTWLoginButton:(id)sender {
    
    NSString *title = @"Choose an Account";
    if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        title = ERROR_NO_ACCOUNTS;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (ACAccount *acct in _accounts) {
        [sheet addButtonWithTitle:acct.username];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:self.view];
}

- (IBAction)onEmailAddressDeleteButton:(id)sender {
    emailAddressTextField.text = @"";
}

- (IBAction)onPasswordDeleteButton:(id)sender {
    passwordTextField.text = @"";
}

- (IBAction)onConfirmButton:(id)sender {
    
//    if (![emailAddressTextField.text isValidEmail]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"The email address is invalid." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
//        [alert show];
//        return;
//    }
    
    if ([emailAddressTextField.text isEqualToString:@""]) {
        return;
    }
    
    [self request_userInfo];
}

- (IBAction)onForgotPasswordButton:(id)sender {
    
    ForgotPasswordViewController *forgotPasswordViewController = [[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordViewController" bundle:nil];
    
    [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
}


#pragma mark - Textfield Delegate Functions
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == passwordTextField) {
        isEditing = FALSE;
    }
    
    [emailAddressTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height <= 480) {
        if (textField == passwordTextField) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 138) animated:YES];
        }
    }else {
        if (textField == passwordTextField) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 50) animated:YES];
        }
    }
    if (textField == emailAddressTextField) {
        [passwordTextField becomeFirstResponder];
    }else if (textField == passwordTextField) {
        [self onConfirmButton:nil];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (isEditing) {
        return YES;
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height <= 480) {
        if (textField == emailAddressTextField) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 88) animated:YES];
        }
        if (textField == passwordTextField) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 138) animated:YES];
        }
    }else {
        if (textField == passwordTextField) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 50) animated:YES];
        }
    }
    
    if (textField == passwordTextField) {
        isEditing = YES;
    }
    return YES;
}

#pragma mark - Touch Event Funtions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [emailAddressTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    [activityView startAnimation];
    viewLoading.hidden = NO;
}

- (void)endLoading{
    viewLoading.hidden = YES;
    [activityView stopAnimation];
}

#pragma mark -
#pragma mark NSURLConnection Part ASynchronous Method

- (void) request_Facebook_Login {
    
    NSDictionary *data = [[AppSharedData sharedInstance] facebookInfo];
    
    NSString *snsId = [data objectForKey:@"id"];

    [self startLoading];
    
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, LOGIN_SOCIAL_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@",
                      TAG_REQ_SNSID, snsId,
                      TAG_REQ_SNSTYPE, [NSNumber numberWithInt:1]];
    
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
    
    //set Request Type
    requestType = REQUEST_FACEBOOK_LOGIN;
    
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) request_Twitter_Login: (NSString *)snsId {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, LOGIN_SOCIAL_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@",
                      TAG_REQ_SNSID, snsId,
                      TAG_REQ_SNSTYPE, [NSNumber numberWithInt:2]];
    
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
    
    //set Request Type
    requestType = REQUEST_TWITTER_LOGIN;
    
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) request_userInfo {
    [self startLoading];
    
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, LOGIN_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@", TAG_REQ_EMAIL, emailAddressTextField.text, TAG_REQ_PASSWORD, passwordTextField.text];
    
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

- (void) request_setDevToken {
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SET_DEV_TOKEN_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@", TAG_REQ_USERID, [[UserController instance] userUserID], TAG_REQ_DEVTOKEN, [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]];
    
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
    
    requestType = REQUEST_SET_DEVTOKEN;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [self endLoading];
    
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
    
    dict = (NSDictionary*)[jsonParser objectWithString:text ];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:REQUEST_SET_DEVTOKEN]) {
            
        }else {
            NSString *userid = [dict objectForKey:TAG_RES_USERID];
            [[UserController instance] setUserUserID:userid];
        
//            HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:Nil];
//        
//            [self.navigationController pushViewController:homeViewController animated:YES];
            
            SearchViewController *searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
            
            [self.navigationController pushViewController:searchView animated:YES];
            
            [self request_setDevToken];
        }
        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        if (![errorMsg isEqualToString:@""] && errorMsg != Nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    [self endLoading];
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

#pragma mark -
#pragma mark Clear Cookies Function

- (void) clearCookies {
    [FBSession.activeSession closeAndClearTokenInformation];
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in
         [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookies deleteCookie:cookie];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        twitterAccount = _accounts[buttonIndex];
        
        [self startLoading];
        
        [_apiManager performReverseAuthForAccount:_accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData) {
                
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                //                TWDLog(@"Reverse Auth process returned: %@", responseStr);
                
                NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                /*
                 dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:lined delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
                 });*/
                
                NSString *snsId = [[NSString alloc] init];
                for (int i = 0; i < [parts count]; i++) {
                    NSArray *subParts = [[parts objectAtIndex:i] componentsSeparatedByString:@"="];

                    if ([[subParts objectAtIndex:0] isEqual:@"user_id"]) {
                        snsId = [NSString stringWithString:[subParts objectAtIndex:1]];
                    }
                }
                
                [self request_Twitter_Login:snsId];
            }
        }];
    }
}

#pragma mark - Private
/**
 *  Checks for the current Twitter configuration on the device / simulator.
 *
 *  First, we check to make sure that we've got keys to work with inside Info.plist (see README)
 *
 *  Then we check to see if the device has accounts available via +[TWAPIManager isLocalTwitterAccountAvailable].
 *
 *  Next, we ask the user for permission to access his/her accounts.
 *
 *  Upon completion, the button to continue will be displayed, or the user will be presented with a status message.
 */
- (void)refreshTwitterAccounts
{
    //    TWDLog(@"Refreshing Twitter Accounts \n");
    
    if (![TWAPIManager hasAppKeys]) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_KEYS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        //        [alert show];
    }
    else if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_ACCOUNTS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        //        [alert show];
    }
    else {
        [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_PERM_ACCESS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
                    [alert show];
                    //                    TWALog(@"You were not granted access to the Twitter accounts.");
                }
            });
        }];
    }
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    
    //  This method changed in iOS6. If the new version isn't available, fall back to the original (which means that we're running on iOS5+).
    if ([_accountStore respondsToSelector:@selector(requestAccessToAccountsWithType:options:completion:)]) {
        [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
    }
    else {
        [_accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:handler];
    }
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}


-(void)viewWillLayoutSubviews{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.view.clipsToBounds = YES;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        CGFloat screenHeight = screenRect.size.height;
        self.mainContentView.frame =  CGRectMake(0, 20, self.mainContentView.frame.size.width,screenHeight-20);
        
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
    }else {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        mainContentView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 20);
    }
}



@end
