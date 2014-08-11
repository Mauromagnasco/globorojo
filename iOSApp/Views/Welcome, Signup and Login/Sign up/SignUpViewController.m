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

#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "AppSharedData.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "Constants.h"
#import "SBJson.h"
#import "NSString+Validations.h"
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"
#import "UserController.h"
#import "HomeViewController.h"
#import <Twitter/TWRequest.h>
#import "SignUpRegistrationViewController.h"
#import "SearchViewController.h"



#define REQUEST_FACEBOOK_SIGNUP         @"facebook"
#define REQUEST_TWITTER_SIGNUP          @"twitter"
#define REQUEST_SUBMIT_SIGNUP           @"submit"
#define kTwitterAPIRootURL              @"https://api.twitter.com/1.1/"

#define ERROR_TITLE_MSG @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings.app to use Twitter Login."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK @"OK"

@interface SignUpViewController (){
    ACAccount *twitterAccount;
}

@property (nonatomic) SocialAccountType socialAccountType;
@property (atomic, strong) ACAccount *twitterAccount;
@property (atomic, strong) NSString *username;
@property (atomic, strong) NSString *name;

@property (atomic) BOOL userDataLoaded;
@property (atomic) BOOL timelineDataLoaded;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation SignUpViewController

@synthesize navTitleLabel;
@synthesize descriptionLabel;
@synthesize userNameTextField;
@synthesize emailAddressTextField;
@synthesize passwordTextField;
@synthesize scrollView;
@synthesize viewLoading;

@synthesize recvData;
@synthesize activityView;
@synthesize requestType;

@synthesize socialAccountType = _socialAccountType;
@synthesize twitterAccount = _twitterAccount;
@synthesize username = _username;
@synthesize name = _name;
@synthesize userDataLoaded = _userDataLoaded;
@synthesize timelineDataLoaded = _timelineDataLoaded;
@synthesize mainContentView;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserData:) name:@"nRetrieveTwitterData" object:nil];
    
    [self setStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    
    changeContentOffset = NO;
    [scrollView setContentSize:CGSizeMake(320, 568)];

    [self refreshTwitterAccounts];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Set Style Functions
- (void) setStyle {
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:22.f]];
    [descriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:18.f]];
    [emailAddressTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.f]];
    [passwordTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.f]];
    [userNameTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.f]];
    

    userNameTextField.delegate = self;
    passwordTextField.delegate = self;
    emailAddressTextField.delegate = self;
    
    //add Activity Indicator View
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 100;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
    
    _accountStore = [[ACAccountStore alloc] init];
    _apiManager = [[TWAPIManager alloc] init];
    
}



#pragma mark -
#pragma mark IBAction Functions

- (IBAction)onFBSignUpButton:(id)sender {
    
    [self closeFacebookSession];
    
    NSArray *facebookPermissions = [NSArray arrayWithObjects:@"user_about_me", @"user_status", @"email", @"publish_stream", @"share_item", nil];
    /* [FBSession sessionOpenWithPermissions:facebookPermissions completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
     [self sessionStateChanged:session state:state error:error];
     }];
     */
    [FBSession openActiveSessionWithPermissions:facebookPermissions allowLoginUI:YES completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)closeFacebookSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            //Save the used SocialAccountType so it can be retrieved the next time the app is started.
            [[NSUserDefaults standardUserDefaults]  setInteger:SocialAccountTypeFacebook forKey:kSocialAccountTypeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //Go to the HomeViewController
            //            HomeViewController *homeViewController = [[HomeViewController alloc] initWithSocialAccountType:SocialAccountTypeFacebook];
            //            [self.navigationController pushViewController:homeViewController animated:YES];
            self.socialAccountType = SocialAccountTypeFacebook;
            [self refreshUserData:nil];
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


- (IBAction)onTWSignUpButton:(id)sender {
    
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

- (IBAction)onConfirmButton:(id)sender {
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    if ([userNameTextField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Username mustn't include space, special characters." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    

    
    if (![emailAddressTextField.text isValidEmail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"The email address is invalid." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    
    [self request_Submit];
}

- (IBAction)onBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)refreshUserData:(id)sender {
    //[SVProgressHUD showWithStatus:@"Loading..."];
    self.userDataLoaded = NO;
    self.timelineDataLoaded = NO;
    [self loadUserDetails];
}

#pragma mark Account Data
- (void)loadUserDetails {
    //If the user is logged in using Twitter
    if(self.socialAccountType == SocialAccountTypeTwitter) {
        //Get a reference to the application delegate.
        
        if ([param5 isEqual:@"--"]) {
            [self performSelector:@selector(loadUserDetails) withObject:nil afterDelay:0.1f];
        }else{
            [[NSUserDefaults standardUserDefaults] setInteger:SocialAccountTypeTwitter forKey:kSocialAccountTypeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
        
        
    } else if(self.socialAccountType == SocialAccountTypeFacebook){
        //If the user is logged in using Facebook
        
        //Check whether the current Facebook session is open.
        if([FBSession.activeSession isOpen]) {
            //Request the users information.
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     
                     [[AppSharedData sharedInstance] setFacebookInfo:user];
                     
                     [self request_Facebook_SignUp];
                     
                 } else {
                     [self displayErrorMessage];
                 }
                 self.userDataLoaded = YES;
             }];
            
            /*
             //Request the users wall feed.
             [[FBRequest requestForGraphPath:@"me/feed"] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
             NSDictionary *data,
             NSError *error) {
             if (!error) {
             //Get the last wall message of the user.
             self.status = [[[data objectForKey:@"data"] objectAtIndex:0] objectForKey:@"message"];
             } else {
             [self displayErrorMessage];
             }
             //Store the loaded data in the properties
             self.timelineDataLoaded = YES;
             }];
             */
        }
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
                
                for (int i = 0; i < [parts count]; i++) {
                    NSArray *subParts = [[parts objectAtIndex:i] componentsSeparatedByString:@"="];
                    if ([[subParts objectAtIndex:0] isEqual:@"oauth_token"]) {
                        param1 = [NSString stringWithString:[subParts objectAtIndex:1]];
                    }
                    if ([[subParts objectAtIndex:0] isEqual:@"oauth_token_secret"]) {
                        param4 = [NSString stringWithString:[subParts objectAtIndex:1]];
                        //param5 = [NSString stringWithString:[subParts objectAtIndex:1]];
                    }
                    if ([[subParts objectAtIndex:0] isEqual:@"user_id"]) {
                        param2 = [NSString stringWithString:[subParts objectAtIndex:1]];
                    }
                    if ([[subParts objectAtIndex:0] isEqual:@"screen_name"]) {
                        param3 = [NSString stringWithString:[subParts objectAtIndex:1]];
                    }
                }
                param5 = @"--";
                
                if (param3 == Nil) {
                    param3 = @"";
                }
                
                self.socialAccountType = SocialAccountTypeTwitter;
                //[self refreshUserData:nil];
                
                if(twitterAccount) {
                    
                    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:param3 forKey:@"screen_name"]];
                    [twitterInfoRequest setAccount:twitterAccount];
                    
                    // Making the request
                    
                    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // Check if we reached the reate limit
                            
                            if ([urlResponse statusCode] == 429) {
                                NSLog(@"Rate limit reached");
                                return;
                            }
                            
                            // Check if there was an error
                            
                            if (error) {
                                NSLog(@"Error: %@", error.localizedDescription);
                                return;
                            }
                            
                            // Check if there is some response data
                            
                            if (responseData) {
                                
                                NSError *error = nil;
                                NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                                
                                
                                // Filter the preferred data
                                
                                NSString *profileImageStringURL = [(NSDictionary *)TWData objectForKey:@"profile_image_url_https"];
//                                NSString *bannerImageStringURL =[(NSDictionary *)TWData objectForKey:@"profile_banner_url"];
                                
                                
                                
                                // Get the profile image in the original resolution
                                
                                profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                                
                                param5 = profileImageStringURL;
                                param6 = @"";
                                param7 = @"";
                                
                                [self request_Twitter_SignUp];
                            }
                        });
                    }];
                    
                }
                
                
                
                //param setting
                /*      param1 = @"oauth token";
                 param2 = [response objectForKey:@"id"];
                 param3 = [response objectForKey:@"name"];
                 param4 = @"token secret";
                 param5 = @"token secret";
                 param6 = [response objectForKey:@"profile_image_url"];*/
                param7 = @"";
            }
            else {
                //                TWALog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
            }
        }];
    }
}





#pragma mark -
#pragma mark Request Functions

- (void) request_Facebook_SignUp {
    
    NSDictionary *data = [[AppSharedData sharedInstance] facebookInfo];

    NSString *snsId = [data objectForKey:@"id"];
    NSString *username = [data objectForKey:@"username"];
    if (username == Nil) {
        username = @"";
    }
    NSString *name = [data objectForKey:@"name"];
    NSString *email = [data objectForKey:@"email"];
    NSString *token = [data objectForKey:@"token"];
    
    if (username == Nil) {
        username = @"";
    }
    
    [self startLoading];
    
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SIGNUP_FACEBOOK_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                      TAG_REQ_SNSID, snsId,
                      TAG_REQ_USERNAME, username,
                      TAG_REQ_NAME, name,
                      TAG_REQ_EMAIL, email,
                      TAG_REQ_TOKEN, token];
    
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
    requestType = REQUEST_FACEBOOK_SIGNUP;
    
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) request_Twitter_SignUp {
    
    NSString *snsId = param2;
    NSString *username = param3;
    NSString *photo = param5;
    NSString *token1 = param1;
    NSString *token2 = param4;
    
    if (username == Nil) {
        username = @"";
    }
    
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SIGNUP_TWITTER_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                      TAG_REQ_SNSID, snsId,
                      TAG_REQ_USERNAME, username,
                      TAG_REQ_PHOTO, photo,
                      TAG_REQ_TOKEN1, token1,
                      TAG_REQ_TOKEN2, token2];
    
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
    requestType = REQUEST_TWITTER_SIGNUP;
    
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) request_Submit {

    [self startLoading];
    
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SIGNUP_SUBMIT_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",
                      TAG_REQ_USERNAME, userNameTextField.text,
                      TAG_REQ_EMAIL, emailAddressTextField.text,
                      TAG_REQ_PASSWORD, passwordTextField.text];
    
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
    requestType = REQUEST_SUBMIT_SIGNUP;
    
    
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
        if ([requestType isEqualToString:REQUEST_FACEBOOK_SIGNUP] || [requestType isEqualToString:REQUEST_SUBMIT_SIGNUP]) {
            NSString *userid = [NSString stringWithFormat:@"%@", [dict objectForKey:TAG_RES_USERID]];
            [[UserController instance] setUserUserID:userid];
            
//            HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:Nil];
//            
//            [self.navigationController pushViewController:homeViewController animated:YES];
            
            SearchViewController *searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
            
            [self.navigationController pushViewController:searchView  animated:YES];
            
        }else if ([requestType isEqualToString:REQUEST_TWITTER_SIGNUP]){
        
            NSString *userSnsId = [dict objectForKey:TAG_RES_USERSNSID];
            NSString *username = [dict objectForKey:TAG_RES_USERNAME];
            NSString *photo = [dict objectForKey:TAG_RES_PHOTO];
            
            SignUpRegistrationViewController *signUpRegistrationViewController = [[SignUpRegistrationViewController alloc] initWithNibName:@"SignUpRegistrationViewController" bundle:Nil];
            
            [signUpRegistrationViewController setName:username];
            [signUpRegistrationViewController setUserSnsId:userSnsId];
            [signUpRegistrationViewController setPhotoUrl:photo];
            
            [self.navigationController pushViewController:signUpRegistrationViewController animated:YES];
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
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    [activityView startAnimation];
    viewLoading.hidden = NO;
}

- (void)endLoading{
    viewLoading.hidden = YES;
    [activityView stopAnimation];
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

- (void)displayErrorMessage {
    NSString *socialNetworkName = nil;
    switch (self.socialAccountType) {
        case SocialAccountTypeTwitter:
            socialNetworkName = @"Twitter";
            break;
        case SocialAccountTypeFacebook:
            socialNetworkName = @"Facebook";
            break;
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ error", socialNetworkName]
                                                    message:[NSString stringWithFormat:@"There was an error talking to %@. Please try again later.", socialNetworkName]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark -
#pragma mark UITextField Resign First Responder Functions

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [userNameTextField resignFirstResponder];
    [emailAddressTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (textField == userNameTextField) {
        [emailAddressTextField becomeFirstResponder];
    }else if (textField == emailAddressTextField) {
        [passwordTextField becomeFirstResponder];
    }else {
        if (changeContentOffset) {
            if (screenSize.height > 480) {
                [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 100) animated:YES];
            }else {
                [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 150) animated:YES];
            }
            changeContentOffset = NO;
        }
        [passwordTextField resignFirstResponder];
        [self onConfirmButton:Nil];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [userNameTextField resignFirstResponder];
    [emailAddressTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (changeContentOffset) {
        if (screenSize.height > 480) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 100) animated:YES];
        }else {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 150) animated:YES];
        }
        changeContentOffset = NO;
    }
}

#pragma mark - 
#pragma mark UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (!changeContentOffset) {
        if (screenSize.height > 480) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 100) animated:YES];
        }else {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 150) animated:YES];
        }
        changeContentOffset = YES;
    }
    
    return YES;
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
