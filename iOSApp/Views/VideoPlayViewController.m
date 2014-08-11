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

#import "VideoPlayViewController.h"
#import "AppDelegate.h"
#import "RateViewController.h"
#import "ShareVideoViewController.h"
#import "SearchVideoDetailViewController.h"
#import "UserController.h"
#import "Constants.h"
#import "SBJson.h"
#import "AppSharedData.h"
#import "DeleteVideoViewController.h"
#import "MDMGiftAppActivity.h"
#import "ProfileViewController.h"

#define REQUEST_DELETE_VIDEO        @"deleteVideo"
#define REQUEST_REPORT_VIDEO        @"reportVideo"
#define REQUEST_USERID              @"userid"


@interface MyMovieViewController : MPMoviePlayerViewController
@end

@implementation MyMovieViewController

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


@end


@interface VideoPlayViewController ()

@property (strong, nonatomic) MyMovieViewController *playerView;

@end

@implementation VideoPlayViewController

@synthesize videoUrl;
@synthesize webView;
@synthesize mainContentView;
@synthesize shareButton;
@synthesize videoID;
@synthesize videoTitle;
@synthesize userName;
@synthesize userID;
@synthesize hashTag;
@synthesize reportButton;
@synthesize number;
@synthesize activityView;
@synthesize recvData;
@synthesize requestType;
@synthesize videoScore;
@synthesize usernameTWLabel;
@synthesize hashTWLabel;
@synthesize rateButton;

static BOOL _isVideoPlaying = NO;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStarted:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWillExitFullscreen:) name:@"UIMoviePlayerControllerWillExitFullscreenNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[vComp objectAtIndex:0] intValue] < 7) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        [self.navigationController.view setFrame:CGRectMake(0, 0, screenSize.width+1, screenSize.height+1)];
    }
    
    
    rotateFlag = NO;
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if(![deviceType isEqualToString:@"iPad"]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    } // it's an iPhone
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [self.mainContentView addSubview:activityView];
    
    activityView.hidden = YES;
    
    [webView setFrame:CGRectMake(webView.frame.origin.x, webView.frame.origin.y, screenSize.width, screenSize.height - 80)];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"VideoPlay" forKey:@"lastView"];
    
    [self.mainContentView bringSubviewToFront:reportButton];
    [self.mainContentView bringSubviewToFront:shareButton];
    
    [hashTWLabel removeFromSuperview];
    [usernameTWLabel removeFromSuperview];
    
    NSString *txt;
    CGSize stringsize;
    
    txt = [NSString stringWithFormat:@"%@", userName];
    stringsize = [txt sizeWithFont:[UIFont fontWithName:CUSTOM_FONT size:13.f]];

    
    hashTWLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake((320 - stringsize.width) / 2 ,-8, stringsize.width,18)];
    
    [hashTWLabel setText:txt];
    
    txt = [NSString stringWithFormat:@"%@ %.1f", hashTag, videoScore];
    stringsize = [txt sizeWithFont:[UIFont fontWithName:CUSTOM_FONT size:13.f]];
    
    usernameTWLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake((320 - stringsize.width) / 2 ,10, stringsize.width,18)];
    
    [usernameTWLabel setText:txt];
    
    [hashTWLabel setButtonFontColor:[UIColor whiteColor]];
    [usernameTWLabel setButtonFontColor:[UIColor whiteColor]];
    [usernameTWLabel setTextColor:[UIColor whiteColor]];
    [hashTWLabel setTextColor:[UIColor whiteColor]];
    hashTWLabel.linksEnabled = YES;
    usernameTWLabel.linksEnabled = YES;
    [hashTWLabel setButtonFontSize:14.f];
    [usernameTWLabel setButtonFontSize:14.f];
    hashTWLabel.backgroundColor = [UIColor clearColor];
    usernameTWLabel.backgroundColor = [UIColor clearColor];
    [mainContentView addSubview:hashTWLabel];
    [mainContentView addSubview:usernameTWLabel];
    
    usernameTWLabel.linksEnabled = YES;
    hashTWLabel.linksEnabled = YES;
    
    [mainContentView bringSubviewToFront:rateButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestUserId:) name:IFTweetLabelUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchView:) name:IFTWeetLabelPostNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        
//        [[UIApplication sharedApplication] delegate].window.frame = CGRectMake(0, 20, screenRect.size.width, screenRect.size.height);
//        [[UIApplication sharedApplication] delegate].window.bounds = CGRectMake(0,  0, screenRect.size.width, screenRect.size.height);
//    }
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if(![deviceType isEqualToString:@"iPad"]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTWeetLabelPostNotification object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTweetLabelUserNotification object:nil];
    
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[vComp objectAtIndex:0] intValue] < 7) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        [self.navigationController.view setFrame:CGRectMake(0, 20, screenSize.width, screenSize.height - 20)];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    if (!returnFlag) {
        [self setStyle];
    }else {
        returnFlag = false;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setStyle {
    
    
    if ([videoUrl rangeOfString:@"youtube"].location == NSNotFound) {
        
        if ([videoUrl rangeOfString:@"vimeo"].location != NSNotFound) {
            
            int fs = [videoUrl rangeOfString:@"/" options:NSBackwardsSearch].location;
            int ds = [videoUrl rangeOfString:@"?" options:NSBackwardsSearch].location;
            
            NSString *vimeoId = [videoUrl substringWithRange:NSMakeRange(fs + 1, ds - fs - 1)];
            
            [YTVimeoExtractor fetchVideoURLFromURL:[NSString stringWithFormat:@"http://vimeo.com/%@", vimeoId] quality:YTVimeoVideoQualityMedium completionHandler:^(NSURL *videoURL, NSError *error, YTVimeoVideoQuality quality) {
                if (error) {
                    NSLog(@"Error : %@", [error localizedDescription]);
                } else if (videoURL) {
                    NSLog(@"Extracted url : %@", [videoURL absoluteString]);
                    
                    self.playerView = [[MyMovieViewController alloc] initWithContentURL:videoURL];
                    
                    self.playerView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
                    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    returnFlag = YES;
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    [request setURL:videoURL];
                    
                    [webView setMediaPlaybackRequiresUserAction:NO];
                    
                    [webView loadRequest:request];
                    
                }
            }];
        }else if ([videoUrl rangeOfString:@"facebook"].location != NSNotFound){
            
            int fs = [videoUrl rangeOfString:@"video_id" options:NSBackwardsSearch].location;
            NSString *evideoId = [videoUrl substringFromIndex:fs + 9];
            
            NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/video/video.php?v=%@", evideoId]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:fileURL];
            
            [webView setMediaPlaybackRequiresUserAction:NO];
            
            [webView loadRequest:request];
        }else {
        
            NSURL *fileURL = [NSURL URLWithString:videoUrl];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:fileURL];
            
            [webView setMediaPlaybackRequiresUserAction:NO];
            
            [webView loadRequest:request];
        }
        
    } else {
        int sl = [videoUrl rangeOfString:@"?autoplay=1"].location;
        
        NSString *rv = [videoUrl substringToIndex:sl];
        
        int dl = [rv rangeOfString:@"/" options:NSBackwardsSearch].location;
        
        NSString *rvideoId = [rv substringFromIndex:dl + 1];
        
        NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";
        
        
        NSString *html = [NSString stringWithFormat:youTubeVideoHTML, webView.frame.size.width, webView.frame.size.height, rvideoId];
        
        [webView setMediaPlaybackRequiresUserAction:NO];
        [webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
    }
}

- (IBAction)onPrevButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)playerStarted:(NSNotification *)notification{
    _isVideoPlaying = YES;
}
-(void)playerWillExitFullscreen:(NSNotification *)notification {
    _isVideoPlaying = NO;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight)
        {
            rotateFlag = YES;
            self.navigationController.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.5 animations:^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft  animated:NO];
                // rotate main view, in this sample the view of navigation controller is the root view in main window
                [self.navigationController.view setTransform: CGAffineTransformMakeRotation(180 * M_PI * 0.5)];
                // set size of view
                [self.navigationController.view setFrame:CGRectMake(0, 0, screenSize.width+1, screenSize.height+1)];
            } completion:^(BOOL finished) {
                self.navigationController.view.userInteractionEnabled = YES;
            }];
        }else {
            rotateFlag = NO;
        }
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if(![deviceType isEqualToString:@"iPad"]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
    }else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    } // it's an iPhone
    
    
    [webView setFrame:CGRectMake(webView.frame.origin.x, webView.frame.origin.y, screenSize.width, screenSize.height - 80)];
    
    [mainContentView setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
//    }
}

+(BOOL)isVideoPlaying {
    return _isVideoPlaying;
}

- (IBAction)onReportButton:(id)sender {
    
    if ([userID isEqualToString:[[UserController instance] userUserID]]) {
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

- (IBAction)onShareButton:(id)sender {
    
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

- (IBAction)onRateButton:(id)sender {
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *aController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    
    if ([aController isKindOfClass:[RateViewController class]]) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else {
    
        RateViewController *rateView = [[RateViewController alloc] initWithNibName:@"RateViewController" bundle:nil];
    
        [rateView setVideoURL:videoUrl];
        [rateView setVideoID:videoID];
        [rateView setUserID:userID];
        [rateView setNumber:number];
        [rateView setVideoTitle:videoTitle];
        [rateView setUserName:userName];
        [rateView setHashTag:hashTag];
        [rateView setVideoScore:videoScore];
    
        [self.navigationController pushViewController:rateView animated:YES];
    }
}
- (BOOL)shouldAutorotate {
    return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(![VideoPlayViewController isVideoPlaying]) {
        return toInterfaceOrientation != UIInterfaceOrientationLandscapeLeft && toInterfaceOrientation != UIInterfaceOrientationLandscapeRight;
    }
    return NO;
}

-(void)viewWillLayoutSubviews{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7 && [deviceType isEqualToString:@"iPad"]) {
        self.view.clipsToBounds = YES;
        CGFloat screenHeight = screenRect.size.height;
        mainContentView.frame =  CGRectMake(0, 20, self.mainContentView.frame.size.width,screenHeight-20);
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
    }else if ([deviceType isEqualToString:@"iPad"]) {
        mainContentView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 20);
    }
}

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
        
        
        if ([requestType isEqualToString:REQUEST_REPORT_VIDEO]) {
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
                if ([aController isKindOfClass:[RateViewController class]]) {
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
