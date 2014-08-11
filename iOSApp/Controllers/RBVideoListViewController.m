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

#import "RBVideoListViewController.h"
#import "Constants.h"
#import "SearchVideoDetailViewController.h"
#import "AppDelegate.h"
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AppSharedData.h"
#import "MTHTTPClient.h"
#import "SearchViewController.h"
#import "ProfileViewController.h"
#import "SBJson.h"
#import "VideoPlayViewController.h"
#import "RateViewController.h"

#define REQUEST_USERID                  @"userid"


@interface RBVideoListViewController ()

@end

@implementation RBVideoListViewController


@synthesize videoID;
@synthesize titleLabel;
@synthesize hashLabel;
@synthesize usernameLabel;
@synthesize videoThumbImageView;
@synthesize scoreImageView;
@synthesize playButton;
@synthesize rateButton;

@synthesize data;
@synthesize recvData;
@synthesize number;

@synthesize hashTWLabel;
@synthesize usernameTWLabel;
@synthesize requestType;
@synthesize videoURL;
@synthesize userId;

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
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"linkCount"];
    
    [titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [hashLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [usernameLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestUserId:) name:IFTweetLabelUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchView:) name:IFTWeetLabelPostNotification object:nil];
    
    [self parseData];
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

#pragma mark-
#pragma mark Parse Data
- (void) parseData {
    
    NSString *username  = [data objectForKey:TAG_RES_RB_USERNAME];
    usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
    
    NSString *hashtag = [data objectForKey:TAG_RES_RB_HASHTAG];
    hashLabel.text = [NSString stringWithFormat:@"#%@", hashtag];
    
    [usernameTWLabel removeFromSuperview];
    [hashTWLabel removeFromSuperview];
    
    hashTWLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(119, 45, 0, 0)];
    usernameTWLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(119, 0, 0, 0)];
    [hashTWLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [usernameTWLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [hashTWLabel setButtonFontColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]];
    [usernameTWLabel setButtonFontColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]];
    hashTWLabel.linksEnabled = YES;
    usernameTWLabel.linksEnabled = YES;
    hashTWLabel.backgroundColor = [UIColor clearColor];
    usernameTWLabel.backgroundColor = [UIColor clearColor];
    [hashTWLabel setButtonFontSize:14.f];
    [usernameTWLabel setButtonFontSize:14.f];
    hashLabel.hidden = YES;
    usernameLabel.hidden = YES;
    [self.view addSubview:hashTWLabel];
    [self.view addSubview:usernameTWLabel];
    usernameTWLabel.text = [NSString stringWithFormat:@"@%@", username];
    hashTWLabel.text = [NSString stringWithFormat:@"#%@", hashtag];
    
    videoURL = [data objectForKey:TAG_RES_VIDEOURL];
    videoScore = [[data objectForKey:TAG_RES_RB_VIDEO_SCORE] floatValue];
    userId = [data objectForKey:TAG_RES_RB_USER];
    
    videoID = [data objectForKey:TAG_RES_RB_VIDEO];
    
    
    NSString *description = [data objectForKey:TAG_RES_RB_CONTENT];
    titleLabel.text = description;
    
    float videoScore = [[data objectForKey:TAG_RES_RB_VIDEO_SCORE] floatValue];
    
    
    NSString *videoThumbUrl = [data objectForKey:TAG_RES_RB_VIDEO_THUMB_LARGE];
    UIImage *vImage;
    
    vImage = [[[AppSharedData sharedInstance] videoStoreImage] objectForKey:videoThumbUrl];
    
    if (vImage == nil) {
        
        NSURL *url = [NSURL URLWithString:videoThumbUrl];
        
        AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:url] success:^(UIImage *image) {
            
            [videoThumbImageView setImage:[AppSharedData resizeImage:image]];
            
//            [[[AppSharedData sharedInstance] videoStoreImage] setObject:[AppSharedData resizeImage:image] forKey:videoThumbUrl];
            //[activityIndicator removeFromSuperview];
            
        }];
        
        
        [imageOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
         {
             float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
             NSLog(@"VideoThumbImage ---------------- PROGRESS - %f -------- %f ---------- %lld", progress, (float)totalBytesRead, totalBytesExpectedToRead); //Can be deleted once the progress bar works.
             
         }];
        
        
        //        [httpClient enqueueHTTPRequestOperation:imageOperation];
        
        [[MTHTTPClient sharedClient] enqueueHTTPRequestOperation:imageOperation];
    }else {
        [videoThumbImageView setImage:vImage];
    }
    
    [self changeVideoScoreImage: videoScore];
    
    
    [self.view bringSubviewToFront:playButton];
    [self.view bringSubviewToFront:rateButton];
}

- (IBAction)onPlayButton:(id)sender {
    
    NSLog(@"PlayButton");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHashtag:) name:@"HashtagChanged" object:Nil];
    
    VideoPlayViewController *videoPlayView = [[VideoPlayViewController alloc] initWithNibName:@"VideoPlayViewController" bundle:Nil];
    
    [videoPlayView setVideoUrl:videoURL];
    [videoPlayView setVideoID:videoID];
    [videoPlayView setUserID:userId];
    [videoPlayView setNumber:number];
    [videoPlayView setVideoTitle:titleLabel.text];
    [videoPlayView setUserName:usernameLabel.text];
    [videoPlayView setHashTag:hashLabel.text];
    [videoPlayView setVideoScore:videoScore];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [navigationController pushViewController:videoPlayView animated:YES];
    });
}

- (IBAction)onRateButton:(id)sender {
    NSLog(@"RatingButton");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeVideoScoreImage:) name:@"VideoScoreChanged" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHashtag:) name:@"HashtagChanged" object:Nil];
    
    RateViewController *rateViewController = [[RateViewController alloc] initWithNibName:@"RateViewController" bundle:Nil];
    
    [rateViewController setVideoID:videoID];
    [rateViewController setVideoURL:videoURL];
    [rateViewController setUserID:userId];
    [rateViewController setNumber:number];
    [rateViewController setVideoTitle:titleLabel.text];
    [rateViewController setUserName:usernameLabel.text];
    [rateViewController setHashTag:hashLabel.text];
    [rateViewController setVideoScore:videoScore];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    [navigationController pushViewController:rateViewController animated:YES];
}

#pragma mark -
#pragma mark Change the User Score Image View

- (void) changeVideoScoreImage: (float) videoScore {
    
    int score = (int) videoScore;
    
    float mm = videoScore - (float) score;
    
    if (mm >= 0.5) {
        score ++;
    }
    
    switch (score) {
        case 0:
            [scoreImageView setImage:[UIImage imageNamed:@"pieWhite0.png"]];
            break;
            
        case 1:
            [scoreImageView setImage:[UIImage imageNamed:@"pieWhite1.png"]];
            break;
            
        case 2:
            [scoreImageView setImage:[UIImage imageNamed:@"pieWhite2.png"]];
            break;
            
        case 3:
            [scoreImageView setImage:[UIImage imageNamed:@"pieWhite3.png"]];
            break;
            
        case 4:
            [scoreImageView setImage:[UIImage imageNamed:@"pieWhite4.png"]];
            break;
            
        case 5:
            [scoreImageView setImage:[UIImage imageNamed:@"pieWhite5.png"]];
            break;
            
        default:
            break;
    }
}

- (IBAction)onViewButton:(id)sender {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(schangeVideoScoreImage:) name:@"sVideoScoreChanged" object:Nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHashtag:) name:@"sHashtagChanged" object:Nil];
    
    SearchVideoDetailViewController *videoDetailViewController = [[SearchVideoDetailViewController alloc] initWithNibName:@"SearchVideoDetailViewController" bundle:Nil];
    
    [videoDetailViewController setData:data];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    [navigationController pushViewController:videoDetailViewController animated:YES];
    
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
        
        if ([requestType isEqualToString:REQUEST_USERID]) {
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
            
            if ([requestType isEqualToString:REQUEST_USERID]) {
                return;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}




#pragma mark -
#pragma mark NSNotication Functions

- (void) showSearchView: (NSNotification *) notification {
    
    int linkCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"linkCount"] intValue];
    
    if (linkCount != 0) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"linkCount"];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTWeetLabelPostNotification object:Nil];
    
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    
    NSString *searchText = [[[NSUserDefaults standardUserDefaults] objectForKey:IFTweetLabelButtonTitle] substringFromIndex:1];
    
    [searchViewController setSearchText:searchText];
    
    [navigationController pushViewController:searchViewController animated:YES];
    
    
}

- (void) schangeVideoScoreImage: (NSNotification *) notification {
    
    NSString *changedVideoId = [[NSUserDefaults standardUserDefaults] objectForKey:@"changedVideoId"];
    float changedScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"changedScore"] floatValue];
    
    
    [data setValue:[NSNumber numberWithFloat:changedScore] forKey:TAG_RES_RB_VIDEO_SCORE];
    
    if ([changedVideoId isEqualToString:videoID]) {
        [self changeVideoScoreImage:changedScore];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sVideoScoreChanged" object:Nil];
    }
    
}

- (void) changeHashtag:(NSNotification *) notification {
    NSString *changedVideoId = [[NSUserDefaults standardUserDefaults] objectForKey:@"changedVideoId"];
    float changedScore = 0;
    NSString *changedHashtag = [[NSUserDefaults standardUserDefaults] objectForKey:@"changedHashtag"];
    
    hashLabel.text = [NSString stringWithFormat:@"#%@", changedHashtag];
    CGRect rect = hashTWLabel.frame;
    hashTWLabel.text = [NSString stringWithFormat:@"#%@", changedHashtag];
    [hashTWLabel setFrame:rect];
    
    [data setValue:[NSNumber numberWithFloat:changedScore] forKey:TAG_RES_RB_VIDEO_SCORE];
    [data setValue:changedHashtag forKeyPath:TAG_RES_RB_HASHTAG];
    
    if ([changedVideoId isEqualToString:videoID]) {
        [self changeVideoScoreImage:changedScore];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sHashtagChanged" object:Nil];
    }
}

- (void)clear {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestUserId:) name:IFTweetLabelUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchView:) name:IFTWeetLabelPostNotification object:nil];
    
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 308, 80)];
    [hashTWLabel removeFromSuperview];
    [usernameTWLabel removeFromSuperview];
    
    [self setStyle];
}

- (void) setStyle {
    
    [titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
    [hashLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [usernameLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    
    hashTWLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(84, 22, 0, 0)];
    usernameTWLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(84, 42, 0, 0)];
    [hashTWLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [usernameTWLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [hashTWLabel setButtonFontColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]];
    [usernameTWLabel setButtonFontColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]];
    hashTWLabel.linksEnabled = YES;
    usernameTWLabel.linksEnabled = YES;
    [hashTWLabel setButtonFontSize:14.f];
    [usernameTWLabel setButtonFontSize:14.f];
    hashTWLabel.backgroundColor = [UIColor clearColor];
    usernameTWLabel.backgroundColor = [UIColor clearColor];
    hashLabel.hidden = YES;
    usernameLabel.hidden = YES;
}
@end
