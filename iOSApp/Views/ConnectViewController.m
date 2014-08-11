//
//  ConnectViewController.m
//  BalloonRed
//
//  Created by Mr. RI on 3/7/14.
//  Copyright (c) 2014 Mr. RI. All rights reserved.
//

#import "ConnectViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "SBJson.h"
#import "AppSharedData.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <Twitter/TWRequest.h>
#import <Accounts/Accounts.h>
#import "TWAPIManager.h"
#import "TWSignedRequest.h"

#define REQUEST_FACEBOOK_REGISTER               @"facebook"
#define REQUEST_TWITTER_REGISTER                @"twitter"


#define ERROR_TITLE_MSG @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings.app to use Twitter Login."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK @"OK"

@interface ConnectViewController () {
    
    ACAccount *twitterAccount;
    
}

@property (atomic, strong) ACAccount *twitterAccount;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation ConnectViewController

@synthesize navTitleLabel;
@synthesize menuButton;
@synthesize menu;
@synthesize requestType;
@synthesize recvData;
@synthesize viewLoading;
@synthesize activityView;

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
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
    [self refreshTwitterAccounts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onBackButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)onMenuButton:(id)sender {
    
    if (menu.isOpen)
        return [menu close];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    [menu showFromRect:CGRectMake(0, 45, screenSize.width, screenSize.height - 45) inView:self.view];
    
}

- (IBAction)onCFBButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    [self clearCookies];
    
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [appDelegate sessionStateChanged:session state:state error:error];
         
         [self request_Facebook_Login];
     }];
    
}

- (IBAction)onCTWButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
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

#pragma mark - 
#pragma mark Set Style of View Function

- (void) setStyle {
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:22.f]];
    
    //add Activity Indicator View
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 100;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
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
    
    // clear data
    self.recvData = [NSMutableData data];
    
    //set Request Type
    requestType = REQUEST_FACEBOOK_REGISTER;
    
    
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
    
    // clear data
    self.recvData = [NSMutableData data];
    
    //set Request Type
    requestType = REQUEST_TWITTER_REGISTER;
    
    
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
    
    NSDictionary *dict = [[NSDictionary alloc] init];
    
    dict = (NSDictionary*)[jsonParser objectWithString:text ];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        NSString *userid = [dict objectForKey:TAG_RES_USERID];
//        [[UserController instance] setUserUserID:userid];
//        
//        HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:Nil];
//        
//        [self.navigationController pushViewController:homeViewController animated:YES];
        
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





@end
