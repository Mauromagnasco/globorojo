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

#import "FindFriendsViewController.h"
#import "Constants.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import "AppSharedData.h"
#import "UserController.h"
#import "ApplicationViewController.h"
#import "FriendItemViewController.h"
#import "ProfileViewController.h"

#define REQUEST_FOR_FACEBOOK                @"facebook"
#define REQUEST_FOR_TWITTER                 @"twitter"
#define REQUEST_FOR_NOTIFICATION            @"notification"
#define REQUEST_FOR_CHECKCONNECT            @"checkconnect"
#define REQUEST_USERID                      @"userid"

@interface FindFriendsViewController ()

@end

@implementation FindFriendsViewController

@synthesize recvData;
@synthesize requestType;
@synthesize activityView;
@synthesize menu;
@synthesize navTitlelabel;
@synthesize menuButton;
@synthesize segmentContainerView;
@synthesize applicationButton;
@synthesize descriptionLabel;
@synthesize viewLoading;
@synthesize segmentedControl;
@synthesize scrollView;
@synthesize connectFacebook;
@synthesize connectTwitter;
@synthesize friendsItemArray;
@synthesize contentView;
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
    
    [self setStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"FindFriend" forKey:@"currentView"];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(requestFriendUserId:) name:IFNotiLabelFindUserNotification object:Nil];
    
    friendsItemArray = [[NSMutableArray alloc] init];
    
    [self requestCheckNotification];
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
    contentView.hidden = YES;
    scrollView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)onApplicationButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    ApplicationViewController *applicationViewController = [[ApplicationViewController alloc] initWithNibName:@"ApplicationViewController" bundle:nil];
    
    [self.navigationController pushViewController:applicationViewController animated:YES];
    
}

#pragma mark -
#pragma mark Set Style Funciton

- (void) setStyle {
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0,0, 320, 35)];
    [self.segmentedControl setSectionTitles:@[@"Facebook", @"Twitter"]];
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1]];
    [self.segmentedControl setTextColor:[UIColor whiteColor]];
    [self.segmentedControl setSelectedTextColor:[UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1]];
    [self.segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1]];
    [self.segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [self.segmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationUp];
    [self.segmentedControl setTag:3];
    [segmentContainerView addSubview:segmentedControl];
    
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
        [self doingNextStep:index];
        
    }];
    
    [navTitlelabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [applicationButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [descriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
    
    //add Activity Indicator View
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 100;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
}

#pragma mark - 
#pragma mark Doing Next Step --- for reqest find facebook friends and twitter friends

- (void) doingNextStep: (int) workType {
    
    switch (workType) {
        case 0:
            if ([connectFacebook isEqualToString:@"Y"]) {
                
                contentView.hidden = YES;
                scrollView.hidden = NO;
                [self requestFacebookFriends];
                
            }else {
                [self endLoading];
                [scrollView setHidden:YES];
                contentView.hidden = NO;
                applicationButton.hidden = NO;
                descriptionLabel.text = @"Facebook is not connected.";
            }
            break;
            
        case 1:
            
            if ([connectTwitter isEqualToString:@"Y"]) {
                contentView.hidden = YES;
                scrollView.hidden = NO;
                [self requestTwitterFriends];
            }else {
                [self endLoading];
                [scrollView setHidden:YES];
                contentView.hidden = NO;
                applicationButton.hidden = NO;
                descriptionLabel.text = @"Twitter is not connected.";
            }
            
        default:
            break;
    }
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


- (void) requestFriendUserId: (NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFNotiLabelFindUserNotification object:Nil];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_USERID_FROMUSERNAME_URL];
    
    NSString *username = [[[NSUserDefaults standardUserDefaults] objectForKey:IFNotiLabelButtonTitle] substringFromIndex:1];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_USERNAME, username];
    
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
    
    requestType = REQUEST_USERID;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) requestFacebookFriends {
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, FACEBOOK_FRIENDS_URL];
    
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
    requestType = REQUEST_FOR_FACEBOOK;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestTwitterFriends {
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, TWITTER_FRIENDS_URL];
    
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
    requestType = REQUEST_FOR_TWITTER;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestCheckNotification {
    
    [self startLoading];
    
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

- (void) requestCheckConnect {

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
    if ([requestType isEqualToString:REQUEST_FOR_NOTIFICATION] || [requestType isEqualToString:REQUEST_FOR_CHECKCONNECT]) {
        
        return;
        
    }
    
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
            
            [self requestCheckConnect];
            
        }else if ([requestType isEqualToString:REQUEST_FOR_CHECKCONNECT]) {
            
            connectFacebook = [dict objectForKey:TAG_RES_CONNECTFACEBOOK];
            connectTwitter = [dict objectForKey:TAG_RES_CONNECTTWITTER];
            
            [self doingNextStep:0];
        }else if ([requestType isEqualToString:REQUEST_FOR_FACEBOOK] ||
                  [requestType isEqualToString:REQUEST_FOR_TWITTER]) {
            
            friendsItemArray = [NSMutableArray array];
            [self clearScrollView];
            
            NSMutableArray *userListArray = [dict objectForKey:TAG_RES_USERLIST];
            
            for (int i = 0; i < [userListArray count]; i++) {
                
                NSDictionary *dict1 = [userListArray objectAtIndex:i];
                
                FriendItemViewController *fiVC = [[FriendItemViewController alloc] initWithNibName:@"FriendItemViewController" bundle:Nil];
                
                [fiVC setData:dict1];
                [fiVC setNumber:i];
                fiVC.view.frame = CGRectMake(0, startY, fiVC.view.frame.size.width, fiVC.view.frame.size.height);
                
                [friendsItemArray addObject:fiVC];
                
                FriendItemViewController *vc = (FriendItemViewController *)[friendsItemArray objectAtIndex:[friendsItemArray count] - 1];
                
                [self.scrollView addSubview:vc.view];
                
                startY += fiVC.view.frame.size.height;
                
            }
            
            scrollView.contentSize = CGSizeMake(320, startY);
            
            if ([userListArray count] == 0) {
                scrollView.hidden = YES;
            
                if ([requestType isEqualToString:REQUEST_FOR_FACEBOOK]) {
                    descriptionLabel.text = @"There are no Facebook friends.";
                }else {
                    descriptionLabel.text = @"There are no Twiiter friends.";
                }
                
                applicationButton.hidden = YES;
                
                contentView.hidden = NO;
            }
            
            [self endLoading];
            
        }else if ([requestType isEqualToString:REQUEST_USERID]) {
            NSString *uId = [dict objectForKey:TAG_RES_USERID];
            
            UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
            
            ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
            
            [profileViewController setUserId:uId];
                
            [navigationController pushViewController:profileViewController animated:YES];

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

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark Clear ScrollView Function

- (void) clearScrollView {
    
    startY = 0;
    
    for (UIView *child in scrollView.subviews) {
        [child removeFromSuperview];
    }
}

-(void)viewWillLayoutSubviews{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.view.clipsToBounds = YES;

        
        CGFloat screenHeight = screenRect.size.height;
        self.mainContentView.frame =  CGRectMake(0, 20, self.mainContentView.frame.size.width,screenHeight-20);

        
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
    }else {
        mainContentView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 20);
    }
    
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, screenRect.size.height - 95)];
}

@end
