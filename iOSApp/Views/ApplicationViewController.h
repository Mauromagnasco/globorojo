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

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "CustomActivityIndicatorView.h"

@interface ApplicationViewController : UIViewController<UIActionSheetDelegate> {
    
    REMenu *menu;
    CustomActivityIndicatorView *activityView;
    
    NSString *param1;//site login :userid    facebook : facebook_token    twitter : twitter_oauth_token
    NSString *param2;//site login : secret key    facebook : facebook_id    twitter : twitter_id
    NSString *param3;//site login : N/A    facebook : facebook_name    twitter : twitter_name
    NSString *param4;//site login : N/A    facebook : facebook_email    twitter : twitter_token_secret
    NSString *param5;//site login : N/A    facebook : facebook_email    twitter : twitter_token_secret
    NSString *param6;//site login : N/A    facebook : facebook_img    twitter : twitter_img
    NSString *param7;//site login : N/A    facebook : facebook_friends (friend count ex : 10)    twitter : N/A
    
    NSString *requestType;
    NSMutableData *revcData;
    
    NSString *connectFacebook;
    NSString *connectTwitter;
 
    int socialType;
}


@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *connectFBButton;
@property (strong, nonatomic) IBOutlet UIButton *connectTWButton;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *mainContentView;

@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) REMenu *menu;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *connectFacebook;
@property (nonatomic, retain) NSString *connectTwitter;



- (IBAction)onBackButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (IBAction)onConnectFBButton:(id)sender;
- (IBAction)onConnectTWButton:(id)sender;


@end
