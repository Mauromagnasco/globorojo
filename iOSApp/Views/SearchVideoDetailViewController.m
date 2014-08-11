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

#import "SearchVideoDetailViewController.h"
#import "Constants.h"
#import "RBVideoViewController.h"
#import "UserController.h"
#import "SBJson.h"
#import "NotificationViewController.h"
#import "AppDelegate.h"
#import "SearchViewController.h"
#import "AppSharedData.h"

@interface SearchVideoDetailViewController ()

@end

@implementation SearchVideoDetailViewController

static SearchVideoDetailViewController *sharedInstance = nil;

@synthesize notiButton;
@synthesize scrollView;
@synthesize viewLoading;
@synthesize activityView;
@synthesize recvData;
@synthesize data;
@synthesize rbVC;
@synthesize searchTextField;
@synthesize menu;
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
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2 - 45, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
    
    [searchTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetOffset:) name:@"SearchDetailViewHide" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnOffset:) name:@"SearchDetailViewShow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCommentItem:) name:@"SearchDetailAddCommentItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCommentItem:) name:@"SearchDetailRemoveCommentItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeVideoItem:) name:@"SearchDetailRemoveVideoItem" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentItem:) name:@"SearchDetailShowCommentItem" object:Nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    sharedInstance = self;
    
    int badgeCount = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    
    if (badgeCount > 0) {
        [self setNotiButton_Red];
    }else {
        [self setNotiButton_Normal];
    }
   
    [[NSUserDefaults standardUserDefaults] setObject:@"SearchDetail" forKey:@"lastView"];
    [[NSUserDefaults standardUserDefaults] setObject:@"SearchDetail" forKey:@"currentView"];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"SearchDetail" forKey:@"SuperController"];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
    [self parseData];
    [self requsetCheckNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [rbVC.view removeFromSuperview];
}

- (void) parseData {

    rbVC = [[RBVideoViewController alloc] initWithNibName:@"RBVideoViewController" bundle:Nil];
    
    [rbVC setData:data];
    
    rbVC.view.frame = CGRectMake(6, 6, rbVC.view.frame.size.width, rbVC.view.frame.size.height);
    
//    rbVC.view.layer.masksToBounds = NO;
//    rbVC.view.layer.cornerRadius = 0; // if you like rounded corners
//    rbVC.view.layer.shadowOffset = CGSizeMake(1, 1);
//    rbVC.view.layer.shadowRadius = 1;
//    rbVC.view.layer.shadowOpacity = 0.5;
    
    [self.scrollView addSubview:rbVC.view];
    
    startY = rbVC.view.frame.size.height + 12;
    
    scrollView.contentSize = CGSizeMake(320, startY);
}


#pragma mark -
#pragma mark IBAction Functions

- (IBAction)onBackButton:(id)sender {
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *aController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    if ([aController isKindOfClass:[SearchViewController class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"returnSearch"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNotiButton:(id)sender {
    NotificationViewController *notificationViewController = [[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:Nil];
    
    [self.navigationController pushViewController:notificationViewController animated:YES];
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

- (IBAction)onSearchButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:Nil];
    
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark -
#pragma mark NSNotification Center Functions

- (void)resetOffset:(NSNotification *)notification {
    
    float currentPosition = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPosition"] floatValue];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    stepY = currentPosition - (screenSize.height - 220);
    
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + stepY) animated:YES];
}

- (void)returnOffset:(NSNotification *)notification {
    
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - stepY) animated:YES];
}


- (void) addCommentItem: (NSNotification *) notification {
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommentUserName"];
    NSString *commentContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommentContent"];
    NSString *commentID = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommentID"];
    NSString *userID = [[UserController instance] userUserID];
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          username, TAG_RES_RB_USERNAME,
                          commentContent, TAG_RES_RB_CONTENT,
                          commentID, TAG_RES_RB_USER_VIDEO_COMMENT,
                          userID, TAG_RES_RB_USER, nil];
    
    float iheight = [rbVC addCommentItemView: dict];
    
    startY += iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
}

- (void) removeCommentItem: (NSNotification *) notificaiton {
    
    int commentNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RemoveCommentNumber"] intValue];
    
    
    float iheight = [rbVC removeCommentItem:commentNumber];
    
    startY -= iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
    
}

- (void) removeVideoItem: (NSNotification *) notification {
    
    [[AppSharedData sharedInstance] setDeleteFlag:NO];
    
    float iheight = rbVC.view.frame.size.height + 6;
    
    [rbVC.view removeFromSuperview];
    
    startY -= iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
    
}

- (void) showCommentItem: (NSNotification *) notification {
    
    int iheight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowCommentIncreaseHeight"] intValue];
    
    startY += iheight;
    scrollView.contentSize = CGSizeMake(320, startY + 20);
}

#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    scrollView.scrollEnabled = NO;
    [activityView startAnimation];
    viewLoading.hidden = NO;
    viewLoading.alpha = 1;
}

- (void)endLoading{
    scrollView.scrollEnabled = YES;
    
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
#pragma mark Request Function

- (void) requsetCheckNotification {
    
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
    
    // clear data
    self.recvData = [NSMutableData data];
    
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
    didReceiveData:(NSData *)rdata
{
    
    [self.recvData appendData:rdata];
    
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
        

        NSString *checkFlag = [dict objectForKey:TAG_RES_ISNEWNOTIFICATION];
        
        if ([checkFlag isEqualToString:@"Y"]) {
            [notiButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
        }else {
            [notiButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
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
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        mainContentView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 20);

    }

    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, screenRect.size.height - 65)];
}

+(SearchVideoDetailViewController *) sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (void) setNotiButton_Red {
    [notiButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
}

- (void) setNotiButton_Normal {
    [notiButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
}


#pragma mark-
#pragma mark Tap Gesture Function for ScrollView

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [searchTextField resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WatchScrollViewTapped" object:nil];
}

@end
