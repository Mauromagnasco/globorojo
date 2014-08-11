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

#import "ProfileDetailViewController.h"
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

@interface ProfileDetailViewController ()

@end

@implementation ProfileDetailViewController

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
@synthesize userId;
@synthesize followButton;

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

- (void)viewWillAppear:(BOOL)animated {
    [self setStyle];
    [self setButtonType:3];
    [self requestUserInfo];
}

#pragma mark -
#pragma mark Set Style Functions

- (void) setStyle {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    activityView.hidden = YES;
    
    scrollView.userInteractionEnabled = YES;
    scrollView.delegate = self;
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:20.0]];
    [videosHomeButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
    [meritButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
    [videoCountLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:32.0]];
    [followerCountLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:32.0]];
    [followingCountLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:32.0]];
    [followButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:15.0]];
}

- (void) setButtonType: (int) type {
    
    switch (type) {
        case 1:
            videosHomeButton.backgroundColor = [UIColor redColor];
            videosHomeButton.titleLabel.textColor = [UIColor whiteColor];
            [videosListButton setBackgroundImage:[UIImage imageNamed:@"btnListRed.png"] forState:UIControlStateNormal];
            [videosDetailButton setBackgroundImage:[UIImage imageNamed:@"btnDetailGrey.png"] forState:UIControlStateNormal];
            meritButton.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
            meritButton.titleLabel.textColor = [UIColor whiteColor];
            break;
            
        case 2:
            videosHomeButton.backgroundColor = [UIColor redColor];
            videosHomeButton.titleLabel.textColor = [UIColor whiteColor];
            [videosListButton setBackgroundImage:[UIImage imageNamed:@"btnListGrey.png"] forState:UIControlStateNormal];
            [videosDetailButton setBackgroundImage:[UIImage imageNamed:@"btnDetailRed.png"] forState:UIControlStateNormal];
            meritButton.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
            meritButton.titleLabel.textColor = [UIColor whiteColor];
            
            break;
            
        case 3:
            videosHomeButton.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
            videosHomeButton.titleLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
            [videosListButton setBackgroundImage:[UIImage imageNamed:@"btnListGrey.png"] forState:UIControlStateNormal];
            [videosDetailButton setBackgroundImage:[UIImage imageNamed:@"btnDetailGrey.png"] forState:UIControlStateNormal];
            meritButton.backgroundColor = [UIColor redColor];
            meritButton.titleLabel.textColor = [UIColor whiteColor];
            
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark IBAction Functions

- (IBAction)onBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onVideosCountButton:(id)sender {
}

- (IBAction)onFollowersCountButton:(id)sender {
    FollowsViewController *followsViewController = [[FollowsViewController alloc] initWithNibName:@"FollowsViewController" bundle:Nil];
    
    [self.navigationController pushViewController:followsViewController animated:YES];
}

- (IBAction)onFollowingCountButton:(id)sender {
    
    FollowingViewController *followingViewController = [[FollowingViewController alloc] initWithNibName:@"FollowingViewController" bundle:Nil];
    
    [self.navigationController pushViewController:followingViewController animated:YES];
}

- (IBAction)onFollowButton:(id)sender {
}

- (IBAction)onVideosHomeButton:(id)sender {
    
    [self setButtonType:1];
    
}

- (IBAction)onVideosListButton:(id)sender {
    
    [self setButtonType:1];
    
    
}

- (IBAction)onVideosDetailButton:(id)sender {
    
    [self setButtonType:2];
    
    
}

- (IBAction)onMeritButton:(id)sender {
    
    [self setButtonType:3];
    
}

#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
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
#pragma mark Request Functions
- (void) requestUserInfo {
    
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_USER_PROFILE_INFO_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_USERID, userId];
    
    
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
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        videoCountLabel.text = [dict objectForKey:TAG_RES_CNTVIDEOS];
        followerCountLabel.text = [dict objectForKey:TAG_RES_CNTFOLLOWERS];
        followingCountLabel.text = [dict objectForKey:TAG_RES_CNTFOLLOWING];
        
        NSString *userPhotoUrl = [dict objectForKey:TAG_RES_PHOTO];
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
                    
//                    [[[AppSharedData sharedInstance] storeImage] setObject:image forKey:userPhotoUrl];
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
        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        if ([errorMsg isEqualToString:@""]) {
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
    }
}
-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
