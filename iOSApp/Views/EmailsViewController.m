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

#import "EmailsViewController.h"
#import "Constants.h"
#import "AppSharedData.h"
#import "SBJson.h"
#import "UserController.h"
#import "AppDelegate.h"


#define CheckImageName                  @"noti_check.png"
#define UncheckImageName                @"noti_uncheck.png"
#define GetNotiStatus                   @"getNotiStatus"
#define SaveNotiStatus                  @"saveNotiStatus"


@interface EmailsViewController ()

@end

@implementation EmailsViewController

@synthesize navTitleLabel;
@synthesize menuButton;
@synthesize mentionLabel;
@synthesize scoreLabel;
@synthesize commentLabel;
@synthesize followLabel;
@synthesize unfollowLabel;
@synthesize mainContentView;
@synthesize scrollView;
@synthesize activityView;
@synthesize recvData;

@synthesize mentionButton;
@synthesize scoreButton;
@synthesize followButton;
@synthesize unfollowButton;
@synthesize commentButton;
@synthesize requestType;
@synthesize menu;


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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackButton:(id)sender {
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

- (IBAction)onMentionButton:(id)sender {
    
    if ([menu isOpen]) {
        [menu close];
    }
    
    mentionFlag = !mentionFlag;
    if (mentionFlag) {
        [mentionButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [mentionButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
}

- (IBAction)onScoreButton:(id)sender {

    if ([menu isOpen]) {
        [menu close];
    }

    scoreFlag = !scoreFlag;
    if (scoreFlag) {
        [scoreButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [scoreButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
}

- (IBAction)onCommentButton:(id)sender {
    
    if ([menu isOpen]) {
        [menu close];
    }
    
    commentFlag = !commentFlag;
    if (commentFlag) {
        [commentButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [commentButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
}

- (IBAction)onFollowButton:(id)sender {
    followFlag = !followFlag;
    if (followFlag) {
        [followButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [followButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
}

- (IBAction)onUnfollowButton:(id)sender {
    
    if ([menu isOpen]) {
        [menu close];
    }
    unfollowFlag = !unfollowFlag;
    
    if (unfollowFlag) {
        [unfollowButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [unfollowButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
}

- (IBAction)onConfirmButton:(id)sender {
    
    if ([menu isOpen]) {
        [menu close];
    }
    
    [self requestSaveNotiStatus];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    activityView.hidden = YES;
    [mainContentView addSubview:activityView];
    
    [self requestNotiStatus];
    
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


#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    [activityView startAnimation];
    isLoading = YES;
    activityView.hidden = NO;
    activityView.alpha = 1;
}

- (void)endLoading{
    isLoading = NO;
    
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

- (void) requestNotiStatus {
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_NOTISTATUS_URL];
    
    //make request
    
    NSString *key;
    key = [NSString stringWithFormat:@"%@=%@",
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
    
    requestType = GetNotiStatus;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) requestSaveNotiStatus {

    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SAVE_NOTISTATUS_URL];
    
    //make request
    
    NSString *mentionYn = (mentionFlag) ? @"Y": @"N";
    NSString *scoreYn = (scoreFlag) ? @"Y" : @"N";
    NSString *commentYn = (commentFlag) ? @"Y" : @"N";
    NSString *followYn = (followFlag) ? @"Y" : @"N";
    NSString *unfollowYn = (unfollowFlag) ? @"Y" : @"N";
    
    NSString *key;
    key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
           TAG_REQ_USERID, [[UserController instance] userUserID],
           TAG_REQ_MENTIONYN, mentionYn,
           TAG_REQ_SCOREYN, scoreYn,
           TAG_REQ_COMMENTYN, commentYn,
           TAG_REQ_FOLLOWYN, followYn,
           TAG_REQ_UNFOLLOWYN, unfollowYn];
    
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
    
    requestType = SaveNotiStatus;
    
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
    
    [self endLoading];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:GetNotiStatus]) {
            NSString *mentionYn = [dict objectForKey:TAG_RES_MENTIONYN];
            NSString *scoreYn  = [dict objectForKey:TAG_RES_SCOREYN];
            NSString *commentYn = [dict objectForKey:TAG_RES_COMMENTYN];
            NSString *followYn = [dict objectForKey:TAG_RES_FOLLOWYN];
            NSString *unfollowYn = [dict objectForKey:TAG_RES_UNFOLLOWYN];
            
            if ([mentionYn isEqualToString:@"Y"]) {
                mentionFlag = YES;
            }else {
                mentionFlag = NO;
            }
            
            if ([scoreYn isEqualToString:@"Y"]) {
                scoreFlag = YES;
            }else {
                scoreFlag = NO;
            }
            
            if ([commentYn isEqualToString:@"Y"]) {
                commentFlag = YES;
            }else {
                commentFlag = NO;
            }
            
            if ([followYn isEqualToString:@"Y"]) {
                followFlag = YES;
            }else {
                followFlag = NO;
            }
            
            
            if ([unfollowYn isEqualToString:@"Y"]) {
                unfollowFlag = YES;
            }else {
                unfollowFlag = NO;
            }
            
            
            [self applyValue];
        }else {
            [self.navigationController popViewControllerAnimated:YES];
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
#pragma mark Apply Values Method

- (void) applyValue {
    
    if (mentionFlag) {
        [mentionButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [mentionButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
    
    if (scoreFlag) {
        [scoreButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [scoreButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
    
    if (commentFlag) {
        [commentButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [commentButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
    
    if (followFlag) {
        [followButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [followButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
    
    if (unfollowButton) {
        [unfollowButton setBackgroundImage:[UIImage imageNamed:CheckImageName] forState:UIControlStateNormal];
    }else {
        [unfollowButton setBackgroundImage:[UIImage imageNamed:UncheckImageName] forState:UIControlStateNormal];
    }
}


@end
