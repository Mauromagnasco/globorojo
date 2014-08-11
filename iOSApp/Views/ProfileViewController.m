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

#import "ProfileViewController.h"
#import "UserController.h"
#import "WelcomeViewController.h"
#import "AppDelegate.h"
#import "FollowingViewController.h"
#import "FollowsViewController.h"
#import "UserController.h"
#import "Constants.h"
#import "SBJson.h"
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AppSharedData.h"
#import "MTHTTPClient.h"
#import "categoryIteminfo.h"
#import "RBVideoListViewController.h"
#import "RBVideoViewController.h"
#import "EXPhotoViewer.h"

@implementation UILabel (UILabel_Auto)

- (void)adjustHeight {
    
    if (self.text == nil) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, 0);
        return;
    }
    
    CGSize aSize = self.bounds.size;
    CGSize tmpSize = CGRectInfinite.size;
    tmpSize.width = aSize.width;
    
    tmpSize = [self.text sizeWithFont:self.font constrainedToSize:tmpSize];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, aSize.width, tmpSize.height);
}

@end


#define REQUEST_FOR_MERIT                       @"merit"
#define REQUEST_FOR_VIDEOLIST                   @"videolist"
#define REQUEST_FOR_FOLLOW                      @"follow"
#define REQUEST_FOR_GETTIME                     @"gettime"
#define LIST_VIDEO_ITEM                         @"list"
#define DETAIL_VIDEO_ITEM                       @"detail"
#define MERIT_ITEM                              @"merit"
#define OTHER_ITEM                              @"other"


@interface ProfileViewController ()

@end

@implementation ProfileViewController

static ProfileViewController *sharedInstance = nil;

@synthesize navTitleLabel;
@synthesize profileImageView;
@synthesize videoCountLabel;
@synthesize followerCountLabel;
@synthesize followingCountLabel;
@synthesize videosDetailButton;
@synthesize videosHomeButton;
@synthesize videosListButton;
@synthesize meritButton;
@synthesize scrollContainerView;
@synthesize scrollView;
@synthesize recvData;
@synthesize activityView;
@synthesize settingsButton;
@synthesize categoryItemArray;
@synthesize meritContentView;
@synthesize meritDescriptionLabel;
@synthesize meritScrollView;
@synthesize meritUsernameLabel;
@synthesize meritUserscoreImageView;
@synthesize meritUserscoreLabel;
@synthesize meritFrame;
@synthesize labelArray;
@synthesize requestType;
@synthesize videoItemArray;
@synthesize videoItemType;
@synthesize currentTime;
@synthesize viewLoading;
@synthesize menu;
@synthesize menuButton;
@synthesize settingsViewController;
@synthesize userId;
@synthesize meritNameLabel;
@synthesize isFollowing;
@synthesize rbEmail;
@synthesize commonContentView;
@synthesize commonDescriptionLabel;
@synthesize mainContentView;
@synthesize meritView;
@synthesize followerImageView;
@synthesize followingImageView;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetOffset:) name:@"ProfileViewHide" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCommentItem:) name:@"ProfileAddCommentItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCommentItem:) name:@"ProfileRemoveCommentItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeVideoItem:) name:@"ProfileRemoveVideoItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetProfileImageBlank:) name:@"DeleteProfilePicture" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentItem:) name:@"ProfileShowCommentItem" object:Nil];
    
    settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    sharedInstance = self;
    
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        [self setNotiButton_Red];
    }else {
        [self setNotiButton_Normal];
    }
    
    meritContentView.hidden = YES;
    
    if (userId == Nil) {
        userId = [[UserController instance] userUserID];
        
    }
    
    if ([userId isEqualToString:[[UserController instance] userUserID]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"Profile" forKey:@"currentView"];
        
        [settingsButton setTitle:@"SETTINGS" forState:UIControlStateNormal];
        [settingsButton setTitle:@"SETTINGS" forState:UIControlStateSelected];
        
        followingImageView.hidden = YES;
        followerImageView.hidden = YES;
    }else {
        [[NSUserDefaults standardUserDefaults] setObject:@"ProfileOther" forKey:@"currentView"];
        followerImageView.hidden = NO;
        followingImageView.hidden = NO;
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Profile" forKey:@"SuperController"];
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
//    NSString *lastView = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastView"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Profile" forKey:@"lastView"];
//    if ([lastView isEqualToString:@"Rate"] || [lastView isEqualToString:@"VideoPlay"] || [lastView isEqualToString:@"SearchDetail"] || [lastView isEqualToString:@"Search"]) {
//        return;
//    }
    
    NSString *profileid = [NSString stringWithFormat:@"Profile%@", userId];
    if ([[[AppSharedData sharedInstance] profileHistory] containsObject:profileid]) {
        followingCountLabel.text = [[[AppSharedData sharedInstance] scoreRecord] objectForKey:userId];
        
        if (![[AppSharedData sharedInstance] deleteFlag]) {
            return;
        }else {
            [[AppSharedData sharedInstance] setDeleteFlag:NO];
        }
    }else {
        [[[AppSharedData sharedInstance] profileHistory] addObject:profileid];
    }
    
    
    [[AppSharedData sharedInstance] setDeleteFlag:YES];

    
    categoryItemArray = [[NSMutableArray alloc] init];
    [self setStyle];
    [self setButtonType:3];
    [self requestUserInfo];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (screenSize.height <= 480) {
        [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, 292)];
    }
    
    [videosHomeButton setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0] forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated {
    
//    [activityView removeFromSuperview];
}

#pragma mark - 
#pragma mark Set Style Functions

- (void) setStyle {
    
    commonContentView.hidden = YES;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2 - 90, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
    
    scrollView.userInteractionEnabled = YES;
    scrollView.delegate = self;
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:20.0]];
    [commonDescriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
    [videosHomeButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
    [meritButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
    [videoCountLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:32.0]];
    [followerCountLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:32.0]];
    [followingCountLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:32.0]];
    [settingsButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
    
    [meritUserscoreLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
    [meritUsernameLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
    [meritDescriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
    
    meritFrame = meritScrollView.frame;
    labelArray = [[NSMutableArray alloc] init];
    
    videosHomeButton.titleLabel.highlightedTextColor = [UIColor whiteColor];
    
    //init Video Item Array
    videoItemArray = [[NSMutableArray alloc] init];
    
}

- (void) setButtonType: (int) type {
    
    switch (type) {
        case 1:
            videosHomeButton.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
            [videosHomeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            meritButton.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
            meritButton.titleLabel.textColor = [UIColor whiteColor];
            scrollContainerView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
            videoItemType = LIST_VIDEO_ITEM;
            break;
            
        case 2:
            videosHomeButton.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
            [videosHomeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            meritButton.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
            meritButton.titleLabel.textColor = [UIColor whiteColor];
            scrollContainerView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
            videoItemType = DETAIL_VIDEO_ITEM;
            break;
            
        case 3:
            videosHomeButton.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
            [videosHomeButton setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0] forState:UIControlStateNormal];
            meritButton.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
            scrollContainerView.backgroundColor = [UIColor blackColor];
            videoItemType = MERIT_ITEM;
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark IBAction Functions

- (IBAction)onBackButton:(id)sender {
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *aController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    if ([aController isKindOfClass:[SearchViewController class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"returnSearch"];
    }
    
    if (menu.isOpen) [menu close];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    NSString *profileid = [NSString stringWithFormat:@"Profile%@", userId];
    for (int i = 0; i < [[[AppSharedData sharedInstance] profileHistory] count]; i++) {
        NSString *str = [[[AppSharedData sharedInstance] profileHistory] objectAtIndex:i];
        
        if ([str isEqualToString:profileid]) {
            [[[AppSharedData sharedInstance] profileHistory] removeObjectAtIndex:i];
            break;
        }
    }
}

- (IBAction)onSignOutButton:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    
}

- (IBAction)onVideosCountButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    if (isAnimating) return;
    
    videoItemType = OTHER_ITEM;
    
    [self onVideosListButton:nil];
}

- (IBAction)onFollowersCountButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    if (isAnimating) return;
    
    videoItemType = OTHER_ITEM;
    
    FollowsViewController *followsViewController = [[FollowsViewController alloc] initWithNibName:@"FollowsViewController" bundle:Nil];
    
    [followsViewController setFollowingCount:followingCount];
    [followsViewController setUserid:userId];
    
    [self.navigationController pushViewController:followsViewController animated:YES];
}

- (IBAction)onFollowingCountButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    if (isAnimating) return;
    
    videoItemType = OTHER_ITEM;
    
    FollowingViewController *followingViewController = [[FollowingViewController alloc] initWithNibName:@"FollowingViewController" bundle:Nil];
    
    [followingViewController setUserid:userId];
    [followingViewController setFollowingCount:followingCount];
    
    [self.navigationController pushViewController:followingViewController animated:YES];
}

- (IBAction)onSettingsButton:(id)sender {
    
    if (isAnimating) return;
    
    scrollView.hidden = NO;
    commonContentView.hidden = YES;
    
    if (menu.isOpen) [menu close];
    
    videoItemType = OTHER_ITEM;
    
    
    if ([settingsButton.titleLabel.text isEqualToString:@"SETTINGS"]) {
        
        [settingsViewController setRb_name:rbName];
        [settingsViewController setRb_email:rbEmail];
        [settingsViewController setRb_username:rbUserName];
        
        scrollContainerView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        
        [self clearScrollView];
        
        [settingsViewController.view setFrame:CGRectMake(0, 0, settingsViewController.view.frame.size.width, settingsViewController.view.frame.size.height)];
        
        [scrollView addSubview:settingsViewController.view];
        
        [scrollView setContentSize:CGSizeMake(settingsViewController.view.frame.size.width, settingsViewController.view.frame.size.height)];
    }else if([settingsButton.titleLabel.text isEqualToString:@"FOLLOW"]) {
        [self requestFollowSetting:@"FOLLOW"];
    }else {
        [self requestFollowSetting:@"UNFOLLOW"];
    }
}

- (IBAction)onVideosHomeButton:(id)sender {
    
    if (isAnimating) return;
    
    [videosHomeButton.titleLabel setTextColor:[UIColor whiteColor]];
    
    scrollView.hidden = NO;
    commonContentView.hidden = YES;
    
    if (menu.isOpen) [menu close];
    
    [self clearScrollView];
    [self setButtonType:1];
    [self resetCntValues];
    [self requestCurrentTime];
    
}

- (IBAction)onVideosListButton:(id)sender {
    
    videosDetailButton.hidden = NO;
    videosListButton.hidden = YES;
    
    if (isAnimating) return;
    
    scrollView.hidden = NO;
    commonContentView.hidden = YES;
    
    [videosHomeButton.titleLabel setTextColor:[UIColor whiteColor]];
    
    if (menu.isOpen) [menu close];

    [self clearScrollView];
    [self setButtonType:1];
    [self resetCntValues];
    [self requestCurrentTime];
    
}

- (IBAction)onVideosDetailButton:(id)sender {
    
    videosDetailButton.hidden = YES;
    videosListButton.hidden = NO;
    
    if (isAnimating) return;
    
    scrollView.hidden = NO;
    commonContentView.hidden = YES;
    
    if (menu.isOpen) [menu close];
    
    [self clearScrollView];
    [self setButtonType:2];
    [self resetCntValues];
    [self requestCurrentTime];
    
}

- (IBAction)onMeritButton:(id)sender {
    
    if (isAnimating) return;
    
    if (menu.isOpen) [menu close];
    
    scrollView.hidden = NO;
    commonContentView.hidden = YES;

    [self clearScrollView];
    [self setButtonType:3];
    [scrollView addSubview:meritView.view];
    [scrollView setContentSize:CGSizeMake(320, meritView.view.frame.size.height)];
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

- (IBAction)onPhotoViewButton:(id)sender {
    [EXPhotoViewer showImageFrom:profileImageView];
}

#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    
    isAnimating = YES;
    
    for (UIView *child in scrollView.subviews) {
        child.userInteractionEnabled = FALSE;
    }

    scrollView.scrollEnabled = YES;
    [activityView startAnimation];

    
    [viewLoading bringSubviewToFront:activityView];
    
    viewLoading.hidden = NO;
    viewLoading.alpha = 1;
}

- (void)endLoading{
    
    isAnimating = NO;
    
    for (UIView *child in scrollView.subviews) {
        child.userInteractionEnabled = TRUE;
    }

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
#pragma mark Request Functions

- (void) requestFollowSetting:(NSString *) type  {
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SET_FOLLOW_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_FOLLOWINGID, userId,
                      TAG_REQ_TYPE, type];
    
    
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
    
    requestType = REQUEST_FOR_FOLLOW;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestUserInfo {
    
    scrollView.hidden = NO;
    commonContentView.hidden = YES;
    
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_USER_PROFILE_INFO_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@",
                      TAG_REQ_USERID, userId,
                      TAG_REQ_CURRENTUSERID, [[UserController instance] userUserID]];
    
    
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
    
    requestType = REQUEST_FOR_MERIT;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestVideoItem {
    
    scrollView.hidden = NO;
    commonContentView.hidden = YES;
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_VIDEOLIST_BYUSER_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu",
                      TAG_REQ_USERID, userId,
                      TAG_REQ_CNTLOADED, (unsigned long) cntLoaded,
                      TAG_REQ_CURRENTTIME, currentTime,
                      TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLazyLoad];
    
    
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
    requestType = REQUEST_FOR_VIDEOLIST;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestCurrentTime {
    
    scrollView.hidden = NO;
    commonContentView.hidden = YES;
    
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
    
    dict = (NSDictionary*)[jsonParser objectWithString:text];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    NSMutableArray *categoryList;
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:REQUEST_FOR_MERIT]) {
            
            videoCountLabel.text = [dict objectForKey:TAG_RES_CNTVIDEOS];
            [videosHomeButton setTitle:[NSString stringWithFormat:@"Videos (%@)", [dict objectForKey:TAG_RES_CNTVIDEOS]] forState:UIControlStateNormal];
            [videosHomeButton setTitle:[NSString stringWithFormat:@"Videos (%@)", [dict objectForKey:TAG_RES_CNTVIDEOS]] forState:UIControlStateSelected];
            followerCountLabel.text = [dict objectForKey:TAG_RES_CNTFOLLOWERS];
            followingCountLabel.text = [dict objectForKey:TAG_RES_CNTFOLLOWING];
            
            [[[AppSharedData sharedInstance] scoreRecord] setObject:followingCountLabel.text forKey:userId];
            
            followingCount = [followingCountLabel.text intValue];
            
            NSString *userPhotoUrl = [dict objectForKey:TAG_RES_PHOTO];
            
            //Save user profile image url in NSUserDefaults to use in Upload Picture
            [[NSUserDefaults standardUserDefaults] setObject:userPhotoUrl forKey:@"UserPhotoUrl"];
            
            UIImage *pImage;
            if ([userPhotoUrl isEqualToString:@""]) {
                pImage = [UIImage imageNamed:@"profileImage.png"];
                [profileImageView setImage:pImage];
            }else{
                pImage = [[[AppSharedData sharedInstance] storeImage] objectForKey:userPhotoUrl];
                
                if (pImage == nil) {
                    
                    NSURL *url = [NSURL URLWithString:userPhotoUrl];
                    
                    AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:url] success:^(UIImage *image) {
                        
                        [profileImageView setImage:image];
                        
//                        [[[AppSharedData sharedInstance] storeImage] setObject:image forKey:userPhotoUrl];
                        //[activityIndicator removeFromSuperview];
                        
                    }];
                    
                    
                    [imageOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
                     {
                         float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
                         NSLog(@"UserProfileImage ---------------- PROGRESS - %f -------- %f ---------- %lld", progress, (float)totalBytesRead, totalBytesExpectedToRead); //Can be deleted once the progress bar works.
                         
                     }];
                    
                    
                    //        [httpClient enqueueHTTPRequestOperation:imageOperation];
                    
                    [[MTHTTPClient sharedClient] enqueueHTTPRequestOperation:imageOperation];
                }else {
                    [profileImageView setImage:pImage];
                }
            }
            
            
            categoryList = [dict objectForKey:TAG_RES_CATEGORYLIST];
            
            for (int i = 0; i < [categoryList count]; i++) {
                NSDictionary *rdict = [categoryList objectAtIndex:i];
                
                categoryIteminfo *item = [[categoryIteminfo alloc] init];
                
                item.rbHashtag = [rdict objectForKey:TAG_RES_RB_HASHTAG];
                
                NSString *scoreStr = [rdict objectForKey:TAG_RES_SCORE];
                
                if ([scoreStr isEqual:[NSNull null]]) {
                    scoreStr = @"0";
                }
                item.score = [scoreStr floatValue];
                
                [categoryItemArray addObject:item];
            }
            
            rbUserName = [dict objectForKey:TAG_RES_RB_USERNAME];
            rbCred = [dict objectForKey:TAG_RES_RB_CRED];
            rbName = [dict objectForKey:TAG_RES_RB_NAME];
            isFollowing = [dict objectForKey:TAG_RES_ISFOLLOWING];
            rbEmail = [dict objectForKey:TAG_RES_RB_EMAIL];
            
            [self endLoading];
            
            [self clearScrollView];
            
            meritView = [[MeritViewController alloc] init];
            [meritView setData:dict];
//            [meritView viewWillAppear:YES];
            meritView.view.frame = CGRectMake(meritContentView.frame.origin.x, meritContentView.frame.origin.y, meritView.view.frame.size.width, meritView.view.frame.size.height);
            [scrollView addSubview:meritView.view];
            [scrollView setContentSize:CGSizeMake(320, meritView.view.frame.size.height)];
            
            if (![userId isEqualToString:[[UserController instance] userUserID]]) {
                if ([isFollowing isEqualToString:@"N"]) {
                    [settingsButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
                    [settingsButton setTitle:@"FOLLOW" forState:UIControlStateSelected];
                }else {
                    [settingsButton setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
                    [settingsButton setTitle:@"UNFOLLOW" forState:UIControlStateSelected];
                }
                
                isFollowing = [dict objectForKey:TAG_RES_ISFOLLOWING];
                
                if ([isFollowing isEqualToString:@"Y"]) {
                    [followingImageView setImage:[UIImage imageNamed:@"leftRedArrow.png"]];
                }else {
                    [followingImageView setImage:[UIImage imageNamed:@"leftWhiteArrow.png"]];
                }
                
                NSString *isFollower = [dict objectForKey:TAG_RES_ISFOLLOWER];
                
                if ([isFollower isEqualToString:@"Y"]) {
                    [followerImageView setImage:[UIImage imageNamed:@"redRightArrow.png"]];
                }else {
                    [followerImageView setImage:[UIImage imageNamed:@"rightWhiteArrow.png"]];
                }
            }
            
            
//            [self applyMeritValue];
            
        }else if ([requestType isEqualToString:REQUEST_FOR_VIDEOLIST]) {
        
            NSMutableArray *videoListArray;
            
            videoListArray = [dict objectForKey:TAG_RES_VIDEOLIST];
            
            if ([videoListArray count] == 0 && cntLoaded == 0) {
                scrollView.hidden = YES;
                commonContentView.hidden = NO;
                commonDescriptionLabel.text = @"This user has not uploaded any Videos.";
            }else {
                scrollView.hidden = NO;
                commonContentView.hidden = YES;
            }
            
            if ([videoItemType isEqualToString:DETAIL_VIDEO_ITEM]) {
                for (int i = 0; i < [videoListArray count]; i++) {
                    NSDictionary *dict1 = [videoListArray objectAtIndex:i];
                    
                    RBVideoViewController *rbVC = [[RBVideoViewController alloc] initWithNibName:@"RBVideoViewController" bundle:Nil];
                    
                    [rbVC setData:dict1];
                    [rbVC setNumber:cntLoaded];
                    //                [rbVC viewWillAppear:YES];
                    rbVC.view.frame = CGRectMake(6, startY, rbVC.view.frame.size.width, rbVC.view.frame.size.height);
                    
                    //                    rbVC.view.layer.masksToBounds = NO;
                    //                    rbVC.view.layer.cornerRadius = 0; // if you like rounded corners
                    //                    rbVC.view.layer.shadowOffset = CGSizeMake(1, 1);
                    //                    rbVC.view.layer.shadowRadius = 1;
                    //                    rbVC.view.layer.shadowOpacity = 0.5;
                    
                    
                    [videoItemArray addObject:rbVC];
                    
                    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:[videoItemArray count] - 1];
                    
                    [self.scrollView addSubview:vc.view];
                    
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
                    
                    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:[videoItemArray count] - 1];
                    
                    [self.scrollView addSubview:vc.view];
                    
                    startY += rbVC.view.frame.size.height + stepY;
                    
                    cntLoaded ++;
                    
                }
                
                if ([videoListArray count] != 0 && cntLoaded > cntLazyLoad) {
                    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 20) animated:YES];
                }
                
                
                scrollView.contentSize = CGSizeMake(320, startY);
            }
            
            [self endLoading];
        } else if ([requestType isEqualToString:REQUEST_FOR_GETTIME]) {
            currentTime = [dict objectForKey:TAG_RES_CURRENTTIME];
            
            if ([videoItemType isEqualToString:MERIT_ITEM]) {
//                [self requestUserList];
            }else {
                [self requestVideoItem];
            }
        }else if ([requestType isEqualToString:REQUEST_FOR_FOLLOW]) {
            [self endLoading];
            if ([settingsButton.titleLabel.text isEqualToString:@"FOLLOW"]) {
                [settingsButton setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
                [settingsButton setTitle:@"UNFOLLOW" forState:UIControlStateSelected];
                
                int cf = [followerCountLabel.text intValue];
                [followerCountLabel setText:[NSString stringWithFormat:@"%d", cf + 1]];
                [followingImageView setImage:[UIImage imageNamed:@"leftRedArrow.png"]];
                
            }else {
                [settingsButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
                [settingsButton setTitle:@"FOLLOW" forState:UIControlStateSelected];
                int cf = [followerCountLabel.text intValue];
                [followerCountLabel setText:[NSString stringWithFormat:@"%d", cf - 1]];
                
                [followingImageView setImage:[UIImage imageNamed:@"leftWhiteArrow.png"]];
                
            }
        }
        
        
    }else {
        [self endLoading];
//        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
//        if ([errorMsg isEqualToString:@""]) {
//            return;
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
//        [alert show];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    [self endLoading];
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

#pragma mark-
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [alertView cancelButtonIndex]) {
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:Nil];
        
        UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:welcomeViewController animated:NO];
        
    }
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - 
#pragma mark applyMeritValue

- (void) applyMeritValue {
    
    if ([rbCred isEqual:[NSNull null]]) {
        rbCred = @"0";
    }
    
    float userscore = [rbCred floatValue];
    
    [self changeMeritUserscoreImageView: userscore];
    
    if (![userId isEqualToString:[[UserController instance] userUserID]]) {
        if ([isFollowing isEqualToString:@"N"]) {
            [settingsButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
            [settingsButton setTitle:@"FOLLOW" forState:UIControlStateSelected];
        }else {
            [settingsButton setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
            [settingsButton setTitle:@"UNFOLLOW" forState:UIControlStateSelected];
        }
    }
    
    if (![rbName isEqual:[NSNull null]] && ![rbName isEqualToString:@""]) {
        meritNameLabel.text = rbName;
    }
    
    
    if ([meritNameLabel.text isEqualToString:@""]) {
        meritUsernameLabel.center = CGPointMake(meritUsernameLabel.center.x, 37);
        meritUserscoreImageView.center = CGPointMake(meritUserscoreImageView.center.x, 139);
        meritUserscoreLabel.center = CGPointMake(meritUserscoreLabel.center.x, 139);
        meritDescriptionLabel.center = CGPointMake(meritDescriptionLabel.center.x, 230);
    }
    
    for (int i = 0; i < [labelArray count]; i++) {
        UILabel *child = (UILabel *)[labelArray objectAtIndex:i];
        [child removeFromSuperview];
    }
    
    [labelArray removeAllObjects];
    
    meritUsernameLabel.text = [NSString stringWithFormat:@"@%@", rbUserName];
    
    if (![rbCred isEqual:[NSNull null]]) {
        meritUserscoreLabel.text = [NSString stringWithFormat:@"%.2f", [rbCred floatValue]];
    }

    
    int sy = 285;
    if ([meritNameLabel.text isEqualToString:@""]) {
        sy = 270;
    }
    
    for (int i = 0; i < [categoryItemArray count]; i++) {
        categoryIteminfo *item = [categoryItemArray objectAtIndex:i];
        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, sy, 300, 0)];
//        label.text = [NSString stringWithFormat:@"#%@ = %.2f", item.rbHashtag, item.score];
//        [label setTextColor:[UIColor whiteColor]];
//        [label setBackgroundColor:[UIColor clearColor]];
//        label.textAlignment = NSTextAlignmentCenter;
//        [label adjustHeight];
//        [label setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
        
        IFTweetLabel *label = [[IFTweetLabel alloc] initWithFrame:CGRectMake(10, sy, 300, 20)];
        label.text = [NSString stringWithFormat:@"#%@ = %.2f", item.rbHashtag, item.score];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setButtonFontColor:[UIColor redColor]];
        [label setFont:[UIFont fontWithName:CUSTOM_FONT size:17.f]];
        [label setButtonFontSize:17.f];
        label.linksEnabled = YES;
//        label.label.textAlignment = NSTextAlignmentCenter;
        
        
        [labelArray addObject:label];
        IFTweetLabel *rlabel = [labelArray objectAtIndex:i];
        
        [meritContentView addSubview:rlabel];
        sy += label.frame.size.height + 15;
        
        

        
    }
    
    [meritContentView setFrame:CGRectMake(0, 0, meritFrame.size.width, sy + 20)];
    
    meritFrame = meritContentView.frame;
    
    [self clearScrollView];
    [scrollView addSubview:meritContentView];
    [scrollView setContentSize:CGSizeMake(320, meritFrame.size.height)];
}

- (void) clearScrollView {
    
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
    }
}


#pragma mark -
#pragma mark NSNotification Center Functions
- (void)resetOffset:(NSNotification *)notification {
    
    float currentPosition = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPosition"] floatValue];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    float stY;
    
    if (screenSize.height > 480) {
        stY = currentPosition - (screenSize.height - 220);
    }else {
        stY = currentPosition - (screenSize.height - 200);
    }
    
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + stY) animated:YES];
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
    
    for (int i = number + 1; i < [videoItemArray count]; i++) {
        RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
        [vc.view setCenter:CGPointMake(vc.view.center.x, vc.view.center.y + iheight)];
    }
    
    [self.scrollView setNeedsDisplay];
    
    startY += iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
}

- (void) removeCommentItem: (NSNotification *) notificaiton {
    
    int videoNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
    int commentNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveCommentNumber"] intValue];
    
    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:videoNumber];
    
    float iheight = [vc removeCommentItem:commentNumber];
    
    for (int i = videoNumber + 1; i < [videoItemArray count]; i++) {
        RBVideoViewController *cvc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
        [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
    }
    
    
    [self.scrollView setNeedsDisplay];
    
    startY -= iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
}

- (void) removeVideoItem{
    int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
    
    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:number];
    
    float iheight = vc.view.frame.size.height + 6;
    
    [vc.view removeFromSuperview];
    
    for (int i = number + 1; i < [videoItemArray count]; i++) {
        RBVideoViewController *cvc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
        [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
    }
    
    [videoItemArray removeObjectAtIndex:number];
    [self.scrollView setNeedsDisplay];
    
    startY -= iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
    
    [videosHomeButton setTitle:[NSString stringWithFormat:@"Videos (%lu)", (unsigned long)[videoItemArray count]] forState:UIControlStateNormal];
    [videosHomeButton setTitle:[NSString stringWithFormat:@"Videos (%lu)", (unsigned long)[videoItemArray count]] forState:UIControlStateHighlighted];
    
    [self startLoading];
    [self requestVideoItem];
}

- (void) removeVideoItem: (NSNotification *) notification {
    
    int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
    
    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:number];
    
    float iheight = vc.view.frame.size.height + 6;
    
    [vc.view removeFromSuperview];
    
    for (int i = number + 1; i < [videoItemArray count]; i++) {
        RBVideoViewController *cvc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
        [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
    }
    
    [videoItemArray removeObjectAtIndex:number];
    [self.scrollView setNeedsDisplay];
    
    startY -= iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
    
    [self startLoading];
    [self requestVideoItem];
}

- (void) showCommentItem: (NSNotification *) notification {
    
    int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowCommentViewNumber"] intValue];
    
    int iheight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowCommentIncreaseHeight"] intValue];
    
    for (int i = number + 1; i < [videoItemArray count]; i++) {
        RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
        [vc.view setCenter:CGPointMake(vc.view.center.x, vc.view.center.y + iheight)];
    }
    
    [self.scrollView setNeedsDisplay];
    
    startY += iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
}

- (void) resetProfileImageBlank: (NSNotification *) notification {
    
    UIImage *pImage;
    pImage = [UIImage imageNamed:@"profileImage.png"];
    [profileImageView setImage:pImage];
}


#pragma mark -
#pragma mark Change the User Score Image View

- (void) changeMeritUserscoreImageView: (float) videoScore {
    
    int score = (int) videoScore;
    
    float mv = videoScore - (float) score;
    
    if (mv >= 0.5) {
        score ++;
    }
    
    switch (score) {
        case 0:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed0.png"]];
            break;
            
        case 1:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed1.png"]];
            break;
            
        case 2:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed2.png"]];
            break;
            
        case 3:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed3.png"]];
            break;
            
        case 4:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed4.png"]];
            break;
            
        case 5:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed5.png"]];
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
        
        if (![videoItemType isEqualToString:MERIT_ITEM] && ![videoItemType isEqualToString:OTHER_ITEM] && !isAnimating) {
            [self startLoading];
            [self requestVideoItem];
        }
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
    
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, screenRect.size.height - 175)];
}

+(ProfileViewController *) sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}


- (void) setNotiButton_Red {
    [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
}
- (void) setNotiButton_Normal {
    [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
}


@end
