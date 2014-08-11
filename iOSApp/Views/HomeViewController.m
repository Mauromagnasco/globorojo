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

#import "HomeViewController.h"
#import "Constants.h"
#import "SBJson.h"
#import "UserController.h"
#import "RBVideoViewController.h"
#import "CommentViewController.h"
#import "CreateVideoItemViewController.h"
#import "ProfileViewController.h"
#import "NotificationViewController.h"
#import "SearchViewController.h"
#import "AppDelegate.h"
#import "REMenu.h"
#import "FindFriendsViewController.h"
#import "AppSharedData.h"
#import "RBUserListViewController.h"
#import "RBVideoListViewController.h"
#import "MTDropDownView.h"

@interface HomeViewController ()

@end

#define REQUEST_FOR_GETTIME                 @"time"
#define REQUEST_FOR_VIDEOITEM               @"video"
#define REQUEST_FOR_NOTIFICATION            @"notification"
#define REQUEST_FOR_REFRESH_GETTIME         @"refreshtime"
#define REQUEST_FOR_REFRESH_VIDEOITEM       @"refreshvideo"
#define REQUEST_FOR_REFRESH_USERITEM        @"refreshuser"
#define REQUEST_FOR_USERLIST                @"user"
#define LIST_VIDEO_ITEM                     @"list"
#define DETAIL_VIDEO_ITEM                   @"detail"
#define USER_VIDEO_ITEM                     @"user"


@implementation HomeViewController


static HomeViewController *sharedInstance = nil;

@synthesize segmentContainerView;
@synthesize searchTextField;
@synthesize scrollView;
@synthesize segmentedControl;

@synthesize orderType;
@synthesize activityView;
@synthesize recvData;
@synthesize requestType;
@synthesize currentTime;
@synthesize videoItemArray;
@synthesize viewLoading;
@synthesize notificationButton;
@synthesize navBarView;
@synthesize menu;
@synthesize smenu;
@synthesize descriptionContentView;
@synthesize descriptionLabel;
@synthesize findFriendsButton;
@synthesize mainContentView;
@synthesize updateItemArray;
@synthesize heightArray;
@synthesize arrow;
@synthesize hashtagDetailButton;
@synthesize hashtagHomeButton;
@synthesize hashtagListButton;
@synthesize usernameButton;
@synthesize userSegmentedControl;
@synthesize videoItemType;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetOffset:) name:@"HomeViewHide" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCommentItem:) name:@"HomeAddCommentItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCommentItem:) name:@"HomeRemoveCommentItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeVideoItem:) name:@"HomeRemoveVideoItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentItem:) name:@"HomeShowCommentItem" object:Nil];
    
    
     NSArray *viewControllers = [self.navigationController viewControllers];
    
    if ([viewControllers count] == 1) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) setStyle {

    self.segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0,0, 320, 35)];
    [self.segmentedControl setSectionTitles:@[@"Date", @"Score", @"Meri.to"]];
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
//        [weakSelf.scrollView scrollRectToVisible:CGRectMake(320 * index, 0, 320, 200) animated:YES];
        self.orderType = index;
        cntLoaded = 0;
        if (smenu.isOpen) [smenu close];
        
        for (UIView *child in scrollView.subviews) {
            [child removeFromSuperview];
        }
        
        if (index != 1) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:3] forKey:@"period"];
        }
        
        [self requestCurrentTime];
    }];
    
    //set User search segmented control
    self.userSegmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0,0, 320, 35)];
    [self.userSegmentedControl setSectionTitles:@[@"Date", @"Meri.to"]];
    [self.userSegmentedControl setSelectedSegmentIndex:0];
    [self.userSegmentedControl setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1]];
    [self.userSegmentedControl setTextColor:[UIColor whiteColor]];
    [self.userSegmentedControl setSelectedTextColor:[UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1]];
    [self.userSegmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1]];
    [self.userSegmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [self.userSegmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationUp];
    [self.userSegmentedControl setTag:3];
    
    [self.userSegmentedControl setIndexChangeBlock:^(NSInteger index) {
        //        [weakSelf.scrollView scrollRectToVisible:CGRectMake(320 * index, 0, 320, 200) animated:YES];
        
        userOrderType = index;
        
        if (smenu.isOpen) [smenu close];
        
        [self clearScrollView];
        [self resetCntValues];
        [self requestCurrentTime];
    }];
    
    
    arrow = [[CollapseClickArrow alloc] initWithFrame:CGRectMake(190, 18, 7, 7)];
    [arrow setBackgroundColor:[UIColor clearColor]];
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
    arrow.transform = transform;
    [arrow drawWithColor:[UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1]];
    [segmentContainerView addSubview:arrow];
    
    
    orderType = 0;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2 - 45, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
    
    //set Font
    [searchTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
    [descriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:18.0f]];
    [findFriendsButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:19.0]];
    descriptionContentView.hidden = YES;
    
    //init Video Item Array
    videoItemArray = [[NSMutableArray alloc] init];
    heightArray = [[NSMutableArray alloc] init];
    
    
    //set ScrollView Delegate
    scrollView.delegate = self;
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, screenSize.width, screenSize.height - 75)];
    
//    if (screenSize.height <= 480) {
//        [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height - 20)];
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [MTDropDownView showDropDownViewInView:self.view text:@"People you follow" animated:YES target:self selector:nil hideAfter:4];
    
    sharedInstance = self;
    
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        [self setNotiButton_Red];
    }else {
        [self setNotiButton_Normal];
    }
    
    lodingFlag = FALSE;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Home" forKey:@"SuperController"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"linkCount"];
    
    NSString *lastView  = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastView"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Home" forKey:@"lastView"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Home" forKey:@"currentView"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    smenu = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).smenu;
    
    if (([lastView isEqualToString:@"Rate"] || [lastView isEqualToString:@"VideoPlay"] || [lastView isEqualToString:@"Search"] || [lastView isEqualToString:@"Profile"] || [lastView isEqualToString:@"Notification"] || [lastView isEqualToString:@"ShareVideo"] || [lastView isEqualToString:@"DeleteVideo"] || [lastView isEqualToString:@"SearchDetail"] || [lastView isEqualToString:@"CreateVideo"]) && [videoItemArray count] > 0) {
        
        [self requestRefreshCurrentTime];
        
        return;
    }
    
    for (UIView *child in scrollView.subviews) {
        [child removeFromSuperview];
    }
    
    searchTextField.delegate = self;
    
    cntLazyLoad = 3;
    cntLoaded = 0;
    [self clearScrollView];
    [self setButtonType:1];
    [self setScrollContainerFrame:1];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self performSelectorOnMainThread:@selector(changeLastView) withObject:Nil waitUntilDone:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTWeetLabelPostNotification object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTweetLabelUserNotification object:nil];
    
}
- (void) changeLastView {
    [[NSUserDefaults standardUserDefaults] setObject:@"Home" forKey:@"lastView"];
}


#pragma mark-
#pragma mark Request Functions

- (void) requestVideoItem {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, REQUEST_VIDEO_ITEM_URL];
    
    //make request
    
    NSString *key;
    
    NSString *txtkeyword = searchTextField.text;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    if (orderType != 1) {
        key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu",
               TAG_REQ_USERID, [[UserController instance] userUserID],
               TAG_REQ_TYPE, (unsigned long)orderType,
               TAG_REQ_TXTKEYWORD, txtkeyword,
               TAG_REQ_CNTLOADED, (unsigned long) cntLoaded,
               TAG_REQ_CURRENTTIME, currentTime,
               TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLazyLoad];
    }else {
        int period = [[[NSUserDefaults standardUserDefaults] objectForKey:@"period"] intValue];
        key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
               TAG_REQ_USERID, [[UserController instance] userUserID],
               TAG_REQ_TYPE, (unsigned long)orderType,
               TAG_REQ_TXTKEYWORD, txtkeyword,
               TAG_REQ_CNTLOADED, (unsigned long) cntLoaded,
               TAG_REQ_CURRENTTIME, currentTime,
               TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLazyLoad,
               TAG_REQ_PERIOD, (unsigned long) period];
    }
    
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
    requestType = REQUEST_FOR_VIDEOITEM;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestRefreshVideoItem {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, REQUEST_VIDEO_ITEM_URL];
    
    //make request
    
    NSString *key;
    
    NSString *txtkeyword = searchTextField.text;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    if (orderType != 1) {
        key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu",
               TAG_REQ_USERID, [[UserController instance] userUserID],
               TAG_REQ_TYPE, (unsigned long)orderType,
               TAG_REQ_TXTKEYWORD, txtkeyword,
               TAG_REQ_CNTLOADED, (unsigned long) 0,
               TAG_REQ_CURRENTTIME, currentTime,
               TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLoaded];
    }else {
        int period = [[[NSUserDefaults standardUserDefaults] objectForKey:@"period"] intValue];
        key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
               TAG_REQ_USERID, [[UserController instance] userUserID],
               TAG_REQ_TYPE, (unsigned long)orderType,
               TAG_REQ_TXTKEYWORD, txtkeyword,
               TAG_REQ_CNTLOADED, (unsigned long) 0,
               TAG_REQ_CURRENTTIME, currentTime,
               TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLoaded,
               TAG_REQ_PERIOD, (unsigned long) period];
    }
    
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
    requestType = REQUEST_FOR_REFRESH_VIDEOITEM;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestRefreshUserList {
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_MY_USER_LIST_URL];
    
    //make request
    
    NSString *txtkeyword = searchTextField.text;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu",
                      TAG_REQ_TXTKEYWORD, txtkeyword,
                      TAG_REQ_CNTLOADED, (unsigned long) 0,
                      TAG_REQ_CURRENTTIME, currentTime,
                      TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLoaded,
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_TYPE, (unsigned long)userOrderType + 1];
    
    
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
    requestType = REQUEST_FOR_REFRESH_USERITEM;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestCurrentTime {
    
    startY = 6;
    [videoItemArray removeAllObjects];
    [heightArray removeAllObjects];
    
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

- (void) requestRefreshCurrentTime {

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
    requestType = REQUEST_FOR_REFRESH_GETTIME;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];

}

- (void) requsetCheckNotification {
    
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

- (void) requestUserList {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_MY_USER_LIST_URL];
    
    //make request
    
    NSString *txtkeyword = searchTextField.text;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu",
                      TAG_REQ_TXTKEYWORD, txtkeyword,
                      TAG_REQ_CNTLOADED, (unsigned long) cntLoaded,
                      TAG_REQ_CURRENTTIME, currentTime,
                      TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLazyLoad,
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_TYPE, (unsigned long)userOrderType + 1];
    
    
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
    requestType = REQUEST_FOR_USERLIST;
    
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
        
        if ([requestType isEqualToString:REQUEST_FOR_GETTIME]) {
            currentTime = [dict objectForKey:TAG_RES_CURRENTTIME];
            
            if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
                [self requestUserList];
            }else {
                [self requestVideoItem];
            }
        }else if ([requestType isEqualToString:REQUEST_FOR_VIDEOITEM]){
            
            NSMutableArray *videoListArray;
            
            videoListArray = [dict objectForKey:TAG_RES_VIDEOLIST];
            
            if ([videoListArray count] == 0 && cntLoaded == 0) {
                scrollView.hidden = YES;
                descriptionContentView.hidden = NO;
            }else {
                scrollView.hidden = NO;
                descriptionContentView.hidden = YES;
            }
            
            if ([videoItemType isEqualToString:DETAIL_VIDEO_ITEM]) {
                for (int i = 0; i < [videoListArray count]; i++) {
                    NSDictionary *dict1 = [videoListArray objectAtIndex:i];
                    
                    RBVideoViewController *rbVC = [[RBVideoViewController alloc] initWithNibName:@"RBVideoViewController" bundle:Nil];
                    
                    [rbVC setData:dict1];
                    [rbVC setNumber:cntLoaded];
                    rbVC.view.frame = CGRectMake(6, startY, rbVC.view.frame.size.width, rbVC.view.frame.size.height);
                    
                    [videoItemArray addObject:rbVC];
                    
                    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:[videoItemArray count] - 1];
                    
                    [self.scrollView addSubview:vc.view];
                    [heightArray addObject:[NSNumber numberWithInt:vc.view.frame.size.height]];
                    
                    
                    startY += rbVC.view.frame.size.height + stepY;
                    
                    cntLoaded ++;
                    
                }
                
                if ([videoListArray count] != 0 && cntLoaded > cntLazyLoad) {
                    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 20) animated:YES];
                }
                
                
                scrollView.contentSize = CGSizeMake(320, startY);
            }else {
                for (int i = 0; i < [videoListArray count]; i++) {
                    NSDictionary *dict1 = [videoListArray objectAtIndex:i];
                    
                    RBVideoListViewController *rbVC = [[RBVideoListViewController alloc] initWithNibName:@"RBVideoListViewController" bundle:Nil];
                    
                    [rbVC setData:dict1];
                    [rbVC setNumber:cntLoaded];
                    
                    rbVC.view.frame = CGRectMake(5, startY, rbVC.view.frame.size.width, rbVC.view.frame.size.height);
                    
                    [videoItemArray addObject:rbVC];
                    
                    RBVideoListViewController *vc = (RBVideoListViewController *)[videoItemArray objectAtIndex:[videoItemArray count] - 1];
                    
                    [self.scrollView addSubview:vc.view];
                    
                    [heightArray addObject:[NSNumber numberWithInt:vc.view.frame.size.height]];
                    
                    startY += rbVC.view.frame.size.height + stepY;
                    
                    cntLoaded ++;
                    
                }
                
                if ([videoListArray count] != 0 && cntLoaded > cntLazyLoad) {
                    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 20) animated:YES];
                }
                
                
                scrollView.contentSize = CGSizeMake(320, startY);
            }
            
            [self requsetCheckNotification];
            
            [self endLoading];
        }else if ([requestType isEqualToString:REQUEST_FOR_NOTIFICATION]){
            NSString *checkFlag = [dict objectForKey:TAG_RES_ISNEWNOTIFICATION];
            
            if ([checkFlag isEqualToString:@"Y"]) {
                [notificationButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
            }else {
                [notificationButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
            }
            [self endLoading];
        }else if ([requestType isEqualToString:REQUEST_FOR_REFRESH_GETTIME]) {
            
            currentTime = [dict objectForKey:TAG_RES_CURRENTTIME];
            if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
                [self requestRefreshUserList];
            }else {
                [self requestRefreshVideoItem];
            }
            
        }else if ([requestType isEqualToString:REQUEST_FOR_REFRESH_VIDEOITEM]) {
            
            updateItemArray = [dict objectForKey:TAG_RES_VIDEOLIST];
            
            float pheight, nheight;
            float sheight = 0;
            int j, i;
            
            
            if ([videoItemType isEqualToString:DETAIL_VIDEO_ITEM] && [updateItemArray count] > 0) {
                
                //for added videoitem
                
                i = j = 0;
                
                for (i = 0; i < [updateItemArray count]; i++) {
                    NSDictionary *dict1 = [updateItemArray objectAtIndex:i];
                    
                    NSString *vid = [dict1 objectForKey:TAG_RES_RB_VIDEO];
                    
                    for (j = 0; j < [videoItemArray count]; j++) {
                        RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:j];
                        
                        if ([vid isEqualToString:vc.videoID]) {
                            pheight = [[heightArray objectAtIndex:j] intValue];
                            [vc clear];
                            [vc setData:dict1];
                            [vc parseData];
                            nheight = vc.view.frame.size.height;
                            
                            if (pheight != nheight) {
                                float iheight = nheight - pheight;
                                sheight += iheight;
                                for (int k = j + 1; k < [videoItemArray count]; k++) {
                                    RBVideoViewController *vc1 = (RBVideoViewController *)[videoItemArray objectAtIndex:k];
                                    [vc1.view setCenter:CGPointMake(vc1.view.center.x, vc1.view.center.y + iheight)];
                                }
                                [heightArray replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:nheight]];
                            }
                            
                            break;
                        }
                    }
                    
                    if (j == [videoItemArray count]) {
                        RBVideoViewController *rbVC = [[RBVideoViewController alloc] initWithNibName:@"RBVideoViewController" bundle:Nil];
                        
                        [rbVC setData:dict1];
                        [rbVC setNumber:cntLoaded];
                        rbVC.view.frame = CGRectMake(6, 6, 308, rbVC.view.frame.size.height);
                        
                        
                        [videoItemArray addObject:rbVC];
                        [heightArray addObject:[NSNumber numberWithInt:rbVC.view.frame.size.height]];
                        
                        [self insertViewToScrollView];
                        
                    }
                }
                
                //for deleted video item
                
                i = j = 0;
                
                for (i = 0; i < [videoItemArray count]; i++) {
                    
                    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
                    
                    for (j = 0; j < [updateItemArray count]; j++) {
                        NSDictionary *dict1 = [updateItemArray objectAtIndex:j];
                        NSString *vid = [dict1 objectForKey:TAG_RES_RB_VIDEO];
                        
                        if ([vid isEqualToString:vc.videoID]) {
                            break;
                        }
                    }
                    
                    if (j == [updateItemArray count]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:vc.number] forKey:@"RemoveVideoNumber"];
                        [self removeVideoItem];
                    }
                }
                
            }else if ([updateItemArray count] > 0){
                //for added video item
                i = j = 0;
                
                for (i = 0; i < [updateItemArray count]; i++) {
                    NSDictionary *dict1 = [updateItemArray objectAtIndex:i];
                    
                    NSString *vid = [dict1 objectForKey:TAG_RES_RB_VIDEO];
                    
                    for (j = 0; j < [videoItemArray count]; j++) {
                        RBVideoListViewController *vc = (RBVideoListViewController *)[videoItemArray objectAtIndex:j];
                        
                        if ([vid isEqualToString:vc.videoID]) {
                            pheight = [[heightArray objectAtIndex:j] intValue];
                            [vc clear];
                            [vc setData:dict1];
                            [vc parseData];
                            nheight = vc.view.frame.size.height;
                            
                            if (pheight != nheight) {
                                float iheight = nheight - pheight;
                                sheight += iheight;
                                for (int k = j + 1; k < [videoItemArray count]; k++) {
                                    RBVideoListViewController *vc1 = (RBVideoListViewController *)[videoItemArray objectAtIndex:k];
                                    [vc1.view setCenter:CGPointMake(vc1.view.center.x, vc1.view.center.y + iheight)];
                                }
                                [heightArray replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:nheight]];
                            }
                            
                            break;
                        }
                    }
                    
                    if (j == [videoItemArray count]) {
                        
                        RBVideoListViewController *rbVC = [[RBVideoListViewController alloc] initWithNibName:@"RBVideoViewController" bundle:Nil];
                        
                        [rbVC setData:dict1];
                        [rbVC setNumber:cntLoaded];
                        rbVC.view.frame = CGRectMake(6, 6, 308, rbVC.view.frame.size.height);
                        
                        
                        [videoItemArray addObject:rbVC];
                        [heightArray addObject:[NSNumber numberWithInt:rbVC.view.frame.size.height]];
                        
                        [self insertViewToScrollView];
                        
                    }
                }
                
                i = j = 0;
                
                //for deleted video item
                for (i = 0; i < [videoItemArray count]; i++) {
                    
                    RBVideoListViewController *vc = (RBVideoListViewController *)[videoItemArray objectAtIndex:j];
                    
                    for (j = 0; j < [updateItemArray count]; j++) {
                        NSDictionary *dict1 = [updateItemArray objectAtIndex:j];
                        NSString *vid = [dict1 objectForKey:TAG_RES_RB_VIDEO];
                        
                        if ([vid isEqualToString:vc.videoID]) {
                            break;
                        }
                    }
                    
                    if (j == [updateItemArray count]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:vc.number] forKey:@"RemoveVideoNumber"];
                        [self removeVideoItem];
                    }
                }
            }
            
            [self endLoading];
            
        }else if ([requestType isEqualToString:REQUEST_FOR_REFRESH_USERITEM]) {
        
            NSMutableArray *userListArray;
            
            userListArray = [dict objectForKey:TAG_RES_VIDEOLIST];
            currentTime = [dict objectForKey:TAG_RES_CURRENTTIME];
            
            if ([userListArray count] > 0) {
                
                //for added userlist
                int i, j;
                
                for (i = 0; i < [userListArray count]; i++) {
                    NSDictionary *dict1 = [userListArray objectAtIndex:i];
                    
                    NSString *userId = [dict1 objectForKey:TAG_RES_RB_USER];
                    
                    for (j = 0; j < [videoItemArray count]; j ++) {
                        RBUserListViewController *rbVC = (RBUserListViewController *)[videoItemArray objectAtIndex:j];
                        
                        if ([rbVC.userId isEqualToString:userId]) {
                            break;
                        }
                    }
                    
                    if (j == [videoItemArray count]) {
                        RBUserListViewController *rbVC = [[RBUserListViewController alloc] initWithNibName:@"RBVideoViewController" bundle:Nil];
                        
                        [rbVC setData:dict1];
                        [rbVC setNumber:cntLoaded];
                        rbVC.view.frame = CGRectMake(6, 6, 308, rbVC.view.frame.size.height);
                        
                        
                        [videoItemArray addObject:rbVC];
                        [heightArray addObject:[NSNumber numberWithInt:rbVC.view.frame.size.height]];
                        
                        [self insertViewToScrollView];
                        
                    }
                }
                
                // for removed userlist
                
                
                if ([userListArray count] != 0 && cntLoaded > cntLazyLoad) {
                    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 20) animated:YES];
                }
            }
            
            scrollView.contentSize = CGSizeMake(320, startY);
            
            [self requsetCheckNotification];
            
            [self endLoading];
            
        }else if ([requestType isEqualToString:REQUEST_FOR_USERLIST]){
            
            NSMutableArray *userListArray;
            
            userListArray = [dict objectForKey:TAG_RES_USERLIST];
            
            if ([userListArray count] == 0 && cntLoaded == 0) {
                descriptionContentView.hidden = NO;
                scrollView.hidden = YES;
                
                descriptionLabel.text = @"This Username doesn't have result.";
            }else {
                descriptionContentView.hidden = YES;
                scrollView.hidden = NO;
            }
            
            for (int i = 0; i < [userListArray count]; i++) {
                NSDictionary *dict1 = [userListArray objectAtIndex:i];
                
                RBUserListViewController *rbVC = [[RBUserListViewController alloc] initWithNibName:@"RBUserListViewController" bundle:Nil];
                
                [rbVC setData:dict1];
                [rbVC setNumber:cntLoaded];
                
                rbVC.view.frame = CGRectMake(5, startY, rbVC.view.frame.size.width, rbVC.view.frame.size.height);
                
                [videoItemArray addObject:rbVC];
                
                RBUserListViewController *vc = (RBUserListViewController *)[videoItemArray objectAtIndex:[videoItemArray count] - 1];
                
                [self.scrollView addSubview:vc.view];
                
                startY += rbVC.view.frame.size.height + stepY;
                
                cntLoaded ++;
                
            }
            
            if ([userListArray count] != 0 && cntLoaded > cntLazyLoad) {
                [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 20) animated:YES];
            }
            
            
            scrollView.contentSize = CGSizeMake(320, startY);
            [self endLoading];
        }
        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        
        if (![errorMsg isEqualToString:@""] && errorMsg != Nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
        
        [self endLoading];
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
#pragma mark Insert View to ScrollView

- (void) insertViewToScrollView {
    
    
    if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
        RBUserListViewController *vc = (RBUserListViewController *)[videoItemArray objectAtIndex:[videoItemArray count] - 1];
        
        [self.scrollView addSubview:vc.view];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        for (int i = 0; i < [videoItemArray count] - 1; i++) {
            RBUserListViewController *cvc = (RBUserListViewController *)[videoItemArray objectAtIndex:i];
            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y + iheight)];
        }
        
        [self.scrollView setNeedsDisplay];
        
        startY += iheight;
        scrollView.contentSize = CGSizeMake(320, startY + 20);
        
    }else if ([videoItemType isEqualToString:DETAIL_VIDEO_ITEM]){
        
        RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:[videoItemArray count] - 1];
        
        [self.scrollView addSubview:vc.view];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        for (int i = 0; i < [videoItemArray count] - 1; i++) {
            RBVideoViewController *cvc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y + iheight)];
        }
        
        [self.scrollView setNeedsDisplay];
        
        startY += iheight;
        scrollView.contentSize = CGSizeMake(320, startY + 20);
    }else {
        RBVideoListViewController *vc = (RBVideoListViewController *)[videoItemArray objectAtIndex:[videoItemArray count] - 1];
        
        [self.scrollView addSubview:vc.view];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        for (int i = 0; i < [videoItemArray count] - 1; i++) {
            RBVideoListViewController *cvc = (RBVideoListViewController *)[videoItemArray objectAtIndex:i];
            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y + iheight)];
        }
        
        [self.scrollView setNeedsDisplay];
        
        startY += iheight;
        scrollView.contentSize = CGSizeMake(320, startY + 20);
    }
}


#pragma mark-
#pragma mark IBAction Functions

- (IBAction)onProfileButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:Nil];
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (IBAction)onNotificationButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    NotificationViewController *notificationViewController = [[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:Nil];
    
    [self.navigationController pushViewController:notificationViewController animated:YES];
}

- (IBAction)onSearchButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    [searchTextField resignFirstResponder];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onAddVideoButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    CreateVideoItemViewController *createVideoViewController = [[CreateVideoItemViewController alloc] initWithNibName:@"CreateVideoItemViewController" bundle:nil];
    
    [self.navigationController pushViewController:createVideoViewController animated:YES];
}

- (IBAction)onMenuButton:(id)sender {
    
    if (menu.isOpen)
        return [menu close];
    if (smenu.isOpen) [smenu close];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [menu showFromRect:CGRectMake(0, 60, screenSize.width, screenSize.height - 40) inView:self.view];
    }else {
        [menu showFromRect:CGRectMake(0, 40, screenSize.width, screenSize.height - 40) inView:self.view];
    }
}

- (IBAction)onFindFriendsButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] initWithNibName:@"FindFriendsViewController" bundle:Nil];

    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

- (IBAction)onHashtagHomeButton:(id)sender {
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    if (lodingFlag) {
        return;
    }
    
    [self setButtonType:1];
    [self setScrollContainerFrame:1];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onHashtagListButton:(id)sender {
    if (lodingFlag) {
        return;
    }
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    [self setButtonType:1];
    [self setScrollContainerFrame:1];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onHashtagDetailButton:(id)sender {
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    if (lodingFlag) {
        return;
    }
    
    [self setButtonType:2];
    [self setScrollContainerFrame:1];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onUsernameButton:(id)sender {
    
    if (lodingFlag) {
        return;
    }
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    [self setButtonType:3];
    [self setScrollContainerFrame:2];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onBigWatchButton:(id)sender {
    
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    UIViewController *vc;
    int i;
    
    for (i = [viewControllers count] - 2; i >= 0; i--) {
        vc = [viewControllers objectAtIndex:i];
        
        if ([vc isKindOfClass:[SearchViewController class]]) {
            break;
        }
    }
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    
    if (i >= 0) {
        [self.navigationController popToViewController:vc animated:YES];
    }else {
        SearchViewController *vc = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void) setButtonType: (int) type {
    if (type == 1) {
        hashtagHomeButton.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
        hashtagHomeButton.titleLabel.textColor = [UIColor whiteColor];
        [hashtagListButton setBackgroundImage:[UIImage imageNamed:@"btnListRed.png"] forState:UIControlStateNormal];
        [hashtagDetailButton setBackgroundImage:[UIImage imageNamed:@"btnDetailGrey.png"] forState:UIControlStateNormal];
        usernameButton.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        usernameButton.titleLabel.textColor = [UIColor whiteColor];
        videoItemType = LIST_VIDEO_ITEM;
    }else if (type == 2) {
        hashtagHomeButton.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
        hashtagHomeButton.titleLabel.textColor = [UIColor whiteColor];
        [hashtagListButton setBackgroundImage:[UIImage imageNamed:@"btnListGrey.png"] forState:UIControlStateNormal];
        [hashtagDetailButton setBackgroundImage:[UIImage imageNamed:@"btnDetailRed.png"] forState:UIControlStateNormal];
        usernameButton.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        usernameButton.titleLabel.textColor = [UIColor whiteColor];
        videoItemType = DETAIL_VIDEO_ITEM;
    }else {
        hashtagHomeButton.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
        hashtagHomeButton.titleLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
        [hashtagListButton setBackgroundImage:[UIImage imageNamed:@"btnListGrey.png"] forState:UIControlStateNormal];
        [hashtagDetailButton setBackgroundImage:[UIImage imageNamed:@"btnDetailGrey.png"] forState:UIControlStateNormal];
        usernameButton.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
        usernameButton.titleLabel.textColor = [UIColor whiteColor];
        self.orderType = 0;
        videoItemType = USER_VIDEO_ITEM;
    }
    
    heightArray = [NSMutableArray array];
}

- (void) setScrollContainerFrame: (int) type {
    
    if (type == 1) {
        [self.userSegmentedControl removeFromSuperview];
        [self.segmentContainerView addSubview:segmentedControl];
        [self.segmentContainerView addSubview:arrow];
    }else {
        [self.segmentedControl removeFromSuperview];
        [arrow removeFromSuperview];
        [self.segmentContainerView addSubview:userSegmentedControl];
    }
}

#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    
    lodingFlag = TRUE;
    
    for (UIView *child in scrollView.subviews) {
        child.userInteractionEnabled = FALSE;
    }
    
    self.segmentedControl.enabled = NO;
//    scrollView.scrollEnabled = NO;
    [activityView startAnimation];
    viewLoading.hidden = NO;
    viewLoading.alpha = 1;
}

- (void)endLoading{
    
    lodingFlag = FALSE;
    
    for (UIView *child in scrollView.subviews) {
        child.userInteractionEnabled = TRUE;
    }
    
    segmentedControl.enabled = YES;
//    scrollView.scrollEnabled = YES;
    
    [UIView animateWithDuration:.5
                     animations:^{
                         viewLoading.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         viewLoading.hidden = YES;
                         [activityView stopAnimation];
                     }];

}


#pragma mark - 
#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && !lodingFlag) {
        // we are at the end
        [self startLoading];
        
        if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
            [self requestUserList];
        }else {
            [self requestVideoItem];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.y < -100.0 && scrollView.contentOffset.y > -110.0) {
        
        [self requestRefreshCurrentTime];
        
    }
}

#pragma mark -
#pragma mark NSNotification Center Functions

- (void) showSmallMenu {
    
    if (smenu.isOpen)
        return [smenu close];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [smenu showFromRect:CGRectMake(screenSize.width / 3, 135, screenSize.width / 3, screenSize.height - 40) inView:self.view];
    }else {
        [smenu showFromRect:CGRectMake(screenSize.width / 3, 115, screenSize.width / 3, screenSize.height - 40) inView:self.view];
    }
}

- (void)resetOffset:(NSNotification *)notification {
    
    float currentPosition = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPosition"] floatValue];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    float stepY = currentPosition - (screenSize.height - 220);
    
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + stepY) animated:YES];
}

- (void) addCommentItem: (NSNotification *) notification {
    
    int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ViewNumber"] intValue];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommentUserName"];
    NSString *commentContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommentContent"];
    NSString *commentID = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommentID"];
    NSString *userID = [[UserController instance] userUserID];
    
    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:number];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          username, TAG_RES_RB_USERNAME,
                          commentContent, TAG_RES_RB_CONTENT,
                          commentID, TAG_RES_RB_USER_VIDEO_COMMENT,
                          userID, TAG_RES_RB_USER, nil];
    
    float iheight = [vc addCommentItemView: dict];
    
    [heightArray replaceObjectAtIndex:number withObject:[NSNumber numberWithInt:vc.view.frame.size.height]];

    for (int i = number + 1; i < [videoItemArray count]; i++) {
        RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
        [vc.view setCenter:CGPointMake(vc.view.center.x, vc.view.center.y + iheight)];
    }
    
    [self.scrollView setNeedsDisplay];
    
    startY += iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
    
    [self requsetCheckNotification];
}

- (void) removeCommentItem: (NSNotification *) notificaiton {
    
    int videoNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
    int commentNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveCommentNumber"] intValue];
    
    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:videoNumber];
    
    float iheight = [vc removeCommentItem:commentNumber];
    [heightArray replaceObjectAtIndex:videoNumber withObject:[NSNumber numberWithInt:vc.view.frame.size.height]];
    
    
    for (int i = videoNumber + 1; i < [videoItemArray count]; i++) {
        RBVideoViewController *cvc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
        [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
    }
    
    
    [self.scrollView setNeedsDisplay];
    
    startY -= iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
    
    [self requsetCheckNotification];
}

- (void) removeVideoItem {
    
    if ([videoItemType isEqualToString:DETAIL_VIDEO_ITEM]) {
        int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
        
        RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:number];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        [vc.view removeFromSuperview];
        
        for (int i = number + 1; i < [videoItemArray count]; i++) {
            RBVideoViewController *cvc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
        }
        
        [videoItemArray removeObjectAtIndex:number];
        [heightArray removeObjectAtIndex:number];
        [self.scrollView setNeedsDisplay];
        
        startY -= iheight;
    }else if ([videoItemType isEqualToString:LIST_VIDEO_ITEM]){
        int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
        
        RBVideoListViewController *vc = (RBVideoListViewController *)[videoItemArray objectAtIndex:number];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        [vc.view removeFromSuperview];
        
        for (int i = number + 1; i < [videoItemArray count]; i++) {
            RBVideoListViewController *cvc = (RBVideoListViewController *)[videoItemArray objectAtIndex:i];
            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
        }
        
        [videoItemArray removeObjectAtIndex:number];
        [heightArray removeObjectAtIndex:number];
        [self.scrollView setNeedsDisplay];
        
        startY -= iheight;
    }else {
        int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
        
        RBUserListViewController *vc = (RBUserListViewController *)[videoItemArray objectAtIndex:number];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        [vc.view removeFromSuperview];
        
        for (int i = number + 1; i < [videoItemArray count]; i++) {
            RBUserListViewController *cvc = (RBUserListViewController *)[videoItemArray objectAtIndex:i];
            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
        }
        
        [videoItemArray removeObjectAtIndex:number];
        [heightArray removeObjectAtIndex:number];
        [self.scrollView setNeedsDisplay];
        
        startY -= iheight;
    }

    scrollView.contentSize = CGSizeMake(320, startY + 20);
    
    [self startLoading];
    [self requestVideoItem];
    
    [self requsetCheckNotification];
}

- (void) removeVideoItem: (NSNotification *) notification {
    
    int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
    
    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:number];
    
    float iheight = vc.view.frame.size.height + stepY;
    
    [vc.view removeFromSuperview];
    
    for (int i = number + 1; i < [videoItemArray count]; i++) {
        RBVideoViewController *cvc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
        [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
    }
    
    [videoItemArray removeObjectAtIndex:number];
    [heightArray removeObjectAtIndex:number];
    [self.scrollView setNeedsDisplay];
    
    startY -= iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
    
    [self startLoading];
    [self requestVideoItem];
    
    [self requsetCheckNotification];
}

- (void) showCommentItem: (NSNotification *) notification {
    
    int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowCommentViewNumber"] intValue];
    
    [heightArray replaceObjectAtIndex:number withObject:[NSNumber numberWithInt:[[videoItemArray objectAtIndex:number] view].frame.size.height]];
    
    
    int iheight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowCommentIncreaseHeight"] intValue];
    
    for (int i = number + 1; i < [videoItemArray count]; i++) {
        RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
        [vc.view setCenter:CGPointMake(vc.view.center.x, vc.view.center.y + iheight)];
    }
    
    [self.scrollView setNeedsDisplay];
    
    startY += iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
}


-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(void)viewWillLayoutSubviews{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.view.clipsToBounds = YES;
        CGFloat screenHeight = screenRect.size.height;
        mainContentView.frame =  CGRectMake(0, 20, self.mainContentView.frame.size.width,screenHeight-20);
        [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, 458)];
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
    }else {
        mainContentView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 20);
    }
    
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, screenRect.size.height - 135)];
}

+(HomeViewController *) sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (void) clear {
    cntLoaded = 0;
    if (smenu.isOpen) [smenu close];
    
    for (UIView *child in scrollView.subviews) {
        [child removeFromSuperview];
    }
}

- (void) setNotiButton_Red {
    [notificationButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
}
- (void) setNotiButton_Normal {
    [notificationButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
}
- (void) clearScrollView {
    
    [videoItemArray removeAllObjects];
    for (UIView *child in scrollView.subviews) {
        [child resignFirstResponder];
    }
    for (UIView *child in scrollView.subviews) {
        [child removeFromSuperview];
    }
}
- (void) resetCntValues {
    if ([videoItemType isEqualToString:LIST_VIDEO_ITEM]) {
        cntLazyLoad = 7;
        cntLoaded = 0;
        startY = 5;
        stepY = 5;
    }else if ([videoItemType isEqualToString:DETAIL_VIDEO_ITEM]){
        cntLazyLoad = 3;
        cntLoaded = 0;
        startY = 6;
        stepY = 12;
    }else {
        cntLazyLoad = 7;
        cntLoaded = 0;
        startY = 5;
        stepY = 5;
    }
}

#pragma mark -
#pragma mark UITextField Delegate Functions
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchTextField resignFirstResponder];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
    return YES;
}

@end
