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

#import "NotificationViewController.h"
#import "Constants.h"
#import "UserController.h"
#import "SBJson.h"
#import "NotificationItemViewController.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "SearchVideoDetailViewController.h"
#import "AppSharedData.h"

#define REQUEST_FOR_READ            @"read"
#define REQUEST_FOR_GETTIME         @"time"
#define REQUEST_FOR_NOTIFICATION    @"notification"
#define REQUEST_USERID              @"userid"
#define REQUEST_VIDEO_INFO          @"videoInfo"
#define REQUEST_BADGE_COUNT         @"badgeCount"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

static NotificationViewController *sharedInstance = nil;

@synthesize scrollView;
@synthesize activityView;
@synthesize requestType;
@synthesize currentTime;
@synthesize recvData;
@synthesize notiItemArray;
@synthesize navTitleLabel;
@synthesize menuButton;
@synthesize menu;
@synthesize descriptionContentLabel;
@synthesize descriptionContentView;
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
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [self.view addSubview:activityView];
    activityView.hidden = YES;
    
    startY = 10;
    stepY = 10;
    
    scrollView.delegate = self;
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:20.0]];
    [descriptionContentLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:19.0]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"badgeNumber"];
    
    descriptionContentView.hidden = YES;

    
    [[NSUserDefaults standardUserDefaults] setObject:@"Notification" forKey:@"currentView"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Notification" forKey:@"lastView"];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(requestUserId:) name:IFNotiLabelUserNotification object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestVideoInfo:) name:IFNotiLabelPostNotification object:Nil];
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    sharedInstance = self;
    
    [self setNotiButton_Normal];
    
    
    [self clear];
    [self requestRead];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self clear];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) clear {
    startY = 10;
    cntLazyLoad = 10;
    cntLoaded = 0;
    notiItemArray = [[NSMutableArray alloc] init];
    
    for (UIView *child in scrollView.subviews) {
        [child removeFromSuperview];
    }
}

- (IBAction)onBackButton:(id)sender {
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *aController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    if ([aController isKindOfClass:[SearchViewController class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"returnSearch"];
    }
    
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
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    
    activityView.hidden = NO;
    activityView.alpha = 1;
    [activityView startAnimation];
}

- (void)endLoading{
    
    [UIView animateWithDuration:.5
                     animations:^{
                         activityView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         activityView.hidden = YES;
                         [activityView stopAnimation];
                     }];
    
}

#pragma mark -
#pragma mark Request Methods

- (void) requestUserId: (NSNotification *)notification {
    
    [self startLoading];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFNotiLabelUserNotification object:Nil];
    
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

- (void) requestVideoInfo: (NSNotification *)notification {
    
    [self startLoading];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFNotiLabelPostNotification object:self];
    
    //make URL
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, NOTI_GET_VIDEOINFO_URL];
    
    NSString *videoId = [[NSUserDefaults standardUserDefaults] objectForKey:@"PostVideoId"];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_VIDEOID, videoId];
    
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
    
    requestType = REQUEST_VIDEO_INFO;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) requestSetBadgeCount {
    
    //make URL
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SET_BADGE_COUNT_URL];
    
    int count = 0;
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu",
                      TAG_REQ_DEVTOKEN, [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"], TAG_REQ_COUNT, (unsigned long)count];
    
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
    
    requestType = REQUEST_BADGE_COUNT;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestRead {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SET_NOTI_STATUS_READED_URL];
    
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
    requestType = REQUEST_FOR_READ;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestCurrentTime {
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_CURRENTTIME_URL];
    
    //make request
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *timestr = [NSString stringWithFormat:@"%f", ti];
    NSString *skv = [AppSharedData base64String:[NSString stringWithFormat:@"%@-%@", timestr, APP_SECRET_KEY]];
    [request addValue:timestr forHTTPHeaderField:hv1];
    [request addValue:skv forHTTPHeaderField:hv2];
    
    // clear data
    self.recvData = [NSMutableData data];
    
    //set Request Type;
    requestType = REQUEST_FOR_GETTIME;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestNotificationItem {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_NOTIFICATION_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_CNTLOADED, (unsigned long)cntLoaded,
                      TAG_REQ_CURRENTTIME, currentTime,
                      TAG_REQ_CNTLAZYLOAD, (unsigned long)cntLazyLoad];
    
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

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    //    if ([requestType isEqualToString:REQUEST_VIDEO_ITEM_URL]) {
    //        [self endLoading];
    //    }
    
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
        
        if ([requestType isEqualToString:REQUEST_FOR_READ]) {
            [self requestCurrentTime];
        }else if ([requestType isEqualToString:REQUEST_FOR_GETTIME]) {
            currentTime = [dict objectForKey:TAG_RES_CURRENTTIME];
            [self requestNotificationItem];
        }else if ([requestType isEqualToString:REQUEST_FOR_NOTIFICATION]){
            
            NSMutableArray *notificationListArray;
            
            notificationListArray = [dict objectForKey:TAG_RES_NOTIFICATIONLIST];
            
            if ([notificationListArray count] == 0 && cntLoaded == 0) {
                descriptionContentView.hidden = NO;
                scrollView.hidden = YES;
            }else {
                scrollView.hidden = NO;
                descriptionContentView.hidden = YES;
            }
            
            for (int i = 0; i < [notificationListArray count]; i++) {
                NSDictionary *dict1 = [notificationListArray objectAtIndex:i];
                
                NotificationItemViewController *rbVC = [[NotificationItemViewController alloc] initWithNibName:@"NotificationItemViewController" bundle:Nil];
                
                [rbVC setData:dict1];
                //                [rbVC viewWillAppear:YES];
                rbVC.view.frame = CGRectMake(0, startY, rbVC.view.frame.size.width, rbVC.view.frame.size.height);
                
//                rbVC.view.layer.masksToBounds = NO;
//                rbVC.view.layer.cornerRadius = 0; // if you like rounded corners
//                rbVC.view.layer.shadowOffset = CGSizeMake(1, 1);
//                rbVC.view.layer.shadowRadius = 1;
//                rbVC.view.layer.shadowOpacity = 0.5;
                
                
                [notiItemArray addObject:rbVC];
                
                NotificationItemViewController *vc = (NotificationItemViewController *)[notiItemArray objectAtIndex:[notiItemArray count] - 1];
                
                [self.scrollView addSubview:vc.view];
                
                startY += rbVC.view.frame.size.height + stepY;
                
                cntLoaded ++;
                
            }
            
            if ([notiItemArray count] != 0 && cntLoaded > cntLazyLoad) {
                [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 20) animated:YES];
            }
            
            
            scrollView.contentSize = CGSizeMake(320, startY);
            
            [self endLoading];
            
            [self requestSetBadgeCount];
            
        }else if ([requestType isEqualToString:REQUEST_USERID]) {
            
            [self endLoading];
            
            NSString *uId = [dict objectForKey:TAG_RES_USERID];
            
            UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
            
            ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
            
            [profileViewController setUserId:uId];
            
            [navigationController pushViewController:profileViewController animated:YES];
            
        }else if ([requestType isEqualToString:REQUEST_VIDEO_INFO]) {
            
            [self endLoading];
            
            NSDictionary *rdict = [dict objectForKey:TAG_RES_VIDEOITEM];
            
            if ([rdict isEqual:[NSNull null]]) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You already deleted this video." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
            }else {
                SearchVideoDetailViewController *sVC = [[SearchVideoDetailViewController alloc] initWithNibName:@"SearchVideoDetailViewController" bundle:Nil];
                
                [sVC setData:rdict];
                
                [self.navigationController pushViewController:sVC animated:YES];
            }
        }else if ([requestType isEqualToString:REQUEST_BADGE_COUNT]) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
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
#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
        [self startLoading];
        [self requestNotificationItem];
    }
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
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
    
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, screenRect.size.height - 60)];
}

+(NotificationViewController *) sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (void) setNotiButton_Normal {
    [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
}


@end
