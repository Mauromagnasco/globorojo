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

#import "RBVideoViewController.h"
#import "Constants.h"
#import "CommentViewController.h"
#import "AddCommentViewController.h"
#import "VideoPlayViewController.h"
#import "AppDelegate.h"
#import "RateViewController.h"
#import "UserController.h"
#import "SBJson.h"
#import "ShareVideoViewController.h"
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AppSharedData.h"
#import "MTHTTPClient.h"
#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "DeleteVideoViewController.h"
#import "MDMGiftAppActivity.h"

#define REQUEST_VIDEO_COMMAND           @"video"
#define REQUEST_USERID                  @"userid"

@interface RBVideoViewController ()

@end

@implementation RBVideoViewController

@synthesize profileImageView;
@synthesize timeagoLabel;
@synthesize titleLabel;
@synthesize hashLabel;
@synthesize usernameLabel;
@synthesize playButton;
@synthesize ratingButton;
@synthesize viewHeight;

@synthesize data;
@synthesize videoID;
@synthesize videoThumbImageView;
@synthesize videoURL;
@synthesize commentItemArray;
@synthesize scoreImageView;
@synthesize number;
@synthesize heightArray;
@synthesize userId;
@synthesize activityView;
@synthesize recvData;
@synthesize requestType;
@synthesize showButton;
@synthesize addCommentView;
@synthesize commentArray;
@synthesize originFrame;
@synthesize shareButton;
@synthesize reportButton;
@synthesize hashTWLabel;
@synthesize usernameTWLabel;
@synthesize headerView;

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
    
    originFrame = self.view.frame;
}

- (void)viewWillAppear:(BOOL)animated {
    
//    NSString *currentView = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentView"];
//    
//    if ([currentView isEqualToString:@"SearchDetail"]) {
//        reportButton.hidden = YES;
//        shareButton.hidden = YES;
//    }else {
//        reportButton.hidden = NO;
//        shareButton.hidden = NO;
//    }

    //set Style
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"linkCount"];
    
    [self setStyle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestUserId:) name:IFTweetLabelUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchView:) name:IFTWeetLabelPostNotification object:nil];
 
    [self parseData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTWeetLabelPostNotification object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFTweetLabelUserNotification object:nil];
    
}

- (void)clear {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestUserId:) name:IFTweetLabelUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchView:) name:IFTWeetLabelPostNotification object:nil];
    
    for (int i = 0; i < [commentItemArray count]; i++) {
        CommentViewController *vc = (CommentViewController *)[commentItemArray objectAtIndex:i];
        
        [vc.view removeFromSuperview];
    }
    
    if ([commentItemArray count] > 3) {
        [showButton removeFromSuperview];
    }
    
    [addCommentView.view removeFromSuperview];
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 308, 286)];
    [commentItemArray removeAllObjects];
    [activityView removeFromSuperview];
    [hashTWLabel removeFromSuperview];
    [usernameTWLabel removeFromSuperview];
    showCommentButtonFlag = FALSE;
    
    [self setStyle];
}

- (void) setStyle {
    playButton.clipsToBounds = YES;
    playButton.layer.cornerRadius = 31;
    ratingButton.clipsToBounds = YES;
    ratingButton.layer.cornerRadius = 73;
    
    [titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.f]];
    [hashLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [usernameLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [timeagoLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    
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
    [headerView addSubview:hashTWLabel];
    [headerView addSubview:usernameTWLabel];
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
    usernameTWLabel.text = [NSString stringWithFormat:@"@%@", username];

    NSString *hashtag = [data objectForKey:TAG_RES_RB_HASHTAG];
    hashLabel.text = [NSString stringWithFormat:@"#%@", hashtag];
    hashTWLabel.text = [NSString stringWithFormat:@"#%@", hashtag];
    
    NSString *description = [data objectForKey:TAG_RES_RB_CONTENT];
    titleLabel.text = description;
    
    NSString *timeAgo = [data objectForKey:TAG_RES_TIMEAGO];
    timeagoLabel.text = timeAgo;
    
    NSString *userPhotoUrl = [data objectForKey:TAG_RES_RB_PHOTO];
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
                
//                [[[AppSharedData sharedInstance] storeImage] setObject:image forKey:userPhotoUrl];
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
    
    videoURL = [data objectForKey:TAG_RES_VIDEOURL];
    videoScore = [[data objectForKey:TAG_RES_RB_VIDEO_SCORE] floatValue];
    videoID = [data objectForKey:TAG_RES_RB_VIDEO];
    
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
    
    
    
    userId = [data objectForKey:TAG_RES_RB_USER];
    
    
    //set Comment
    commentArray = [[NSMutableArray alloc] init];
    
    commentArray = [data objectForKey:TAG_RES_COMMENTLIST];
    
    commentItemArray = [[NSMutableArray alloc] init];
    heightArray = [[NSMutableArray alloc] init];
    
    int sn = (int)[commentArray count] - 3;
    
    if (sn < 0) {
        sn = 0;
    }
    
    for (int i = sn; i < [commentArray count]; i++) {
        NSDictionary *dict = [commentArray objectAtIndex:i];
        
        CommentViewController *commentViewController = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:Nil];
        
        [commentViewController setData:dict];
        [commentViewController setVideoNumber:number];
        [commentViewController setCommentNumber:i];
        
        [commentViewController viewDidAppear:YES];
        
        if (i == sn) {
            [commentViewController.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, commentViewController.view.frame.size.height)];
        }else {
            [commentViewController.view setFrame:CGRectMake(0, self.view.frame.size.height - 6, self.view.frame.size.width, commentViewController.view.frame.size.height)];
        }
        
        [heightArray addObject:[NSNumber numberWithFloat:commentViewController.view.frame.size.height]];
        
        
        [commentItemArray addObject:commentViewController];
        
        
        CommentViewController *vc = (CommentViewController *)[commentItemArray objectAtIndex:[commentItemArray count] - 1];
        
        [self.view addSubview:vc.view];
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + vc.view.frame.size.height)];
    }
    
    
    
    //add ShowAllComments Button
    
    if ([commentArray count] > 3) {
        
        showCommentButtonFlag = TRUE;
        
        [showButton removeFromSuperview];
        
        showButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autoreleased
        [showButton setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 35)];
        [showButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
        [showButton setTitle:[NSString stringWithFormat:@"Show all comments..."] forState:UIControlStateNormal];
        [showButton setTitleColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateNormal];
        [showButton addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
        [showButton setContentEdgeInsets:UIEdgeInsetsMake(0, -137, 0, 0)];
        [self.view addSubview:showButton];
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + showButton.frame.size.height)];
    }
    
    //add CommentViewController
    addCommentView = [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController" bundle:Nil];
    
    addCommentView.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, addCommentView.view.frame.size.height);
    [addCommentView setVideoID:videoID];
    [addCommentView setSupernumber:number];

    [addCommentView viewDidAppear:YES];
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 54)];
    
    [self.view addSubview:addCommentView.view];
    
    //set Score
    
    videoScore = [[data objectForKey:TAG_RES_RB_VIDEO_SCORE] floatValue];
    
    [self changeRatingButton];
    
    userScore = [[data objectForKey:TAG_RES_RB_CRED] floatValue];
    
    [self changeUserScoreImage];
    
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - viewSize / 2, self.view.frame.size.height / 2 - viewSize / 2, viewSize, viewSize)];
    activityView.hidden = YES;
    [self.view addSubview:activityView];
    
    viewHeight = self.view.frame.size.height;
}

- (IBAction)onReportButton:(id)sender {
    
    NSLog(@"ReportButton");
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    if ([userId isEqualToString:[[UserController instance] userUserID]]) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                 delegate:self
//                                                        cancelButtonTitle:@"Cancel"
//                                                   destructiveButtonTitle:nil
//                                                        otherButtonTitles:@"DELETE VIDEO", nil];
//        
//        [actionSheet showInView:navigationController.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHashtag:) name:@"HashtagChanged" object:Nil];
        
        DeleteVideoViewController *deleteView = [[DeleteVideoViewController alloc] initWithNibName:@"DeleteVideoViewController" bundle:nil];
        [deleteView setVideoID:videoID];
        [deleteView setNumber:number];
        
        UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
        [navigationController pushViewController:deleteView animated:YES];
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"REPORT VIDEO", nil];
        
        [actionSheet showInView:navigationController.view];
    }
    

    
}

- (IBAction)onShareButton:(id)sender {
    
//    NSLog(@"ShareButton");
//    
//    ShareVideoViewController *shareVideoViewController = [[ShareVideoViewController alloc] initWithNibName:@"ShareVideoViewController" bundle:Nil];
//    
//    [shareVideoViewController setVideoUrl:videoURL];
//    [shareVideoViewController setVideoId:videoID];
//    [shareVideoViewController setVideoTitle:titleLabel.text];
//    [shareVideoViewController setUsername:usernameLabel.text];
//    [shareVideoViewController setHashtag:hashLabel.text];
//    
//    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
//    [navigationController pushViewController:shareVideoViewController animated:YES];
    
    
    
    NSString *eVideoId = [ShareVideoViewController base64String:videoID];
    NSString *postUrl = [NSString stringWithFormat:@"%@/video.php?id=%@", SERVER_HOST, eVideoId];
    NSString *postData = [NSString stringWithFormat:@"%@ via %@ %@ %@", titleLabel.text, usernameLabel.text, hashLabel.text, postUrl];
    
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
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    [navigationController presentViewController:activityViewController animated:YES completion:nil];
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

- (IBAction)onRatingButton:(id)sender {
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

- (IBAction)onProfileViewButton:(id)sender {
    
    NSString *profileid = [NSString stringWithFormat:@"Profile%@", userId];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
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
        
        [profileViewController setUserId:userId];
        
        [navigationController pushViewController:profileViewController animated:YES];
    }
}

#pragma mark -
#pragma mark Change Rating Button Background Image with VideoScore

- (void) changeRatingButton {
    
    int score = (int) videoScore;
    
    float dm = videoScore - (float) score;
    
    if (dm >= 0.5) {
        score ++;
    }
    
    switch (score) {
        case 0:
            [ratingButton setBackgroundImage:[UIImage imageNamed:@"pieRed0.png"] forState:UIControlStateNormal];
            break;
            
        case 1:
            [ratingButton setBackgroundImage:[UIImage imageNamed:@"pieRed1.png"] forState:UIControlStateNormal];
            break;
            
        case 2:
            [ratingButton setBackgroundImage:[UIImage imageNamed:@"pieRed2.png"] forState:UIControlStateNormal];
            break;
            
        case 3:
            [ratingButton setBackgroundImage:[UIImage imageNamed:@"pieRed3.png"] forState:UIControlStateNormal];
            break;
            
        case 4:
            [ratingButton setBackgroundImage:[UIImage imageNamed:@"pieRed4.png"] forState:UIControlStateNormal];
            break;
            
        case 5:
            [ratingButton setBackgroundImage:[UIImage imageNamed:@"pieRed5.png"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }

}

#pragma mark -
#pragma mark NSNotification Function

- (void) changeVideoScoreImage: (NSNotification *) notification {
    
   
    
    NSString *changedVideoId = [[NSUserDefaults standardUserDefaults] objectForKey:@"changedVideoId"];
    float changedScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"changedScore"] floatValue];
    
    
    [data setValue:[NSNumber numberWithFloat:changedScore] forKey:TAG_RES_RB_VIDEO_SCORE];
    
    if ([changedVideoId isEqualToString:videoID]) {
        videoScore = changedScore;
        [self changeRatingButton];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VideoScoreChanged" object:Nil];
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
        videoScore = changedScore;
        [self changeRatingButton];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HashtagChanged" object:Nil];
    }
}

#pragma mark -
#pragma mark Change the User Score Image View 

- (void) changeUserScoreImage {

    int score = (int) userScore;
    
    float fractional = userScore - score;
    if(fractional > .5f)
        score++;
    
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

- (void) move_addCommentView: (float) step {
    [addCommentView.view setFrame:CGRectMake(addCommentView.view.frame.origin.x, addCommentView.view.frame.origin.y + step, addCommentView.view.frame.size.width, addCommentView.view.frame.size.height)];
}

- (void)handleButton:(id)sender {
    
    showCommentButtonFlag = FALSE;
    
    [self removeAllSubViews];
    
    int oheight = self.view.frame.size.height;
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, originFrame.size.width, originFrame.size.height)];
    
    [self refreshViewWithoutShowButton];
    
    int iheight = self.view.frame.size.height - oheight;
    
    
    NSString *superController = [[NSUserDefaults standardUserDefaults] objectForKey:@"SuperController"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:number] forKey:@"ShowCommentViewNumber"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:iheight] forKey:@"ShowCommentIncreaseHeight"];
    
    if ([superController isEqualToString:@"Home"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeShowCommentItem" object:Nil];
    }else if ([superController isEqualToString:@"Search"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchShowCommentItem" object:Nil];
    }else if ([superController isEqualToString:@"Profile"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileShowCommentItem" object:Nil];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchDetailShowCommentItem" object:Nil];
    }
    
    
}

- (float) addCommentItemView: (NSDictionary *) dict {
    
    if (!showCommentButtonFlag) {
        
        CommentViewController *commentViewController = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:Nil];
        
        [commentViewController setData:dict];
        
        [commentViewController viewDidAppear:YES];
        [commentViewController.view setFrame:CGRectMake(0, addCommentView.view.frame.origin.y, self.view.frame.size.width, commentViewController.view.frame.size.height)];
        [commentViewController setCommentNumber:(int)[commentItemArray count]];
        [commentViewController setVideoNumber:number];
        
        float pheight = commentViewController.view.frame.size.height;
        float rheight = self.view.frame.size.height;
        float aheight = addCommentView.view.frame.size.height;
        
        [commentItemArray addObject:commentViewController];
        [heightArray addObject:[NSNumber numberWithFloat:commentViewController.view.frame.size.height]];
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, rheight + pheight)];
        
        float nheight = self.view.frame.size.height;
        
        float sy = nheight - aheight;
        
        [addCommentView.view setFrame:CGRectMake(0, sy, self.view.frame.size.width, 54)];
        
        [self.view addSubview:addCommentView.view];
        
        float sumheight = 54;
        float startPos;
        
        for (int i = (int)[commentItemArray count] - 1; i >= 0; i--) {
            
            CommentViewController *cvc = (CommentViewController *)[commentItemArray objectAtIndex:i];
            pheight = [[heightArray objectAtIndex:i] floatValue];
            [cvc.view removeFromSuperview];
            startPos = self.view.frame.size.height - sumheight - pheight;
            [cvc.view setFrame:CGRectMake(cvc.view.frame.origin.x, startPos, cvc.view.frame.size.width, pheight)];
            [self.view addSubview:cvc.view];
            sumheight += cvc.view.frame.size.height;
        }
        
        return commentViewController.view.frame.size.height;
        
    }else {
        
        int oheight = self.view.frame.size.height;
        
        [self removeAllSubViews];
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, originFrame.size.width, originFrame.size.height)];
        
        [commentArray addObject:dict];
        [self refreshView];
        
        return self.view.frame.size.height - oheight;
    }
    
    return 0;
}

- (void) removeAllSubViews {
    
    for (int i = 0; i < [commentItemArray count]; i++) {
        CommentViewController *vc = (CommentViewController *)[commentItemArray objectAtIndex:i];
        [vc.view removeFromSuperview];
    }
    
    [showButton removeFromSuperview];
    showButton = NULL;
    [addCommentView.view removeFromSuperview];
    [commentItemArray removeAllObjects];
}

- (void) refreshView {
    
    [commentItemArray removeAllObjects];
    [heightArray removeAllObjects];
    
    int sn = (int)[commentArray count] - 3;
    
    if (sn < 0) {
        sn = 0;
    }
    
    for (int i = sn; i < [commentArray count]; i++) {
        NSDictionary *dict = [commentArray objectAtIndex:i];
        
        CommentViewController *commentViewController = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:Nil];
        
        [commentViewController setData:dict];
        [commentViewController setVideoNumber:number];
        [commentViewController setCommentNumber:i];
        
        [commentViewController viewDidAppear:YES];
        [commentViewController.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, commentViewController.view.frame.size.height)];
        
        [heightArray addObject:[NSNumber numberWithFloat:commentViewController.view.frame.size.height]];
        
        
        [commentItemArray addObject:commentViewController];
        
        
        CommentViewController *vc = (CommentViewController *)[commentItemArray objectAtIndex:[commentItemArray count] - 1];
        
        [self.view addSubview:vc.view];
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + vc.view.frame.size.height)];
    }
    
    
    
    //add ShowAllComments Button
    
    if ([commentArray count] > 3) {
        
        showCommentButtonFlag = TRUE;
        
        showButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autoreleased
        [showButton setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 25)];
        [showButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
        [showButton setTitle:[NSString stringWithFormat:@"Show all comments..."] forState:UIControlStateNormal];
        [showButton setTitleColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateNormal];
        [showButton addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
        [showButton setContentEdgeInsets:UIEdgeInsetsMake(0, -137, 0, 0)];
        [self.view addSubview:showButton];
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + showButton.frame.size.height)];
    }
    
    //add CommentViewController
    addCommentView = [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController" bundle:Nil];
    
    addCommentView.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, addCommentView.view.frame.size.height);
    [addCommentView setVideoID:videoID];
    [addCommentView setSupernumber:number];
    
    [addCommentView viewDidAppear:YES];
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 54)];
    
    [self.view addSubview:addCommentView.view];
    
}

- (void) refreshViewWithoutShowButton {
    
    [commentItemArray removeAllObjects];
    [heightArray removeAllObjects];
    
    for (int i = 0; i < [commentArray count]; i++) {
        NSDictionary *dict = [commentArray objectAtIndex:i];
        
        CommentViewController *commentViewController = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:Nil];
        
        [commentViewController setData:dict];
        [commentViewController setVideoNumber:number];
        [commentViewController setCommentNumber:i];
        
        [commentViewController viewDidAppear:YES];
        [commentViewController.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, commentViewController.view.frame.size.height)];
        
        [heightArray addObject:[NSNumber numberWithFloat:commentViewController.view.frame.size.height]];
        
        
        [commentItemArray addObject:commentViewController];
        
        
        CommentViewController *vc = (CommentViewController *)[commentItemArray objectAtIndex:[commentItemArray count] - 1];
        
        [self.view addSubview:vc.view];
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + vc.view.frame.size.height)];
    }
    
    
    //add CommentViewController
    addCommentView = [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController" bundle:Nil];
    
    addCommentView.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, addCommentView.view.frame.size.height);
    [addCommentView setVideoID:videoID];
    [addCommentView setSupernumber:number];
    
    [addCommentView viewDidAppear:YES];
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 54)];
    
    [self.view addSubview:addCommentView.view];
    
}

- (float) removeCommentItem:(int)commentNumber {
    
    if (!showCommentButtonFlag) {
        
        CommentViewController *vc = (CommentViewController *)[commentItemArray objectAtIndex:commentNumber];
        
        float iheight = vc.view.frame.size.height;
        
        [vc.view removeFromSuperview];
        
        [addCommentView.view removeFromSuperview];
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - vc.view.frame.size.height)];
        
        float sy = self.view.frame.size.height - addCommentView.view.frame.size.height;
        
        [addCommentView.view setFrame:CGRectMake(0, sy, self.view.frame.size.width, 54)];
        
        [self.view addSubview:addCommentView.view];
        
        float sumheight = 54;
        float startPos;
        float pheight;
        
        for (int i = (int)[commentItemArray count] - 1; i >= 0; i--) {
            if (i == commentNumber) {
                continue;
            }
            
            CommentViewController *cvc = (CommentViewController *)[commentItemArray objectAtIndex:i];
            pheight = [[heightArray objectAtIndex:i] floatValue];
            [cvc.view removeFromSuperview];
            startPos = self.view.frame.size.height - sumheight - pheight;
            [cvc.view setFrame:CGRectMake(cvc.view.frame.origin.x, startPos, cvc.view.frame.size.width, pheight)];
            if (i > commentNumber) {
                [cvc setCommentNumber:cvc.commentNumber - 1];
            }
            [self.view addSubview:cvc.view];
            sumheight += cvc.view.frame.size.height;
        }
        
        
        [commentItemArray removeObjectAtIndex:commentNumber];
        [heightArray removeObjectAtIndex:commentNumber];
        
        return iheight;

    }else {
        
        int cn = commentNumber;
        
        commentNumber -= [commentArray count] - [commentItemArray count];
        
        [commentArray removeObjectAtIndex:cn];
        
        CommentViewController *vc = (CommentViewController *)[commentItemArray objectAtIndex:commentNumber];
        
        float iheight = vc.view.frame.size.height;
        
        [vc.view removeFromSuperview];
        
        [addCommentView.view removeFromSuperview];
        [showButton removeFromSuperview];
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - vc.view.frame.size.height)];
        
        float sy = self.view.frame.size.height - addCommentView.view.frame.size.height;
        
        [addCommentView.view setFrame:CGRectMake(0, sy, self.view.frame.size.width, 54)];
        
        [self.view addSubview:addCommentView.view];
        
        [showButton setFrame:CGRectMake(showButton.frame.origin.x, showButton.frame.origin.y - iheight, showButton.frame.size.width, showButton.frame.size.height)];
        [self.view addSubview:showButton];
        
        float sumheight = 54 + showButton.frame.size.height;
        float startPos;
        float pheight;
        
        for (int i = (int)[commentItemArray count] - 1; i >= 0; i--) {
            if (i == commentNumber) {
                continue;
            }
            
            CommentViewController *cvc = (CommentViewController *)[commentItemArray objectAtIndex:i];
            pheight = [[heightArray objectAtIndex:i] floatValue];
            [cvc.view removeFromSuperview];
            startPos = self.view.frame.size.height - sumheight - pheight;
            [cvc.view setFrame:CGRectMake(cvc.view.frame.origin.x, startPos, cvc.view.frame.size.width, pheight)];
            if (i > commentNumber) {
                [cvc setCommentNumber:cvc.commentNumber - 1];
            }
            [self.view addSubview:cvc.view];
            sumheight += cvc.view.frame.size.height;
        }
        
        [commentItemArray removeObjectAtIndex:commentNumber];
        [heightArray removeObjectAtIndex:commentNumber];
        
        return iheight;
        
    }
    
    return 0;
}

- (void) resetFrame {
    float maxheight = 0;
    for (UIView *child in self.view.subviews) {
        if (maxheight < child.frame.origin.y + child.frame.size.height) {
            maxheight = child.frame.origin.y + child.frame.size.height;
        }
    }
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, maxheight)];
}

#pragma mark - UIActionSheet Delegate Functions

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        if ([userId isEqualToString:[[UserController instance] userUserID]]) {
            [self requestDeleteVideo];
        }else {
            [self requestReportVideo];
        }
    }
    
}

#pragma mark - Request Functions
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
    
    requestType = REQUEST_VIDEO_COMMAND;
    
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
    
    requestType = REQUEST_VIDEO_COMMAND;
    
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
        
        if ([requestType isEqualToString:REQUEST_VIDEO_COMMAND]) {
        
            if ([userId isEqualToString:[[UserController instance] userUserID]]) {
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
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your report has been sent successfully." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                [alert show];
            }
        }else if ([requestType isEqualToString:REQUEST_USERID]) {
            NSString *uId = [dict objectForKey:TAG_RES_USERID];
            
            NSString *profileid = [NSString stringWithFormat:@"Profile%@", uId];

            UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
            
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
    
    [self endLoading];
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}


#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    [activityView setFrame:CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height / 2 - 40, 80, 80)];
    [activityView startAnimation];
    activityView.hidden = NO;
    activityView.alpha = 1;
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
#pragma mark NSNotication Functions

- (void) showSearchView: (NSNotification *) notification {
    
    int linkCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"linkCount"] intValue];
    
    if (linkCount != 0) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"linkCount"];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    
    NSString *searchText = [[[NSUserDefaults standardUserDefaults] objectForKey:IFTweetLabelButtonTitle] substringFromIndex:1];
    
    [searchViewController setSearchText:searchText];
    
    [navigationController pushViewController:searchViewController animated:YES];
    
    
}


@end
