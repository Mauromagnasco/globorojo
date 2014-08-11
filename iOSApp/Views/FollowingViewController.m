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

#import "FollowingViewController.h"
#import "Constants.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import "UserController.h"
#import "AppSharedData.h"
#import "FriendItemViewController.h"
#import "ProfileViewController.h"


#define REQUEST_FOR_NOTIFICATION            @"notification"
#define REQUEST_FOR_FOLLOWING               @"following"
#define REQUEST_USERID                      @"userid"

@interface FollowingViewController ()

@end

@implementation FollowingViewController

@synthesize userid;
@synthesize navTitleLabel;
@synthesize descriptionContentView;
@synthesize scrollView;
@synthesize descriptionLabel;
@synthesize menuButton;
@synthesize viewLoading;
@synthesize recvData;
@synthesize requestType;
@synthesize activityView;
@synthesize menu;
@synthesize followingItemArray;
@synthesize mainContentView;
@synthesize followingCount;

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
}

- (void)viewWillAppear:(BOOL)animated {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Following" forKey:@"currentView"];

    [[NSUserDefaults standardUserDefaults] setObject:@"Following" forKey:@"lastView"];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(requestFollowingUserId:) name:IFNotiLabelFollowingUserNotification object:Nil];
    
    followingItemArray = [[NSMutableArray alloc] init];
    
    [self requestFollowing];
    
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
    descriptionContentView.hidden = YES;
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
        [menu showFromRect:CGRectMake(0, 60, screenSize.width, screenSize.height - 40) inView:self.view];
    }else {
        [menu showFromRect:CGRectMake(0, 40, screenSize.width, screenSize.height - 40) inView:self.view];
    }
}

#pragma mark -
#pragma mark Set Style Functions

- (void) setStyle {
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:20.0]];
    [descriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:19.0]];
    
    
    //add Activity Indicator View
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 100;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
    
}
-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
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


- (void) requestFollowingUserId: (NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFNotiLabelFollowUserNotification object:Nil];
    
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

- (void) requestFollowing {
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, FOLLOWING_LIST_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_USERID, userid];
    
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
    requestType = REQUEST_FOR_FOLLOWING;
    
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
            
        }else if ([requestType isEqualToString:REQUEST_FOR_FOLLOWING]) {
            
            followingItemArray = [NSMutableArray array];
            [self clearScrollView];
            
            NSMutableArray *userListArray = [dict objectForKey:TAG_RES_USERLIST];
            
            for (int i = 0; i < [userListArray count]; i++) {
                
                NSDictionary *dict1 = [userListArray objectAtIndex:i];
                
                FriendItemViewController *fiVC = [[FriendItemViewController alloc] initWithNibName:@"FriendItemViewController" bundle:Nil];
                
                [fiVC setData:dict1];
                [fiVC setNumber:i];
                [fiVC setFollowingCount:followingCount];
                fiVC.view.frame = CGRectMake(0, startY, fiVC.view.frame.size.width, fiVC.view.frame.size.height);
                
                [followingItemArray addObject:fiVC];
                
                FriendItemViewController *vc = (FriendItemViewController *)[followingItemArray objectAtIndex:[followingItemArray count] - 1];
                
                [self.scrollView addSubview:vc.view];
                
                startY += fiVC.view.frame.size.height;
                
            }
            
            scrollView.contentSize = CGSizeMake(320, startY);
            
            if ([userListArray count] == 0) {
                scrollView.hidden = YES;
                descriptionContentView.hidden = NO;
            }else {
                scrollView.hidden = NO;
                descriptionContentView.hidden = YES;
            }
            
            [self requestCheckNotification];
            
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
    
    scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, screenRect.size.width, screenRect.size.height - 60);
}


@end
