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

#import "RBUserListViewController.h"
#import "Constants.h"
#import "ProfileDetailViewController.h"
#import "AppDelegate.h"
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AppSharedData.h"
#import "MTHTTPClient.h"
#import "ProfileViewController.h"
#import "UserController.h"
#import "SBJson.h"
#import "SearchViewController.h"


#define REQUEST_FOR_FOLLOW                      @"follow"

@interface RBUserListViewController ()

@end

@implementation RBUserListViewController

@synthesize userNameLabel;
@synthesize nameLabel;
@synthesize credRankLabel;
@synthesize profileImageView;
@synthesize scoreImageView;

@synthesize number;
@synthesize data;
@synthesize recvData;
@synthesize followerButton;
@synthesize followingButton;
@synthesize userId;
@synthesize requestType;
@synthesize isFollowing;

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
    [nameLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [userNameLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [credRankLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    
    [self parseData];
}

#pragma mark-
#pragma mark Parse Data
- (void) parseData {
    
    NSString *username  = [data objectForKey:TAG_RES_RB_USERNAME];
    userNameLabel.text = [NSString stringWithFormat:@"@%@", username];
    
    NSString *name = [data objectForKey:TAG_RES_RB_NAME];
    if ([name isEqualToString:@""]) {
        nameLabel.hidden = YES;
        credRankLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, credRankLabel.frame.size.width, credRankLabel.frame.size.height);
    }else {
        nameLabel.text = [NSString stringWithFormat:@"%@", name];
    }
    
    float userScore = [[data objectForKey:TAG_RES_RB_CRED] floatValue];
    credRankLabel.text = [NSString stringWithFormat:@"merit: %.3f", userScore];
    
    
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
    
    isFollowing = [data objectForKey:TAG_RES_ISFOLLOWER];
    
    if ([isFollowing isEqualToString:@"Y"]) {
        [followingButton setBackgroundImage:[UIImage imageNamed:@"leftRedArrow.png"] forState:UIControlStateNormal];
    }else {
        [followingButton setBackgroundImage:[UIImage imageNamed:@"leftWhiteArrow.png"] forState:UIControlStateNormal];
    }
    
    NSString *isFollower = [data objectForKey:TAG_RES_ISFOLLOWING];
    
    if ([isFollower isEqualToString:@"Y"]) {
        [followerButton setBackgroundImage:[UIImage imageNamed:@"redRightArrow.png"] forState:UIControlStateNormal];
    }else {
        [followerButton setBackgroundImage:[UIImage imageNamed:@"rightWhiteArrow.png"] forState:UIControlStateNormal];
    }
    
    userId = [data objectForKey:TAG_RES_RB_USER];
    
    [self changeUserScoreImage: userScore];
    
}

#pragma mark -
#pragma mark Change the User Score Image View

- (void) changeUserScoreImage: (float) userScore {
    
    int score = (int) userScore;
    
    float mm = userScore - (float) score;
    
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
    ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:Nil];
    
    [profileViewController setUserId:[data objectForKey:TAG_RES_RB_USER]];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    [navigationController pushViewController:profileViewController animated:YES];
}

- (IBAction)onFollowingButton:(id)sender {
    
 
    if ([isFollowing isEqualToString:@"Y"]) {
        [self requestFollowSetting:@"UNFOLLOW"];
    }else {
        [self requestFollowSetting:@"FOLLOW"];
    }
    
}

- (void) requestFollowSetting:(NSString *) type  {
    
    [[SearchViewController sharedInstance] startLoading];
    
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

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    //    if ([requestType isEqualToString:REQUEST_VIDEO_ITEM_URL]) {
    //        [self endLoading];
    //    }
    
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
    
    dict = (NSDictionary*)[jsonParser objectWithString:text];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    [[SearchViewController sharedInstance] endLoading];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:REQUEST_FOR_FOLLOW]) {
            
            if ([isFollowing isEqualToString:@"Y"]) {
                isFollowing = @"N";
            }else {
                isFollowing = @"Y";
            }
            
            if ([isFollowing isEqualToString:@"Y"]) {
                [followingButton setBackgroundImage:[UIImage imageNamed:@"leftRedArrow.png"] forState:UIControlStateNormal];
            }else {
                [followingButton setBackgroundImage:[UIImage imageNamed:@"leftWhiteArrow.png"] forState:UIControlStateNormal];
            }
            
        }
    }else {
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[SearchViewController sharedInstance] endLoading];
    
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

@end
