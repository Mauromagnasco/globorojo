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

#import "SearchViewController.h"
#import "Constants.h"
#import "SBJson.h"
#import "UserController.h"
#import "RBVideoViewController.h"
#import "CommentViewController.h"
#import "RBVideoListViewController.h"
#import "RBUserListViewController.h"
#import "AppDelegate.h"
#import "AppSharedData.h"
#import "HomeViewController.h"
#import "CreateVideoItemViewController.h"
#import "MTDropDownView.h"
#import "MarkDropDownView.h"
#import "MTHTTPClient.h"
#import "AFHTTPRequestOperation.h"

#define REQUEST_FOR_GETTIME             @"time"
#define REQUEST_FOR_VIDEOITEM           @"video"
#define REQUEST_FOR_REFRESH_GETTIME     @"refreshtime"
#define REQUEST_FOR_USERLIST            @"user"
#define REQUEST_FOR_REFRESH_USERITEM    @"refreshuser"
#define LIST_VIDEO_ITEM                 @"list"
#define DETAIL_VIDEO_ITEM               @"detail"
#define USER_VIDEO_ITEM                 @"user"
#define REQUEST_FOR_NOTIFICATION        @"notification"
#define REQUEST_FOR_REFRESH_VIDEOITEM   @"refreshVideo"
#define REQUEST_FOR_UPDATE              @"requestUpdateInfo"

#define BIG_STATE                       @"big"
#define SMALL_STATE                     @"small"

@interface SearchViewController ()

@end

@implementation SearchViewController

static SearchViewController *sharedInstance = nil;

@synthesize searchTextField;
@synthesize hashtagDetailButton;
@synthesize hashtagHomeButton;
@synthesize hashtagListButton;
@synthesize usernameButton;
@synthesize segmentContainerView;
@synthesize scrollView;
@synthesize scrollContainerView;
@synthesize dmenu;
@synthesize menuArray;

@synthesize segmentedControl;
@synthesize orderType;
@synthesize activityView;
@synthesize videoItemArray;
@synthesize recvData;
@synthesize currentTime;
@synthesize requestType;
@synthesize viewLoading;
@synthesize videoItemType;
@synthesize searchText;
@synthesize menu;
@synthesize menuButton;
@synthesize descriptionContentView;
@synthesize descriptionLabel;
@synthesize mainContentView;
@synthesize userSegmentedControl;
@synthesize arrow;
@synthesize smenu;
@synthesize userOrderType;
@synthesize heightArray;
@synthesize swipeButton;
@synthesize currentWatchState;

@synthesize hashDateOrderButton;
@synthesize hashMeritOrderButton;
@synthesize hashScoreOrderButton;
@synthesize nameAlphaOrderButton;
@synthesize nameDateOrderButton;
@synthesize nameMeritOrderButton;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetOffset:) name:@"SearchViewHide" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCommentItem:) name:@"SearchAddCommentItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCommentItem:) name:@"SearchRemoveCommentItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeVideoItem:) name:@"SearchRemoveVideoItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentItem:) name:@"SearchShowCommentItem" object:Nil];
    
    
    downHashDate = YES;
    downHashMerit = YES;
    downHashScore = YES;
    downNameAlpha = NO;
    downNameData = YES;
    downNameMerit = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showDropView_Everyone {
    [MarkDropDownView showDropDownViewInView:self.view text:@"You are watching: Everyone" animated:YES target:self selector:nil hideAfter:5];
}

- (void) showDropView_Follow {
    [MarkDropDownView showDropDownViewInView:self.view text:@"You are watching: People you follow" animated:YES target:self selector:nil hideAfter:5];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (currentWatchState == nil) {
        currentWatchState = BIG_STATE;
        [swipeButton setBackgroundImage:[UIImage imageNamed:@"btnBigWatch.png"] forState:UIControlStateNormal];
    }
    
    if ([currentWatchState isEqualToString:BIG_STATE]) {
        [self performSelectorOnMainThread:@selector(showDropView_Everyone) withObject:nil waitUntilDone:NO];
    }else {
        [self performSelectorOnMainThread:@selector(showDropView_Follow) withObject:nil waitUntilDone:NO];
    }
    
    sharedInstance = self;
    
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        [self setNotiButton_Red];
    }else {
        [self setNotiButton_Normal];
    }
    
    isAnimating = NO;
    
    descriptionContentView.hidden = YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Search" forKey:@"SuperController"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Search" forKey:@"currentView"];
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    smenu = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).smenu;
    [smenu setSelectedNumber:3];
    
    if (searchText == nil) {
        searchTextField.text = @"";
    }else {
        searchTextField.text = searchText;
    }
    
    searchTextField.delegate = self;
    [searchTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    arrow = [[CollapseClickArrow alloc] initWithFrame:CGRectMake(190, 18, 7, 7)];
    [arrow setBackgroundColor:[UIColor clearColor]];
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
    arrow.transform = transform;
    [arrow drawWithColor:[UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1]];
    
    NSString *lastView = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastView"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Search" forKey:@"lastView"];
    if (([lastView isEqualToString:@"Rate"] || [lastView isEqualToString:@"VideoPlay"] || [lastView isEqualToString:@"Home"] || [lastView isEqualToString:@"Profile"] || [lastView isEqualToString:@"Notification"] || [lastView isEqualToString:@"ShareVideo"] || [lastView isEqualToString:@"DeleteVideo"] || [lastView isEqualToString:@"SearchDetail"] ||[lastView isEqualToString:@"CreateVideo"]) && [videoItemArray count] > 0) {
        
        [self requestRefreshCurrentTime];
        return;
    }
    
    for (UIView *child in scrollView.subviews) {
        [child removeFromSuperview];
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
    orderType = 0;
    userOrderType = 0;
    
    hashtagListButton.hidden = YES;
    hashtagDetailButton.hidden = NO;
    
    [self initMenuArray];
    [self clearScrollView];
    [self setButtonType:1];
    [self setScrollContainerFrame:1];
    [self resetCntValues];
    [self requestCurrentTime];
    
}


- (void) initMenuArray {
    
    menuArray = [NSMutableArray array];
    
    for (int i = 0; i < 2; i++) {
        REMenu *fmenu = [[REMenu alloc] init];
        fmenu.itemHeight = 40;
        fmenu.startNumber = 1;
        fmenu.waitUntilAnimationIsComplete = YES;
        fmenu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
            badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
            badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
        };
        
        [menuArray addObject:fmenu];
    }
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

#pragma mark -
#pragma mark Set Style Functions

- (void) setStyle {
    
    //
    self.segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0,0, 320, 35)];
    [self.segmentedControl setSectionTitles:@[@"Date", @"Score", @"Meri.to"]];
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1]];
    [self.segmentedControl setTextColor:[UIColor whiteColor]];
    [self.segmentedControl setSelectedTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self.segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0]];
    [self.segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [self.segmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationUp];
    [self.segmentedControl setTag:3];
    [segmentContainerView addSubview:segmentedControl];
    
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        //        [weakSelf.scrollView scrollRectToVisible:CGRectMake(320 * index, 0, 320, 200) animated:YES];
        self.orderType = index;
        
        [searchTextField resignFirstResponder];
        
        if (smenu.isOpen) [smenu close];
        
        [self clearScrollView];
        [self resetCntValues];
        [self requestCurrentTime];
    }];
    
    
    //set User search segmented control
    self.userSegmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0,0, 320, 35)];
    [self.userSegmentedControl setSectionTitles:@[@"Date", @"A - Z", @"Meri.to"]];
    [self.userSegmentedControl setSelectedSegmentIndex:0];
    [self.userSegmentedControl setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1]];
    [self.userSegmentedControl setTextColor:[UIColor whiteColor]];
    [self.userSegmentedControl setSelectedTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self.userSegmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0]];
    [self.userSegmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [self.userSegmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationUp];
    [self.userSegmentedControl setTag:3];
    
    [self.userSegmentedControl setIndexChangeBlock:^(NSInteger index) {
        //        [weakSelf.scrollView scrollRectToVisible:CGRectMake(320 * index, 0, 320, 200) animated:YES];
        self.userOrderType = index;
        
        if (smenu.isOpen) [smenu close];
        
        [searchTextField resignFirstResponder];
        
        [self clearScrollView];
        [self resetCntValues];
        [self requestCurrentTime];
    }];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2 - 45, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
    
    //set Font
    [searchTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
    searchTextField.delegate = self;
    [descriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:18.0]];
    
    //init Video Item Array
    videoItemArray = [[NSMutableArray alloc] init];
    heightArray = [[NSMutableArray alloc] init];
    
    
    //set ScrollView Delegate
    scrollView.userInteractionEnabled = YES;
    scrollView.delegate = self;
    
    [searchTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
    [hashtagHomeButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
    [usernameButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
    
}

- (void) setScrollContainerFrame: (int) type {
  
    if (type == 1) {
        [self.userSegmentedControl removeFromSuperview];
        [self.segmentContainerView addSubview:segmentedControl];
//        [self.segmentContainerView addSubview:arrow];
        
        [hashMeritOrderButton setHidden:NO];
        [hashDateOrderButton setHidden:NO];
        [hashScoreOrderButton setHidden:NO];
        [nameAlphaOrderButton setHidden:YES];
        [nameDateOrderButton setHidden:YES];
        [nameMeritOrderButton setHidden:YES];
        
        [searchTextField setPlaceholder:@"Search #category"];
        
    }else {
        [self.segmentedControl removeFromSuperview];
//        [arrow removeFromSuperview];
        [self.segmentContainerView addSubview:userSegmentedControl];
        
        [hashMeritOrderButton setHidden:YES];
        [hashDateOrderButton setHidden:YES];
        [hashScoreOrderButton setHidden:YES];
        [nameAlphaOrderButton setHidden:NO];
        [nameDateOrderButton setHidden:NO];
        [nameMeritOrderButton setHidden:NO];
        
        [searchTextField setPlaceholder:@"Search @username"];
    }
    
    [self.segmentContainerView bringSubviewToFront:hashScoreOrderButton];
    [segmentContainerView bringSubviewToFront:hashDateOrderButton];
    [segmentContainerView bringSubviewToFront:hashMeritOrderButton];
    [segmentContainerView bringSubviewToFront:nameMeritOrderButton];
    [segmentContainerView bringSubviewToFront:nameDateOrderButton];
    [segmentContainerView bringSubviewToFront:nameAlphaOrderButton];
}

- (void) setButtonType: (int) type {
    if (type == 1) {
        hashtagHomeButton.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
        hashtagHomeButton.titleLabel.textColor = [UIColor whiteColor];
        
//        [hashtagListButton setBackgroundImage:[UIImage imageNamed:@"btnListRed.png"] forState:UIControlStateNormal];
//        [hashtagDetailButton setBackgroundImage:[UIImage imageNamed:@"btnDetailGrey.png"] forState:UIControlStateNormal];
        
//        hashtagListButton.hidden = YES;
//        hashtagDetailButton.hidden = NO;
        
        usernameButton.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        usernameButton.titleLabel.textColor = [UIColor whiteColor];
        videoItemType = LIST_VIDEO_ITEM;
    }else if (type == 2) {
        hashtagHomeButton.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
        hashtagHomeButton.titleLabel.textColor = [UIColor whiteColor];
        
//        [hashtagListButton setBackgroundImage:[UIImage imageNamed:@"btnListGrey.png"] forState:UIControlStateNormal];
//        [hashtagDetailButton setBackgroundImage:[UIImage imageNamed:@"btnDetailRed.png"] forState:UIControlStateNormal];
        
        usernameButton.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        usernameButton.titleLabel.textColor = [UIColor whiteColor];
        videoItemType = DETAIL_VIDEO_ITEM;
    }else {
        hashtagHomeButton.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
        hashtagHomeButton.titleLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
//        [hashtagListButton setBackgroundImage:[UIImage imageNamed:@"btnListGrey.png"] forState:UIControlStateNormal];
//        [hashtagDetailButton setBackgroundImage:[UIImage imageNamed:@"btnDetailGrey.png"] forState:UIControlStateNormal];
        usernameButton.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
        usernameButton.titleLabel.textColor = [UIColor whiteColor];
        videoItemType = USER_VIDEO_ITEM;
    }
    
    heightArray = [NSMutableArray array];
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
#pragma mark IBAction Functions

- (IBAction)onDeleteTextButton:(id)sender {
    
    [self closeMenu];
   
    searchTextField.text = @"";
    
    searchText = searchTextField.text;
    [searchTextField resignFirstResponder];
    [self resetCntValues];
    
    [self performSelectorOnMainThread:@selector(requestCurrentTime) withObject:nil waitUntilDone:YES];
}

- (IBAction)onBackButton:(id)sender {
    
    [self closeMenu];
    
    [searchTextField resignFirstResponder];
    
    if ([currentWatchState isEqualToString:BIG_STATE]) {
        currentWatchState = SMALL_STATE;
        [swipeButton setBackgroundImage:[UIImage imageNamed:@"btnSmallWatch.png"] forState:UIControlStateNormal];
    }else {
        currentWatchState = BIG_STATE;
        [swipeButton setBackgroundImage:[UIImage imageNamed:@"btnBigWatch.png"] forState:UIControlStateNormal];
    }
    
    if ([currentWatchState isEqualToString:BIG_STATE]) {
        [self performSelectorOnMainThread:@selector(showDropView_Everyone) withObject:nil waitUntilDone:NO];
    }else {
        [self performSelectorOnMainThread:@selector(showDropView_Follow) withObject:nil waitUntilDone:NO];
    }
    
    [self.segmentedControl setSelectedSegmentIndex:0];
    self.orderType = 0;
    [self.userSegmentedControl setSelectedSegmentIndex:0];
    self.userOrderType = 0;
    
    
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onSearchButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    [self closeMenu];
    
    searchText = searchTextField.text;
    [searchTextField resignFirstResponder];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onHashtagHomeButton:(id)sender {
    
    [searchTextField resignFirstResponder];
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    [self closeMenu];
    
    if (isAnimating) {
        return;
    }
    
    searchText = searchTextField.text;
    
    [self setButtonType:1];
    [self setScrollContainerFrame:1];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
    
}

- (IBAction)onHashtagListButton:(id)sender {
    
    hashtagDetailButton.hidden = NO;
    hashtagListButton.hidden = YES;
    
    [searchTextField resignFirstResponder];
    
    if (isAnimating) {
        return;
    }
    
    searchText = searchTextField.text;
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    [self closeMenu];
    
    [self setButtonType:1];
    [self setScrollContainerFrame:1];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
    
}

- (IBAction)onHashtagDetailButton:(id)sender {
    
    hashtagDetailButton.hidden = YES;
    hashtagListButton.hidden = NO;
    
    [searchTextField resignFirstResponder];
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    [self closeMenu];
    
    if (isAnimating) {
        return;
    }
    
    searchText = searchTextField.text;
    
    [self setButtonType:2];
    [self setScrollContainerFrame:1];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
    
}

- (IBAction)onUsernameButton:(id)sender {
    
    [searchTextField resignFirstResponder];
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    [self closeMenu];
    
    searchText = searchTextField.text;
    
    [self setButtonType:3];
    [self setScrollContainerFrame:2];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
    
}
- (IBAction)onAddVideoButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    [self closeMenu];
    
    CreateVideoItemViewController *createVideoViewController = [[CreateVideoItemViewController alloc] initWithNibName:@"CreateVideoItemViewController" bundle:nil];
    
    [self.navigationController pushViewController:createVideoViewController animated:YES];
}

- (IBAction)onHashDateOrderButton:(id)sender {
    
    [self closeMenu];
    
    if (self.orderType != 0) {
        return;
    }
    
    downHashDate = !downHashDate;
    
    if (downHashDate) {
        [hashDateOrderButton setBackgroundImage:[UIImage imageNamed:@"orderDownArrow.png"] forState:UIControlStateNormal];
    }else {
        [hashDateOrderButton setBackgroundImage:[UIImage imageNamed:@"orderUpArrow.png"] forState:UIControlStateNormal];
    }
    
    searchText = searchTextField.text;
    
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onHashScoreOrderButton:(id)sender {
    [self closeMenu];
    
    if (self.orderType != 1) {
        return;
    }
    
    [self showSmallMenu];
}

- (IBAction)onHashMeritOrderButton:(id)sender {
    
    [self closeMenu];
    
    if (self.orderType != 2) {
        return;
    }

    downHashMerit = !downHashMerit;
    
    if (downHashMerit) {
        [hashMeritOrderButton setBackgroundImage:[UIImage imageNamed:@"orderDownArrow.png"] forState:UIControlStateNormal];
    }else {
        [hashMeritOrderButton setBackgroundImage:[UIImage imageNamed:@"orderUpArrow.png"] forState:UIControlStateNormal];
    }
    
    searchText = searchTextField.text;
    
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onNameDateOrderButton:(id)sender {
    
    [self closeMenu];
    
    if (self.userOrderType != 0) {
        return;
    }
    
    downNameData = !downNameData;
    
    if (downNameData) {
        [nameDateOrderButton setBackgroundImage:[UIImage imageNamed:@"orderDownArrow.png"] forState:UIControlStateNormal];
    }else {
        [nameDateOrderButton setBackgroundImage:[UIImage imageNamed:@"orderUpArrow.png"] forState:UIControlStateNormal];
    }
    
    searchText = searchTextField.text;
    
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onNameAlphaOrderButton:(id)sender {
    
    [self closeMenu];
    
    if (self.userOrderType != 1) {
        return;
    }
    
    downNameAlpha = !downNameAlpha;
    
    if (downNameAlpha) {
        [nameAlphaOrderButton setBackgroundImage:[UIImage imageNamed:@"orderDownArrow.png"] forState:UIControlStateNormal];
    }else {
        [nameAlphaOrderButton setBackgroundImage:[UIImage imageNamed:@"orderUpArrow.png"] forState:UIControlStateNormal];
    
    }
    
    searchText = searchTextField.text;
    
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onNameMeritOrderButton:(id)sender {
    
    [self closeMenu];
    
    if (self.userOrderType != 2) {
        return;
    }
    
    downNameMerit = !downNameMerit;
    
    if (downNameMerit) {
        [nameMeritOrderButton setBackgroundImage:[UIImage imageNamed:@"orderDownArrow.png"] forState:UIControlStateNormal];
    }else {
        [nameMeritOrderButton setBackgroundImage:[UIImage imageNamed:@"orderUpArrow.png"] forState:UIControlStateNormal];
    }
    
    searchText = searchTextField.text;
    
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (IBAction)onMenuButton:(id)sender {
    
    [searchTextField resignFirstResponder];
    
    if (menu.isOpen)
        return [menu close];
    [self closeMenu];
    
    if (smenu.isOpen) [smenu close];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [menu showFromRect:CGRectMake(0, 60, screenSize.width, screenSize.height - 40) inView:self.view];
    }else {
        [menu showFromRect:CGRectMake(0, 40, screenSize.width, screenSize.height - 40) inView:self.view];
    }
    
}

#pragma mark-
#pragma mark Request Functions

- (void) requestUpdateInfo {
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, REQUEST_VIDEO_ITEM_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%lu&%@=%@&%@=%lu",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_CNTLOADED, (unsigned long)cntLoaded,
                      TAG_REQ_TYPE, (unsigned long)orderType,
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
    requestType = REQUEST_FOR_UPDATE;
    
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


- (void) requestSmallVideoItem {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, REQUEST_VIDEO_ITEM_URL];
    
    //make request
    
    NSString *key;
    
    NSString *txtkeyword = searchText;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    if (orderType != 1) {
        
        NSUInteger sort;
        
        if (orderType == 0) {
            if (downHashDate) {
                sort = 1;
            }else {
                sort = 2;
            }
        }else {
            if (downHashDate) {
                sort = 1;
            }else {
                sort = 2;
            }
        }
        
        key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
               TAG_REQ_USERID, [[UserController instance] userUserID],
               TAG_REQ_TYPE, (unsigned long)orderType,
               TAG_REQ_TXTKEYWORD, txtkeyword,
               TAG_REQ_CNTLOADED, (unsigned long) cntLoaded,
               TAG_REQ_CURRENTTIME, currentTime,
               TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLazyLoad,
               TAG_REQ_SORT, (unsigned long) sort];
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

- (void) requestSmallUserList {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_MY_USER_LIST_URL];
    
    //make request
    
    NSString *txtkeyword = searchText;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    NSUInteger sort;
    
    if (userOrderType == 0) {
        if (downNameData) {
            sort = 1;
        }else {
            sort = 2;
        }
    }else if (userOrderType == 1) {
        if (downNameAlpha) {
            sort = 1;
        }else {
            sort = 2;
        }
    }else {
        if (downNameMerit) {
            sort = 1;
        }else {
            sort = 2;
        }
    }
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
                      TAG_REQ_TXTKEYWORD, txtkeyword,
                      TAG_REQ_CNTLOADED, (unsigned long) cntLoaded,
                      TAG_REQ_CURRENTTIME, currentTime,
                      TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLazyLoad,
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_TYPE, (unsigned long)userOrderType + 1,
                      TAG_REQ_SORT, (unsigned long)sort];
    
    
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

- (void) requestVideoItem {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_SEARCH_VIDEO_LIST_URL];
    
    //make request
    NSString *txtkeyword = searchText;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    NSString *key;
    
    
    if (orderType != 1) {
        
        NSUInteger sort;
        
        if (orderType == 0) {
            if (downHashDate) {
                sort = 1;
            }else {
                sort = 2;
            }
        }else {
            if (downHashDate) {
                sort = 1;
            }else {
                sort = 2;
            }
        }
        
        key = [NSString stringWithFormat:@"%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
               TAG_REQ_TYPE, (unsigned long)orderType,
               TAG_REQ_TXTKEYWORD, txtkeyword,
               TAG_REQ_CNTLOADED, (unsigned long) cntLoaded,
               TAG_REQ_CURRENTTIME, currentTime,
               TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLazyLoad,
               TAG_REQ_SORT, (unsigned long) sort];
    }else {
        int period = [[[NSUserDefaults standardUserDefaults] objectForKey:@"period"] intValue];
        key = [NSString stringWithFormat:@"%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
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

- (void) requestCurrentTime {
    
    [self startLoading];
    [videoItemArray removeAllObjects];
    [heightArray removeAllObjects];
    
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

- (void) requestUserList {

    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_SEARCH_USER_LIST_URL];
    
    //make request
    
    NSString *txtkeyword = searchText;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    NSUInteger sort;
    
    if (userOrderType == 0) {
        if (downNameData) {
            sort = 1;
        }else {
            sort = 2;
        }
    }else if (userOrderType == 1) {
        if (downNameAlpha) {
            sort = 1;
        }else {
            sort = 2;
        }
    }else {
        if (downNameMerit) {
            sort = 1;
        }else {
            sort = 2;
        }
    }
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
                      TAG_REQ_TXTKEYWORD, txtkeyword,
                      TAG_REQ_CNTLOADED, (unsigned long) cntLoaded,
                      TAG_REQ_CURRENTTIME, currentTime,
                      TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLazyLoad,
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_TYPE, (unsigned long)userOrderType + 1,
                      TAG_REQ_SORT, (unsigned long)sort];
    
    
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

- (void) requestRefreshUserList {
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_SEARCH_USER_LIST_URL];
    
    //make request
    
    NSString *txtkeyword = searchText;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    
    NSUInteger sort;
    
    if (userOrderType == 0) {
        if (downNameData) {
            sort = 1;
        }else {
            sort = 2;
        }
    }else if (userOrderType == 1) {
        if (downNameAlpha) {
            sort = 1;
        }else {
            sort = 2;
        }
    }else {
        if (downNameMerit) {
            sort = 1;
        }else {
            sort = 2;
        }
    }
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
                      TAG_REQ_TXTKEYWORD, txtkeyword,
                      TAG_REQ_CNTLOADED, (unsigned long) 0,
                      TAG_REQ_CURRENTTIME, currentTime,
                      TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLoaded,
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_TYPE, (unsigned long)userOrderType + 1,
                      TAG_REQ_SORT, (unsigned long)sort];
    
    
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

- (void) requestRefreshSmallVideoItem {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, REQUEST_VIDEO_ITEM_URL];
    
    //make request
    
    NSString *key;
    
    NSString *txtkeyword = searchText;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    if (orderType != 1) {
        
        NSUInteger sort;
        
        if (orderType == 0) {
            if (downHashDate) {
                sort = 1;
            }else {
                sort = 2;
            }
        }else {
            if (downHashDate) {
                sort = 1;
            }else {
                sort = 2;
            }
        }
        
        key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu%@=%lu",
               TAG_REQ_USERID, [[UserController instance] userUserID],
               TAG_REQ_TYPE, (unsigned long)orderType,
               TAG_REQ_TXTKEYWORD, txtkeyword,
               TAG_REQ_CNTLOADED, (unsigned long) 0,
               TAG_REQ_CURRENTTIME, currentTime,
               TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLoaded,
               TAG_REQ_SORT, (unsigned long) sort];
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

- (void) requestRefreshSmallUserList {
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_MY_USER_LIST_URL];
    
    //make request
    
    NSString *txtkeyword = searchText;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    NSUInteger sort;
    
    if (userOrderType == 0) {
        if (downNameData) {
            sort = 1;
        }else {
            sort = 2;
        }
    }else if (userOrderType == 1) {
        if (downNameAlpha) {
            sort = 1;
        }else {
            sort = 2;
        }
    }else {
        if (downNameMerit) {
            sort = 1;
        }else {
            sort = 2;
        }
    }
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
                      TAG_REQ_TXTKEYWORD, txtkeyword,
                      TAG_REQ_CNTLOADED, (unsigned long) 0,
                      TAG_REQ_CURRENTTIME, currentTime,
                      TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLoaded,
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_TYPE, (unsigned long)userOrderType + 1,
                      TAG_REQ_SORT, (unsigned long)sort];
    
    
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

- (void) requestRefreshVideoItem {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_SEARCH_VIDEO_LIST_URL];
    
    //make request
    NSString *txtkeyword = searchText;
    if (txtkeyword == Nil) {
        txtkeyword = @"";
    }
    
    NSString *key;
    
    
    if (orderType != 1) {
        
        NSUInteger sort;
        
        if (orderType == 0) {
            if (downHashDate) {
                sort = 1;
            }else {
                sort = 2;
            }
        }else {
            if (downHashDate) {
                sort = 1;
            }else {
                sort = 2;
            }
        }
        
        key = [NSString stringWithFormat:@"%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
               TAG_REQ_TYPE, (unsigned long)orderType,
               TAG_REQ_TXTKEYWORD, txtkeyword,
               TAG_REQ_CNTLOADED, (unsigned long) 0,
               TAG_REQ_CURRENTTIME, currentTime,
               TAG_REQ_CNTLAZYLOAD, (unsigned long) cntLoaded,
               TAG_REQ_SORT, (unsigned long) sort];
    }else {
        int period = [[[NSUserDefaults standardUserDefaults] objectForKey:@"period"] intValue];
        key = [NSString stringWithFormat:@"%@=%lu&%@=%@&%@=%lu&%@=%@&%@=%lu&%@=%lu",
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
            
            if ([currentWatchState isEqualToString:BIG_STATE]) {
                if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
                    [self requestUserList];
                }else {
                    [self requestVideoItem];
                }
            }else {
                if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
                    [self requestSmallUserList];
                }else {
                    [self requestSmallVideoItem];
                }
            }

        }else if ([requestType isEqualToString:REQUEST_FOR_REFRESH_GETTIME]) {
            
            currentTime = [dict objectForKey:TAG_RES_CURRENTTIME];
            
            if ([currentWatchState isEqualToString:BIG_STATE]) {
                if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
                    [self requestRefreshUserList];
                }else {
                    [self requestRefreshVideoItem];
                }
            }else {
                if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
                    [self requestRefreshSmallUserList];
                }else {
                    [self requestRefreshSmallVideoItem];
                }
            }
        }else if ([requestType isEqualToString:REQUEST_FOR_VIDEOITEM]){
            
            NSMutableArray *videoListArray;
            
            videoListArray = [dict objectForKey:TAG_RES_VIDEOLIST];
            
            if ([videoListArray count] == 0 && cntLoaded == 0) {
                descriptionContentView.hidden = NO;
                scrollContainerView.hidden = YES;

                descriptionLabel.text = @"This Hashtag doesn't have result.";
            }else {
                descriptionContentView.hidden = YES;
                scrollContainerView.hidden = NO;
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
//            [self endLoading];
        }else if ([requestType isEqualToString:REQUEST_FOR_USERLIST]){
        
            NSMutableArray *userListArray;
            
            userListArray = [dict objectForKey:TAG_RES_USERLIST];
            
            if ([userListArray count] == 0 && cntLoaded == 0) {
                descriptionContentView.hidden = NO;
                scrollContainerView.hidden = YES;
                
                descriptionLabel.text = @"This Username doesn't have result.";
            }else {
                descriptionContentView.hidden = YES;
                scrollContainerView.hidden = NO;
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
            
            [self requsetCheckNotification];
//            [self endLoading];
        }else if ([requestType isEqualToString:REQUEST_FOR_NOTIFICATION]) {
            NSString *checkFlag = [dict objectForKey:TAG_RES_ISNEWNOTIFICATION];
            
            if ([checkFlag isEqualToString:@"Y"]) {
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
            }else {
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
            }
            
            [self endLoading];
        }else if ([requestType isEqualToString:REQUEST_FOR_REFRESH_VIDEOITEM]) {
            
            NSMutableArray *updateItemArray;
            
            updateItemArray = [dict objectForKey:TAG_RES_VIDEOLIST];
            
            float pheight, nheight;
            float sheight = 0;
            int i;
            
            
            if ([videoItemType isEqualToString:DETAIL_VIDEO_ITEM] && [updateItemArray count] > 0) {
                
                //for added videoitem
                
                i = 0;
                int count = 0;
                
                for (i = 0; i < [updateItemArray count]; i++) {
                    NSDictionary *dict1 = [updateItemArray objectAtIndex:i];
                    
                    NSString *vid = [dict1 objectForKey:TAG_RES_RB_VIDEO];
                    
                    
                    RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
                        
                    if ([vid isEqualToString:vc.videoID]) {
                        pheight = [[heightArray objectAtIndex:i] intValue];
                        [vc clear];
                        [vc setData:dict1];
                        [vc parseData];
                        nheight = vc.view.frame.size.height;
                            
                        if (pheight != nheight) {
                            float iheight = nheight - pheight;
                            sheight += iheight;
                            for (int k = i + 1; k < [videoItemArray count]; k++) {
                                RBVideoViewController *vc1 = (RBVideoViewController *)[videoItemArray objectAtIndex:k];
                                [vc1.view setCenter:CGPointMake(vc1.view.center.x, vc1.view.center.y + iheight)];
                            }
                            [heightArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:nheight]];
                        }
                    }else {
                        
                        count ++;
                        
                        RBVideoViewController *rbVC = [[RBVideoViewController alloc] initWithNibName:@"RBVideoViewController" bundle:Nil];
                        
                        [rbVC setData:dict1];
                        [rbVC setNumber:0];
                        rbVC.view.frame = CGRectMake(6, vc.view.frame.origin.y, 308, rbVC.view.frame.size.height);
                        
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:i] forKey:@"insertNumber"];
                        
                        [videoItemArray insertObject:rbVC atIndex:i];
                        
                        RBVideoViewController *vc = (RBVideoViewController *) [videoItemArray objectAtIndex:i];
                        
                        [heightArray insertObject:[NSNumber numberWithInt:vc.view.frame.size.height] atIndex:0];
                        
                        [self insertViewToScrollView];
                        
                    }
                }
                
                //for deleted video item
                
                i  = 0;
                
                for (i = count; i > 0; i--) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:cntLoaded] forKey:@"RemoveVideoNumber"];
                    [self removeVideoItem];
                }
                
            }else if ([updateItemArray count] > 0){
                //for added video item
                i = 0;
                
                int count = 0;
                
                for (i = 0; i < [updateItemArray count]; i++) {
                    NSDictionary *dict1 = [updateItemArray objectAtIndex:i];
                    
                    NSString *vid = [dict1 objectForKey:TAG_RES_RB_VIDEO];
                    

                    RBVideoListViewController *vc = (RBVideoListViewController *)[videoItemArray objectAtIndex:i];
                        
                    if ([vid isEqualToString:vc.videoID]) {
                        pheight = [[heightArray objectAtIndex:i] intValue];
                        [vc clear];
                        [vc setData:dict1];
                        [vc parseData];
                        nheight = vc.view.frame.size.height;
                            
                        if (pheight != nheight) {
                            float iheight = nheight - pheight;
                            sheight += iheight;
                            for (int k = i + 1; k < [videoItemArray count]; k++) {
                                RBVideoListViewController *vc1 = (RBVideoListViewController *)[videoItemArray objectAtIndex:k];
                                [vc1.view setCenter:CGPointMake(vc1.view.center.x, vc1.view.center.y + iheight)];
                            }
                            [heightArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:nheight]];
                        }
                            
                    }else {
                        
                        count ++;
                        
                        RBVideoListViewController *rbVC = [[RBVideoListViewController alloc] initWithNibName:@"RBVideoListViewController" bundle:Nil];
                        
                        [rbVC setData:dict1];
                        [rbVC setNumber:0];
                        rbVC.view.frame = CGRectMake(6, vc.view.frame.origin.y, 308, rbVC.view.frame.size.height);
                        
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:i] forKey:@"insertNumber"];
                        
                        [videoItemArray insertObject:rbVC atIndex:i];
                        
                        RBVideoListViewController *vc = (RBVideoListViewController *) [videoItemArray objectAtIndex:i];
                        
                        [heightArray insertObject:[NSNumber numberWithInt:vc.view.frame.size.height] atIndex:0];
                        
                        [self insertViewToScrollView];
                        
                    }
                }
                
                i = 0;
                
                //for deleted video item
                for (i = count; i > 0; i--) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:cntLoaded] forKey:@"RemoveVideoNumber"];
                    [self removeVideoItem];
                }
            }
            
            [self endLoading];
            
        }else if ([requestType isEqualToString:REQUEST_FOR_REFRESH_USERITEM]) {
            
            NSMutableArray *userListArray;
            
            userListArray = [dict objectForKey:TAG_RES_VIDEOLIST];
            currentTime = [dict objectForKey:TAG_RES_CURRENTTIME];
            
            if ([userListArray count] > 0) {
                
                //for added userlist
                int i;
                int count = 0;
                
                for (i = 0; i < [userListArray count]; i++) {
                    NSDictionary *dict1 = [userListArray objectAtIndex:i];
                    
                    NSString *userId = [dict1 objectForKey:TAG_RES_RB_USER];
                    

                    RBUserListViewController *vc = (RBUserListViewController *)[videoItemArray objectAtIndex:i];
                    
                    if (![vc.userId isEqualToString:userId]) {
                        count ++;
                        
                        RBUserListViewController *rbVC = [[RBUserListViewController alloc] initWithNibName:@"RBUserListViewController" bundle:Nil];
                        
                        [rbVC setData:dict1];
                        [rbVC setNumber:0];
                        rbVC.view.frame = CGRectMake(6, vc.view.frame.origin.y, 308, rbVC.view.frame.size.height);
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:i] forKey:@"insertNumber"];
                        
                        [videoItemArray insertObject:rbVC atIndex:i];
                        
                        RBUserListViewController *vc = (RBUserListViewController *) [videoItemArray objectAtIndex:i];
                        
                        [heightArray insertObject:[NSNumber numberWithInt:vc.view.frame.size.height] atIndex:0];
                        
                        [self insertViewToScrollView];
                        
                    }
                }
                
                // for removed userlist
                for (i = count; i > 0; i--) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:cntLoaded] forKey:@"RemoveVideoNumber"];
                    [self removeVideoItem];
                }
                
                
                if ([userListArray count] != 0 && cntLoaded > cntLazyLoad) {
                    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 20) animated:YES];
                }
            }
            
            scrollView.contentSize = CGSizeMake(320, startY);
            
            [self requsetCheckNotification];
            
            [self endLoading];
        }
        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        
        if ([errorMsg isEqualToString:@""]) {
            return;
        }
        
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
}

- (void) removeVideoItem {
    
    if ([videoItemType isEqualToString:DETAIL_VIDEO_ITEM]) {
        int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
        
        RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:number];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        [vc.view removeFromSuperview];
        
//        for (int i = number + 1; i < [videoItemArray count]; i++) {
//            RBVideoViewController *cvc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
//            CGPoint k = cvc.view.center;
//            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
//            [cvc setNumber:cvc.number - 1];
//        }
        
        [videoItemArray removeObjectAtIndex:number];
        [heightArray removeObjectAtIndex:number];
        [self.scrollView setNeedsDisplay];
        
        startY -= iheight;
    }else if ([videoItemType isEqualToString:LIST_VIDEO_ITEM]){
        int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
        
        RBVideoListViewController *vc = (RBVideoListViewController *)[videoItemArray objectAtIndex:number];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        [vc.view removeFromSuperview];
        
//        for (int i = number + 1; i < [videoItemArray count]; i++) {
//            RBVideoListViewController *cvc = (RBVideoListViewController *)[videoItemArray objectAtIndex:i];
//            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
//        }
        
        [videoItemArray removeObjectAtIndex:number];
        [heightArray removeObjectAtIndex:number];
        [self.scrollView setNeedsDisplay];
        
        startY -= iheight;
    }else {
        int number = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveVideoNumber"] intValue];
        
        RBUserListViewController *vc = (RBUserListViewController *)[videoItemArray objectAtIndex:number];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        [vc.view removeFromSuperview];
        
//        for (int i = number + 1; i < [videoItemArray count]; i++) {
//            RBUserListViewController *cvc = (RBUserListViewController *)[videoItemArray objectAtIndex:i];
//            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y - iheight)];
//        }
        
        [videoItemArray removeObjectAtIndex:number];
        [heightArray removeObjectAtIndex:number];
        [self.scrollView setNeedsDisplay];
        
        startY -= iheight;
    }
    
    scrollView.contentSize = CGSizeMake(320, startY + 20);
//    
//    [self startLoading];
//    [self requestVideoItem];
//    
//    [self requsetCheckNotification];
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
    [heightArray removeObjectAtIndex:number];
    [self.scrollView setNeedsDisplay];
    
    startY -= iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
    
    [self startLoading];
    [self requestVideoItem];
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

#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    
    for (UIView *child in scrollView.subviews) {
        child.userInteractionEnabled = FALSE;
    }
    
    isAnimating = YES;
//    hashtagListButton.enabled = NO;
    segmentedControl.enabled = NO;
    usernameButton.enabled = NO;
    
    self.segmentedControl.enabled = NO;
//    scrollView.scrollEnabled = NO;
    [activityView startAnimation];
    viewLoading.hidden = NO;
    viewLoading.alpha = 1;
}

- (void)endLoading{
    
    for (UIView *child in scrollView.subviews) {
        child.userInteractionEnabled = TRUE;
    }
    
    isAnimating = NO;
    
//    hashtagListButton.enabled = YES;
    usernameButton.enabled = YES;
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
#pragma mark UITextField Delegate Functions
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    searchText = searchTextField.text;
    [searchTextField resignFirstResponder];
    [self clearScrollView];
    [self resetCntValues];
    [self requestCurrentTime];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    int i;
    for (i = 0 ; i < 2; i++) {
        dmenu = [menuArray objectAtIndex: i];
        if ([dmenu isOpen]) {
            break;
        }
    }
    
    if (i == 2) {
        [self textChanged:searchTextField];
    }
}

-(void)textChanged:(UITextField *)textField
{
    searchText = [searchTextField.text lowercaseString];
    
    if ([searchText length] == 0)
    {
        [self closeMenu];
        return;
    }
    
    //    [resetButton setEnabled:NO];
    
    CGSize mainSize = [[UIScreen mainScreen] bounds].size;
    
    NSString *value = [[[AppSharedData sharedInstance] dHashtagList] objectForKey:searchText];
    
    if ([value length] > 0) {
        for (int i = 0 ; i < 2; i++) {
            dmenu = [menuArray objectAtIndex: i];
            if ([dmenu isOpen]) {
                [dmenu close];
            }else {
                [self setMenuItems: value];
                CGSize screenSize = [[UIScreen mainScreen] bounds].size;
                
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
                    [dmenu showFromRect:CGRectMake(40, 60, screenSize.width - 80, screenSize.height - 40) inView:self.view];
                }else {
                    [dmenu showFromRect:CGRectMake(40, 40, screenSize.width - 80, screenSize.height - 40) inView:self.view];
                }
                break;
            }
        }
        
    }else {
        
        [[MTHTTPClient sharedClient].operationQueue cancelAllOperations];
        
        //make URL
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_PARENTHASHTAG_URL];
        
        //make request
        NSString * key = [NSString stringWithFormat:@"%@=%@",
                          TAG_REQ_KEYWORD, searchTextField.text];
        
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
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            
            NSDictionary *dict;
            
            dict = (NSDictionary*)[jsonParser objectWithString:text ];
            
            NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
            
            if ([successFlag isEqualToString:TAG_SUCCCESS]) {
                NSString *parentHashtag = [dict objectForKey:TAG_RES_PARENTHASHTAG];
                if ([parentHashtag length] > 0) {
                    for (int i = 0 ; i < 2; i++) {
                        dmenu = [menuArray objectAtIndex: i];
                        if ([dmenu isOpen]) {
                            [dmenu close];
                        }else {
                            [self setMenuItems: parentHashtag];
                            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
                            
                            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
                                [dmenu showFromRect:CGRectMake(40, 60, screenSize.width - 80, screenSize.height - 40) inView:self.view];
                            }else {
                                [dmenu showFromRect:CGRectMake(40, 40, screenSize.width - 80, screenSize.height - 40) inView:self.view];
                            }
                            break;
                        }
                    }
                }
            }else {
                for (int i = 0; i < 2; i++) {
                    dmenu = [menuArray objectAtIndex:i];
                    if ([dmenu isOpen] || [dmenu isAnimating]) {
                        [dmenu close];
                    }
                }
            }
            
        } failure:nil];
        
        [[MTHTTPClient sharedClient] enqueueHTTPRequestOperation:requestOperation];
        

    }
}

#pragma mark-
#pragma mark Set Menu Items
- (void) setMenuItems:(NSString *)title {
    
    REMenuItem *defaultItem;
    
    if ([title isEqualToString:@""]) {
        defaultItem = [[REMenuItem alloc] initWithTitle:@"CREATE NEW CATEGORY"
                                                  image:nil
                                       highlightedImage:nil
                                                 action:^(REMenuItem *item) {
                                                     [searchTextField resignFirstResponder];
                                                 }];
        
        [dmenu setStartNumber:0];
    }else {
        defaultItem = [[REMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"USE '%@' INSTEAD", title]
                                                  image:nil
                                       highlightedImage:nil
                                                 action:^(REMenuItem *item) {
                                                     [self changeCategoryTextField:title];
                                                     [searchTextField resignFirstResponder];
                                                 }];
        
        [dmenu setStartNumber:1];
    }
    
    [self.view bringSubviewToFront:defaultItem.customView];
    
    defaultItem.tag = 0;
    [dmenu setItems:@[defaultItem]];
}

- (void) changeCategoryTextField: (NSString *) title {
    
    searchTextField.text = title;
    searchText = [searchTextField.text lowercaseString];
    
    if (menu.isOpen) [menu close];
    if (smenu.isOpen) [smenu close];
    if (dmenu.isOpen) {
        [dmenu close];
    }
    
    [searchTextField resignFirstResponder];
    [self resetCntValues];
    [self requestCurrentTime];
}

- (void) closeMenu {
    for (int i = 0; i < [menuArray count]; i++) {
        dmenu = [menuArray objectAtIndex:i];
        if ([dmenu isOpen]) {
            [dmenu close];
        }
    }
}

#pragma mark -
#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && !isAnimating) {
        // we are at the end
        [self startLoading];
        
        
        if ([currentWatchState isEqualToString:BIG_STATE]) {
            if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
                [self requestUserList];
            }else {
                [self requestVideoItem];
            }
        }else {
            if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
                [self requestSmallUserList];
            }else {
                [self requestSmallVideoItem];
            }
        }

    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < -100.0 && scrollView.contentOffset.y > -110.0) {
        
        [self requestRefreshCurrentTime];
        
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
    
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, screenRect.size.height - 135)];
}

+(SearchViewController *) sharedInstance {
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

#pragma mark -
#pragma mark Insert View to ScrollView

- (void) insertViewToScrollView {
    
    int ii = [[[NSUserDefaults standardUserDefaults] objectForKey:@"insertNumber"] intValue];
    
    if ([videoItemType isEqualToString:USER_VIDEO_ITEM]) {
        RBUserListViewController *vc = (RBUserListViewController *)[videoItemArray objectAtIndex:ii];
        
        [self.scrollView addSubview:vc.view];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        for (int i = ii + 1; i < [videoItemArray count]; i++) {
            RBUserListViewController *cvc = (RBUserListViewController *)[videoItemArray objectAtIndex:i];
            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y + iheight)];
            [cvc setNumber:cvc.number + 1];
        }
        
        [self.scrollView setNeedsDisplay];
        
        startY += iheight;
        scrollView.contentSize = CGSizeMake(320, startY + 20);
        
    }else if ([videoItemType isEqualToString:DETAIL_VIDEO_ITEM]){
        
        RBVideoViewController *vc = (RBVideoViewController *)[videoItemArray objectAtIndex:ii];
        
        [self.scrollView addSubview:vc.view];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        for (int i = ii + 1; i < [videoItemArray count]; i++) {
            RBVideoViewController *cvc = (RBVideoViewController *)[videoItemArray objectAtIndex:i];
            CGPoint k = cvc.view.center;
            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y + iheight)];
            [cvc setNumber:cvc.number + 1];
        }
        
        [self.scrollView setNeedsDisplay];
        
        startY += iheight;
        scrollView.contentSize = CGSizeMake(320, startY + 20);
    }else {
        RBVideoListViewController *vc = (RBVideoListViewController *)[videoItemArray objectAtIndex:ii];
        
        [self.scrollView addSubview:vc.view];
        
        float iheight = vc.view.frame.size.height + stepY;
        
        for (int i = ii + 1; i < [videoItemArray count]; i++) {
            RBVideoListViewController *cvc = (RBVideoListViewController *)[videoItemArray objectAtIndex:i];
            CGPoint k = cvc.view.center;
            [cvc.view setCenter:CGPointMake(cvc.view.center.x, cvc.view.center.y + iheight)];
            [cvc setNumber:cvc.number + 1];
        }
        
        [self.scrollView setNeedsDisplay];
        
        startY += iheight;
        scrollView.contentSize = CGSizeMake(320, startY + 20);
    }
}


- (IBAction)hashDateOrderButton:(id)sender {
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [searchTextField resignFirstResponder];
}

#pragma mark-
#pragma mark Tap Gesture Function for ScrollView

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if ([smenu isOpen]) return;
    [searchTextField resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WatchScrollViewTapped" object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
