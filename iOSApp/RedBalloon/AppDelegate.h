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
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "REMenu.h"

#define kSocialAccountTypeKey @"SOCIAL_ACCOUNT_TYPE"

typedef enum SocialAccountType  {
    SocialAccountTypeNone = 0,
    SocialAccountTypeFacebook = 1,
    SocialAccountTypeTwitter = 2
} SocialAccountType;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>


@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (weak, nonatomic) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) REMenu *menu;
@property (nonatomic, retain) REMenu *smenu;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic) int type;
@property (nonatomic) NSString *sid;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)getTwitterAccountOnCompletion:(void(^)(ACAccount *))completionHandler;

- (void)openFacebookSession;
- (void)closeFacebookSession;
- (void) toggleMenu;
- (void) setMenuItems;

@end
