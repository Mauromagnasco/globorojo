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

#import "ApplicationViewController.h"
#import "Constants.h"
#import "SBJson.h"
#import "UserController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Twitter/TWRequest.h>
#import "TWAPIManager.h"
#import "TWSignedRequest.h"
#import "OAuth+Additions.h"
#import "AppSharedData.h"
#import "SearchViewController.h"

#define REQUEST_FOR_NOTIFICATION            @"requestNotification"
#define REQUEST_FOR_DISCONNECT              @"disconnect"
#define REQUEST_FACEBOOK_REGIST             @"facebook"
#define REQUEST_TWITTER_REGIST              @"twitter"
#define REQUEST_FOR_CHECKCONNECT            @"checkconnect"
#define ERROR_TITLE_MSG                     @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS                   @"You must add a Twitter account in Settings.app to use Twitter Login."
#define ERROR_PERM_ACCESS                   @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS                       @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK                            @"OK"

@interface ApplicationViewController () {
    ACAccount *twitterAccount;
}

@property (atomic, strong) ACAccount *twitterAccount;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation ApplicationViewController

@synthesize navTitleLabel;
@synthesize menuButton;
@synthesize connectFBButton;
@synthesize connectTWButton;
@synthesize viewLoading;
@synthesize requestType;
@synthesize recvData;
@synthesize activityView;
@synthesize menu;
@synthesize connectFacebook;
@synthesize connectTwitter;
@synthesize contentView;
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
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Application" forKey:@"lastView"];
    
    [self refreshTwitterAccounts];
    
    [self requestCheckConnect];
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                     
                     NSLog(@"%@", FBSession.activeSession.accessTokenData.accessToken);
                     
                     [[AppSharedData sharedInstance] setFacebookInfo:user];
                     
                     [self request_Facebook_Regist];
                     
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
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *aController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    if ([aController isKindOfClass:[SearchViewController class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"returnSearch"];
    }
    
    if (menu.isOpen) [menu close];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)onMenuButton:(id)sender {
    
    if (menu.isOpen)
        return [menu close];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [menu showFromRect:CGRectMake(0, 65, screenSize.width, screenSize.height - 45) inView:self.view];
    }else {
        [menu showFromRect:CGRectMake(0, 45, screenSize.width, screenSize.height - 45) inView:self.view];
    }
    
}

- (IBAction)onConnectFBButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    if ([connectFacebook isEqualToString:@"N"]) {
        [self clearCookies];
        
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             [self sessionStateChanged:session state:state error:error];
        }];
    }else {
        [self requestDisconnectSocial:1];
    }

}

- (IBAction)onConnectTWButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    
    if ([connectTwitter isEqualToString:@"N"]) {
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
    }else {
        [self requestDisconnectSocial:2];
    }
}


#pragma mark -
#pragma mark Set Style Funciton

- (void) setStyle {
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [connectTWButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:19.0]];
    [connectFBButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:19.0]];
    
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
#pragma mark Request Funcitons
- (void) requestCheckNotification {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, CHECK_NOTIFICATION_URL];
    
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
    
    //set Request Type;
    requestType = REQUEST_FOR_NOTIFICATION;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    
}

- (void) requestDisconnectSocial: (int) snsType {
    
    [self startLoading];

    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, DISCONNECT_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_SNSTYPE, [NSString stringWithFormat:@"%d", snsType]];
    
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
    
    //set Request Type;
    requestType = REQUEST_FOR_DISCONNECT;
    
    socialType = snsType;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) request_Facebook_Regist {
    
    NSDictionary *data = [[AppSharedData sharedInstance] facebookInfo];
    
    if (data == Nil) {
        return;
    }
    
    NSString *snsId = [data objectForKey:@"id"];
//    NSString *username = [data objectForKey:@"username"];
    NSString *name = [data objectForKey:@"name"];
    NSString *email = [data objectForKey:@"email"];
    NSString *token = [[AppSharedData sharedInstance] facebookToken];
    
    
    [self startLoading];
    
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, FACEBOOK_CONNECT_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_SNSID, snsId,
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
    requestType = REQUEST_FACEBOOK_REGIST;
    
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) request_Twitter_Regist{
    
    NSString *snsId = param2;
    NSString *username = param3;
    NSString *photo = param5;
    NSString *token1 = param1;
    NSString *token2 = param4;
    
    if (username == Nil) {
        username = @"";
    }
    
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, TWITTER_CONNECT_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_SNSID, snsId,
                      TAG_REQ_NAME, username,
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
    requestType = REQUEST_TWITTER_REGIST;
    
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestCheckConnect {
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_SOCIALINFO_URL];
    
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
    
    //set Request Type;
    requestType = REQUEST_FOR_CHECKCONNECT;
    
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
    
    dict = (NSDictionary*)[jsonParser objectWithString:text];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:REQUEST_FOR_NOTIFICATION]){
            
            NSString *checkFlag = [dict objectForKey:TAG_RES_ISNEWNOTIFICATION];
            
            if ([checkFlag isEqualToString:@"Y"]) {
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
            }else {
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
            }
        }else if ([requestType isEqualToString:REQUEST_FOR_CHECKCONNECT]) {
            
            connectFacebook = [dict objectForKey:TAG_RES_CONNECTFACEBOOK];
            connectTwitter = [dict objectForKey:TAG_RES_CONNECTTWITTER];
            
            [self resetButtonTitle];
            [self requestCheckNotification];
        }else if ([requestType isEqualToString:REQUEST_FOR_DISCONNECT]){
            
            if (socialType == 1) {
                connectFacebook = @"N";
            }else {
                connectTwitter = @"N";
            }
            
            [self resetButtonTitle];
            
        }else {
            
            if ([requestType isEqualToString:REQUEST_FACEBOOK_REGIST]) {
                connectFacebook = @"Y";
            }else {
                connectTwitter = @"Y";
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Connection success." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
            
            [self resetButtonTitle];
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
    
    [self endLoading];
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

#pragma mark -
#pragma mark Clear Cookies Function

- (void) clearCookies {
    [[AppSharedData sharedInstance] setFacebookInfo:Nil];
    [FBSession.activeSession closeAndClearTokenInformation];
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in
         [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookies deleteCookie:cookie];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        twitterAccount = _accounts[buttonIndex];
        
        if (twitterAccount == Nil) {
            return;
        }
        
        [self startLoading];
        
        [_apiManager performReverseAuthForAccount:_accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData) {
                
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                
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
                
                if(twitterAccount) {
                    SLRequest *twitterInfoRequest =  [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:param3 forKey:@"screen_name"]];
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
                                
                                
                                [self request_Twitter_Regist];
                            }
                        });
                    }];
                }
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

#pragma mark -
#pragma mark Reset Button Title

- (void) resetButtonTitle {
    
    if ([connectFacebook isEqualToString:@"Y"]) {
        [connectFBButton setTitle:@"DISCONNECT FACEBOOK" forState:UIControlStateNormal];
        [connectFBButton setTitle:@"DISCONNECT FACEBOOK" forState:UIControlStateSelected];
    }else {
        [connectFBButton setTitle:@"CONNECT FACEBOOK" forState:UIControlStateNormal];
        [connectFBButton setTitle:@"CONNECT FACEBOOK" forState:UIControlStateSelected];
    }
    
    if ([connectTwitter isEqualToString:@"Y"]) {
        [connectTWButton setTitle:@"DISCONNECT TWITTER" forState:UIControlStateNormal];
        [connectTWButton setTitle:@"DISCONNECT TWITTER" forState:UIControlStateSelected];
    }else {
        [connectTWButton setTitle:@"CONNECT TWITTER" forState:UIControlStateNormal];
        [connectTWButton setTitle:@"CONNECT TWITTER" forState:UIControlStateSelected];
    }
}

-(void)viewWillLayoutSubviews{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.view.clipsToBounds = YES;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        CGFloat screenHeight = screenRect.size.height;
        self.mainContentView.frame =  CGRectMake(0, 20, self.mainContentView.frame.size.width,screenHeight-20);
        [self.contentView setFrame:CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, 320, 503)];
        
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
    }else {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        mainContentView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 20);
    }
}



@end
