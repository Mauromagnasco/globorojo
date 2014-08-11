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

#import "NotificationItemViewController.h"
#import "Constants.h"
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AppSharedData.h"
#import "MTHTTPClient.h"

@interface NotificationItemViewController ()

@end

@implementation NotificationItemViewController

@synthesize profileImageView;
@synthesize timeagoLabel;
@synthesize contentLabel;
@synthesize titleLabel;
@synthesize data;

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
    [self parseData];
}


- (void) parseData {
    NSString *userPhotoUrl = [data objectForKey:TAG_RES_RB_SENDER_PHOTO];
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
    
    contentLabel = [[IFNotiLabel alloc] initWithFrame:CGRectMake(89, 40, 180, 17)];
    contentLabel.linksEnabled = YES;
    [contentLabel setButtonFontColor:[UIColor colorWithRed:(103.0/255.0) green:(103.0/255.0) blue:(103.0/255.0) alpha:1.0]];
    [contentLabel setButtonFontSize:13.0];
    [contentLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [contentLabel setTextColor:[UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0]];
	[contentLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:contentLabel];
    contentLabel.hidden = YES;

    
    NSString *content = [data objectForKey:TAG_RES_RB_CONTENT];
    if(![content isEqual: [NSNull null]]) {
        content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        contentLabel.text = content;
    }else {
        content = @"";
    }

 
    titleLabel = [[IFNotiLabel alloc] initWithFrame:CGRectMake(86, 14, 0, 30)];
    titleLabel.linksEnabled = YES;
    [titleLabel setButtonFontColor:[UIColor colorWithRed:(103.0/255.0) green:(103.0/255.0) blue:(103.0/255.0) alpha:1.0]];
    
    [titleLabel setButtonFontSize:14.0];
    [titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [titleLabel setTextColor:[UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setVideoId:[data objectForKey:TAG_RES_RB_VIDEO]];
    [self.view addSubview:titleLabel];
    
    NSString *username = [data objectForKey:TAG_RES_RB_SENDER_USERNAME];
    
    int rb_type = [[data objectForKey:TAG_RES_RB_TYPE] intValue];
    
    [titleLabel setRb_type:rb_type];
    [titleLabel setData:data];
    
    switch (rb_type) {
        case 1:
            titleLabel.text = [NSString stringWithFormat:@"@%@ commented your post.", username];
            break;
            
        case 2:
            titleLabel.text = [NSString stringWithFormat:@"@%@ scored your post: %@", username, content];
            break;
            
        case 3:
            [titleLabel setText:[NSString stringWithFormat:@"@%@ is following you: %@", username, content]];
            break;
            
        case 4:
            titleLabel.text = [NSString stringWithFormat:@"@%@ mentioned you: %@", username, content];
            break;
            
        case 5:
            [titleLabel setText:[NSString stringWithFormat:@"@%@ is unfollowing you: %@", username, content]];
            break;
        default:
            break;
    }
    
    NSString *timeAgo = [data objectForKey:TAG_RES_TIMEAGO];
    timeagoLabel.text = timeAgo;
}

- (IBAction)onBodyButton:(id)sender {
    
    int rb_type = [[data objectForKey:TAG_RES_RB_TYPE] intValue];
    if (rb_type != 3 && rb_type != 5) {
        [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:TAG_RES_RB_VIDEO] forKey:@"PostVideoId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelPostNotification object:Nil];
    }else {
        NSString *username = [data objectForKey:TAG_RES_RB_SENDER_USERNAME];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"@%@", username] forKey:IFNotiLabelButtonTitle];
        [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelUserNotification object:Nil];
    }
}

- (IBAction)onThumbButton:(id)sender {
    NSString *username = [data objectForKey:TAG_RES_RB_SENDER_USERNAME];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"@%@", username] forKey:IFNotiLabelButtonTitle];
    [[NSNotificationCenter defaultCenter] postNotificationName:IFNotiLabelUserNotification object:Nil];
}
@end
