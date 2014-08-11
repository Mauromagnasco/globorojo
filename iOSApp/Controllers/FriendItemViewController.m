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

#import "FriendItemViewController.h"
#import "Constants.h"
#import "MTHTTPClient.h"
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AppSharedData.h"
#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "UserController.h"
#import "SBJson.h"


#define REQUEST_FOR_FOLLOW                      @"follow"

@interface FriendItemViewController ()

@end

@implementation FriendItemViewController

@synthesize usernameLabel;
@synthesize nameLabel;
@synthesize credLabel;
@synthesize data;
@synthesize profileImageView;
@synthesize contentView;
@synthesize number;
@synthesize scoreImageView;
@synthesize followerButton;
@synthesize followingButton;
@synthesize isFollowing;
@synthesize recvData;
@synthesize requestType;
@synthesize userId;
@synthesize followingCount;

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
    [self parseData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (void) parseData {
    
    userId = [data objectForKey:TAG_RES_RB_USER];
    
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
    
    nameLabel.text = [data objectForKey:TAG_RES_RB_NAME];
    credLabel.text = [NSString stringWithFormat:@"Merit: %.3f", [[data objectForKey:TAG_RES_RB_CRED] floatValue]];
    
    [nameLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.0]];
    [credLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.0]];
    
    usernameLabel = [[IFNotiLabel alloc] initWithFrame:CGRectMake(83, 0, 148, 21)];
    usernameLabel.linksEnabled = YES;
    [usernameLabel setButtonFontColor:[UIColor colorWithRed:(52.0/255.0) green:(52.0/255.0) blue:(52.0/255.0) alpha:1.0]];
    [usernameLabel setButtonFontSize:14.0];
    [usernameLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [usernameLabel setTextColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
	[usernameLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:usernameLabel];
    
    NSString *username = [data objectForKey:TAG_RES_RB_USERNAME];
    
    usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
    
    [self.contentView addSubview:usernameLabel];
    
    float userscore = [[data objectForKey:TAG_RES_RB_CRED] floatValue];
    
    [self changeVideoScoreImage:userscore];
}

#pragma mark -
#pragma mark Change the User Score Image View

- (void) changeVideoScoreImage: (float) videoScore {
    
    int score = (int) videoScore;
    
    float mv = videoScore - (float) score;
    
    if (mv >= 0.5) {
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


#pragma mark -
#pragma mark Request Methods
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
                followingCount ++;
                [followingButton setBackgroundImage:[UIImage imageNamed:@"leftRedArrow.png"] forState:UIControlStateNormal];
            }else {
                [followingButton setBackgroundImage:[UIImage imageNamed:@"leftWhiteArrow.png"] forState:UIControlStateNormal];
                
                followingCount --;
            }
            
            [[[AppSharedData sharedInstance] scoreRecord] setObject:[NSNumber numberWithInt:followingCount] forKey:userId];
            
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
