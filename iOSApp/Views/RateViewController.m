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

#import "RateViewController.h"
#import "Constants.h"
#import "UserController.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import "AppSharedData.h"
#import "VideoPlayViewController.h"
#import "ShareVideoViewController.h"
#import "SearchVideoDetailViewController.h"
#import "DeleteVideoViewController.h"
#import "MDMGiftAppActivity.h"
#import "ProfileViewController.h"

#define REQUEST_GETVIDEOINFO        @"getVideoInfo"
#define REQUEST_SAVEVIDEOSCORE      @"saveVideoScore"
#define REQUEST_DELETE_VIDEO        @"deleteVideo"
#define REQUEST_REPORT_VIDEO        @"reportVideo"
#define REQUEST_USERID              @"userid"

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
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, aSize.width, tmpSize.height + 3);
}

@end


@interface RateViewController ()

@end

@implementation RateViewController

@synthesize viewsCountLabel;
@synthesize scoresCountLabel;
@synthesize sharesCountLabel;
@synthesize commentsCountLabel;
@synthesize circleSlider;
@synthesize sliderBackImageView;
@synthesize sliderContentView;
@synthesize scoreLabel;
@synthesize videoID;
@synthesize recvData;
@synthesize activityView;
@synthesize scoreList;
@synthesize avgScoreLabel;
@synthesize scrollView;
@synthesize requestType;
@synthesize mainContentView;
@synthesize confirmButton;
@synthesize videoURL;
@synthesize userID;
@synthesize number;
@synthesize videoTitle;
@synthesize userName;
@synthesize hashTag;
@synthesize videoScore;
@synthesize usernameTWLabel;
@synthesize hashTWLabel;
@synthesize myscoreTWLabel;
@synthesize redImageView;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestUserId:) name:IFTweetLabelUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchView:) name:IFTWeetLabelPostNotification object:nil];
    
    valueChanged = FALSE;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Rate" forKey:@"lastView"];
    
    [self clear];
    
    [self setStyle];
    [self requestVideoInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTWeetLabelPostNotification object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTweetLabelUserNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setStyle {

    circleSlider = [[UICircularSlider alloc] initWithFrame:CGRectMake(0, 0, sliderContentView.frame.size.width, sliderContentView.frame.size.height)];
    
    [circleSlider setMaximumValue:5.f];
    [circleSlider setMinimumValue:0.f];
    
    [self.sliderContentView addSubview:circleSlider];
    [self.sliderContentView bringSubviewToFront:sliderBackImageView];
    [self.sliderContentView bringSubviewToFront:scoreLabel];
    [self.sliderContentView bringSubviewToFront:redImageView];
    [self.sliderContentView bringSubviewToFront:confirmButton];
    
    [circleSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [self.view addSubview:activityView];
    
    activityView.hidden = YES;
    scoreList = [[NSMutableArray alloc] init];
    
    [avgScoreLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.f]];
    [scoreLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:19.f]];
    
    [self addTweetlabel];
}

-  (void) addTweetlabel {
    
    hashTWLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(20, 65, 240 , 15)];
    usernameTWLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(20, 42, 240, 15)];
    myscoreTWLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(20, 283, 240, 15)];
    [hashTWLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
    [usernameTWLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
    [myscoreTWLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
    [hashTWLabel setButtonFontColor:[UIColor whiteColor]];
    [usernameTWLabel setButtonFontColor:[UIColor whiteColor]];
    [myscoreTWLabel setButtonFontColor:[UIColor redColor]];
    [usernameTWLabel setTextColor:[UIColor whiteColor]];
    [hashTWLabel setTextColor:[UIColor whiteColor]];
    [myscoreTWLabel setTextColor:[UIColor redColor]];
    hashTWLabel.linksEnabled = YES;
    usernameTWLabel.linksEnabled = YES;
    myscoreTWLabel.linksEnabled = YES;
    [hashTWLabel setButtonFontSize:15.f];
    [usernameTWLabel setButtonFontSize:15.f];
    [myscoreTWLabel setButtonFontSize:15.f];
    hashTWLabel.backgroundColor = [UIColor clearColor];
    usernameTWLabel.backgroundColor = [UIColor clearColor];
    myscoreTWLabel.backgroundColor = [UIColor clearColor];
    [mainContentView addSubview:hashTWLabel];
    [mainContentView addSubview:usernameTWLabel];
    [mainContentView addSubview:myscoreTWLabel];
    
    usernameTWLabel.label.textAlignment = NSTextAlignmentCenter;
    hashTWLabel.label.textAlignment = NSTextAlignmentCenter;
    myscoreTWLabel.label.textAlignment = NSTextAlignmentCenter;
    
}

- (void) clear {
    for (UIView *child in scrollView.subviews) {
        [child removeFromSuperview];
    }
    [hashTWLabel removeFromSuperview];
    [usernameTWLabel removeFromSuperview];
    [myscoreTWLabel removeFromSuperview];
    hashTWLabel = nil;
    usernameTWLabel = nil;
    myscoreTWLabel = nil;
}


- (IBAction)updateProgress:(UISlider *)sender {
    valueChanged = TRUE;
    scoreLabel.text = [NSString stringWithFormat:@"%.0f", circleSlider.value];
    
    if ([userID isEqualToString:[[UserController instance] userUserID]]) {
        
    }else {
        confirmButton.hidden = NO;
    }
}

- (IBAction)onConfirmButton:(id)sender {
    [self requestSaveVideoScore];
}

- (IBAction)onShareButton:(id)sender {
//    ShareVideoViewController *shareVideoViewController = [[ShareVideoViewController alloc] initWithNibName:@"ShareVideoViewController" bundle:Nil];
//    
//    [shareVideoViewController setVideoUrl:videoURL];
//    [shareVideoViewController setVideoId:videoID];
//    [shareVideoViewController setVideoTitle:videoTitle];
//    [shareVideoViewController setUsername:userName];
//    [shareVideoViewController setHashtag:hashTag];
//    
//    [self.navigationController pushViewController:shareVideoViewController animated:YES];

    
    NSString *eVideoId = [ShareVideoViewController base64String:videoID];
    NSString *postUrl = [NSString stringWithFormat:@"%@/video.php?id=%@", SERVER_HOST, eVideoId];
    NSString *postData = [NSString stringWithFormat:@"%@ via %@ %@ %@", videoTitle, userName, hashTag, postUrl];
    
    //    NSString *shareString = @"Check out this awesome app";
    //    NSURL *shareURL = [NSURL URLWithString:@"http://buoyexplorer.com"];
    NSArray *activityItems = @[postData];
    
    
    
    // Gift app without affiliate ID
    MDMGiftAppActivity *giftAppActivity = [[MDMGiftAppActivity alloc] initWithUrl:postData];
    
    NSArray *excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    
    // Gift app with affiliate ID
    // MDMGiftAppActivity *giftAppActivity = [[MDMGiftAppActivity alloc] initWithAppID:@"XXXXXXXXX" withAffiliateToken:@"YYYYYY" withCampaignToken:@"ZZZZZZZ"];
    
    NSArray *applicationActivities = @[giftAppActivity];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                         applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = excludedActivityTypes;
    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)onReportButton:(id)sender {
    if ([userID isEqualToString:[[UserController instance] userUserID]]) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                 delegate:self
//                                                        cancelButtonTitle:@"Cancel"
//                                                   destructiveButtonTitle:nil
//                                                        otherButtonTitles:@"DELETE VIDEO", nil];
//        
//        [actionSheet showInView:self.navigationController.view];
        
        DeleteVideoViewController *vc = [[DeleteVideoViewController alloc] initWithNibName:@"DeleteVideoViewController" bundle:nil];
        
        [vc setVideoID:videoID];
        [vc setNumber:number];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"REPORT VIDEO", nil];
        
        [actionSheet showInView:self.navigationController.view];
    }
}

- (IBAction)onPlayButton:(id)sender {
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *aController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    
    if ([aController isKindOfClass:[VideoPlayViewController class]]) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else {
        
        VideoPlayViewController *videoPlayView = [[VideoPlayViewController alloc] initWithNibName:@"VideoPlayViewController" bundle:Nil];
    
        [videoPlayView setVideoUrl:videoURL];
        [videoPlayView setVideoID:videoID];
        [videoPlayView setUserID:userID];
        [videoPlayView setNumber:number];
        [videoPlayView setVideoTitle:videoTitle];
        [videoPlayView setUserName:userName];
        [videoPlayView setHashTag:[NSString stringWithFormat:@"#%@", hashTag]];
        [videoPlayView setVideoScore:videoScore];
    
        [self.navigationController pushViewController:videoPlayView animated:YES];
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

#pragma mark -
#pragma mark Request Video Information Functions

- (void) requestDeleteVideo {
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, DELETE_VIDEO_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_VIDEOID, videoID];
    
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
    
    requestType = REQUEST_DELETE_VIDEO;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestReportVideo {
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, REPORT_VIDEO_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_VIDEOID, videoID];
    
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
    
    requestType = REQUEST_REPORT_VIDEO;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestVideoInfo {
    
    [self startLoading];

    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_VIDEOINFO_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@",
                      TAG_REQ_VIDEOID, videoID,
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
    
    requestType = REQUEST_GETVIDEOINFO;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

- (void) requestSaveVideoScore {
    [self startLoading];
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SAVE_VIDEOSCORE_URL];
    
    int giveScore = (int) circleSlider.value;
   
    if (circleSlider.value - giveScore > 0.5) {
        giveScore ++;
    }
    
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%i",
                      TAG_REQ_VIDEOID, videoID,
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_SCORE, giveScore];
    
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
    
    requestType = REQUEST_SAVEVIDEOSCORE;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestUserId: (NSNotification *)notification {
    
    int linkCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"linkCount"] intValue];
    
    if (linkCount != 0) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"linkCount"];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_USERID_FROMUSERNAME_URL];
    
    NSString *username = [[[NSUserDefaults standardUserDefaults] objectForKey:IFTweetLabelButtonTitle] substringFromIndex:1];
    
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
    
    dict = (NSDictionary*)[jsonParser objectWithString:text ];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        
        if ([requestType isEqualToString:REQUEST_GETVIDEOINFO]) {
//            viewCount = [[dict objectForKey:TAG_RES_CNTVIEW] intValue];
//            shareCount = [[dict objectForKey:TAG_RES_CNTSHARE] intValue];
//            commentCount = [[dict objectForKey:TAG_RES_CNTCOMMENT] intValue];
//            scoreCount = [[dict objectForKey:TAG_RES_CNTSCORE] intValue];
            
            NSString *scored = [dict objectForKey:TAG_RES_ISSCORED];
            
            if ([scored isEqualToString:@"Y"]) {
                isScored = YES;
            }else {
                isScored = NO;
            }
            
            videoScore = [[dict objectForKey:TAG_RES_RB_VIDEO_SCORE] floatValue];
            
            
            hashTag = [dict objectForKey:TAG_RES_RB_HASHTAG];
            
            NSString *txt;
            CGSize stringsize;
            
            txt = [NSString stringWithFormat:@"%@", userName];
            stringsize = [txt sizeWithFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
            
            usernameTWLabel.text = [NSString stringWithFormat:@"%@", userName];
            [usernameTWLabel setFrame:CGRectMake((320 - stringsize.width) / 2, usernameTWLabel.frame.origin.y, stringsize.width, stringsize.height + 5)];
            
            txt = [NSString stringWithFormat:@"#%@ %.1f", hashTag, videoScore];
            stringsize = [txt sizeWithFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
            hashTWLabel.text = [NSString stringWithFormat:@"#%@ %.1f", hashTag, videoScore];
            [hashTWLabel setFrame:CGRectMake((320 - stringsize.width) / 2, hashTWLabel.frame.origin.y, stringsize.width, stringsize.height + 5)];
            
//            givenScore = [[dict objectForKey:TAG_RES_GIVENSCORE] floatValue];
            
//            NSDictionary *leaveDict = [dict objectForKey:TAG_RES_DATAVIDEO];
//            avgScore = [[leaveDict objectForKey:TAG_RES_RB_VIDEO_SCORE] floatValue];
            
            CGFloat myHashtagScore = [[dict objectForKey:TAG_RES_MYHASHTAGSCORE] floatValue];
            CGFloat myGivenScore = [[dict objectForKey:TAG_RES_MYGIVENSCORE] floatValue];
            NSString *myUsername = [dict objectForKey:TAG_RES_MYUSERNAME];

            txt = [NSString stringWithFormat:@"@%@(%.1f): %.0f", myUsername, myHashtagScore, myGivenScore];
            stringsize = [txt sizeWithFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
            myscoreTWLabel.text = [NSString stringWithFormat:@"@%@(%.1f): %.0f", myUsername, myHashtagScore, myGivenScore];
            [myscoreTWLabel setFrame:CGRectMake((320 - stringsize.width) / 2, myscoreTWLabel.frame.origin.y, stringsize.width, stringsize.height + 5)];
            
            if (!isScored) {
                myscoreTWLabel.hidden = YES;
            }else {
                myscoreTWLabel.hidden = NO;
            }
            
            scoreList = [dict objectForKey:TAG_RES_SCORELIST];
            
            
            //for circle slider value - start
            int currentScore = (int) videoScore;
            
            if (videoScore - currentScore >= 0.5) {
                currentScore ++;
            }
            
            if (isScored || [userID isEqualToString:[[UserController instance] userUserID]]) circleSlider.value = currentScore;
            //end
            

            confirmButton.hidden = YES;

            
            if ((scoreList != (id)[NSNull null] && isScored) || [userID isEqualToString:[[UserController instance] userUserID]] ) {
                [self applyValue];
            }
        }else if ([requestType isEqualToString:REQUEST_SAVEVIDEOSCORE]){
            changedScore = [[dict objectForKey:TAG_RES_VIDEOSCORE] floatValue];
            [[NSUserDefaults standardUserDefaults] setObject:videoID forKey:@"changedVideoId"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:changedScore] forKey:@"changedScore"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoScoreChanged" object:Nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sVideoScoreChanged" object:Nil];
            
            [self clear];
            [self addTweetlabel];
            [self requestVideoInfo];
        }else if ([requestType isEqualToString:REQUEST_REPORT_VIDEO]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your report has been sent successfully." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }else if ([requestType isEqualToString:REQUEST_DELETE_VIDEO]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:number] forKey:@"RemoveVideoNumber"];
            
            NSString *superController = [[NSUserDefaults standardUserDefaults] objectForKey:@"SuperController"];
            if ([superController isEqualToString:@"Home"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeRemoveVideoItem" object:Nil];
            }else if ([superController isEqualToString:@"Search"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchRemoveVideoItem" object:Nil];
            }else if ([superController isEqualToString:@"Profile"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileRemoveVideoItem" object:Nil];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchDetailRemoveVideoItem" object:Nil];
            }
            
            NSArray *viewControllers = [self.navigationController viewControllers];
            UIViewController *aController;
            for (int i = [viewControllers count] - 2; i >= 0; i--) {
                aController = [viewControllers objectAtIndex:i];
                if ([aController isKindOfClass:[SearchVideoDetailViewController class]]) {
                    continue;
                }
                if ([aController isKindOfClass:[VideoPlayViewController class]]) {
                    continue;
                }
                break;
            }

            
            [self.navigationController popToViewController:aController animated:YES];
            
        }else if ([requestType isEqualToString:REQUEST_USERID]) {
            NSString *uId = [dict objectForKey:TAG_RES_USERID];
            
            UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
            
            NSString *profileid = [NSString stringWithFormat:@"Profile%@", uId];
            
            if ([[[AppSharedData sharedInstance] profileHistory] containsObject:profileid]) {
                NSArray* arr = [[NSArray alloc] initWithArray:navigationController.viewControllers];
                int index;
                for(int i=0 ; i<[arr count] ; i++)
                {
                    if([[arr objectAtIndex:i] isKindOfClass:NSClassFromString(@"ProfileViewController")])
                    {
                        index = i;
                    }
                }
                
                if (index != [arr count] - 1) {
                    [navigationController popToViewController:[arr objectAtIndex:index] animated:YES];
                }
                
            }else {
                
                ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:Nil];
                
                [profileViewController setUserId:uId];
                
                [navigationController pushViewController:profileViewController animated:YES];
            }
        }

        
        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        if (![errorMsg isEqualToString:@""] && errorMsg != Nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            alert.delegate = self;
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
#pragma mark Apply Response Value
- (void) applyValue {
    
    commentsCountLabel.text = [NSString stringWithFormat:@"Comments: %i", commentCount];
    viewsCountLabel.text = [NSString stringWithFormat:@"Views: %i", viewCount];
    sharesCountLabel.text = [NSString stringWithFormat:@"Shares : %i", shareCount];
    scoresCountLabel.text = [NSString stringWithFormat:@"Scores: %i", scoreCount];
    
    scoreLabel.text = [NSString stringWithFormat:@"%.1f", givenScore];
    
        circleSlider.enabled = NO;
        [scrollView setCenter:CGPointMake(scrollView.center.x,398)];
    
    avgScoreLabel.text = [NSString stringWithFormat:@"Avg.Score: %.1f", avgScore];
    
    NSDictionary *dict;
    int sy = 0;
    
    NSString *txt;
    CGSize stringsize;
    
    for (int i = 0; i < [scoreList count]; i++) {
        dict = [scoreList objectAtIndex:i];
        
        txt = [NSString stringWithFormat:@"@%@(%.1f): %@", [dict objectForKey:TAG_RES_RB_USERNAME], [[dict objectForKey:TAG_RES_RB_HASHTAG_SCORE] floatValue], [dict objectForKey:TAG_RES_RB_GIVEN_SCORE]];
        stringsize = [txt sizeWithFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
        IFTweetLabel *label = [[IFTweetLabel alloc] initWithFrame:CGRectMake((240 - stringsize.width) / 2 ,sy, stringsize.width,18)];
        [label setText:txt];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setButtonFontColor:[UIColor whiteColor]];
        [label setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
        [label setButtonFontSize:15.f];
        label.linksEnabled = YES;
        
        [scrollView addSubview:label];
        sy += label.frame.size.height + 5;
    }
    
    float maxHeight = 0;
    for (UIView *child in scrollView.subviews) {
        float childHeight = child.frame.origin.y + child.frame.size.height;
        //if child spans more than current maxHeight then make it a new maxHeight
        if (childHeight > maxHeight)
            maxHeight = childHeight;
    }
    //set content size
    [scrollView setContentSize:(CGSizeMake(301, maxHeight))];
}

#pragma mark-
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        if ([requestType isEqualToString:REQUEST_SAVEVIDEOSCORE]) {
//            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
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

#pragma mark - UIActionSheet Delegate Functions

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        if ([userID isEqualToString:[[UserController instance] userUserID]]) {
            [self requestDeleteVideo];
        }else {
            [self requestReportVideo];
        }
    }
    
}

#pragma mark -
#pragma mark NSNotication Functions

- (void) showSearchView: (NSNotification *) notification {
    
    int linkCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"linkCount"] intValue];
    
    if (linkCount != 0) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"linkCount"];
    
    SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    
    NSString *searchText = [[[NSUserDefaults standardUserDefaults] objectForKey:IFTweetLabelButtonTitle] substringFromIndex:1];
    
    [searchViewController setSearchText:searchText];
    
    [self.navigationController pushViewController:searchViewController animated:YES];
    
}

@end
