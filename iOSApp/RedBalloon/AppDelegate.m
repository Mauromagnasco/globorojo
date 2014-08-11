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

#import "AppDelegate.h"
#import <Accounts/Accounts.h>
#import "AppSharedData.h"
#import "HomeViewController.h"
#import "SearchViewController.h"
#import "SearchVideoDetailViewController.h"
#import "CreateVideoItemViewController.h"
#import "NotificationViewController.h"
#import "CreateVideoItemViewController.h"
#import "ProfileViewController.h"
#import "WelcomeViewController.h"
#import <Instabug/Instabug.h>
#import "VideoPlayViewController.h"
#import "MTDropDownView.h"
#import "NotificationViewController.h"
#import "UserController.h"
#import "Constants.h"
#import "SBJson.h"
#import <AVFoundation/AVFoundation.h>

#define REQUEST_VIDEO_INFO                   @"videoInfo"
#define REQUEST_DELETE_DEV_TOKEN             @"deleteDeviceId"
#define REQUEST_GET_HASHTAG                  @"getHashtagList"


@implementation AppDelegate

@synthesize navigationController;
@synthesize window;
@synthesize requestType;
@synthesize recvData;
@synthesize type;
@synthesize sid;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"AppDelegate" forKey:@"lastView"];
    
    [Instabug KickOffWithToken:@"363a13f74fd9731fed537a1e8a4f89db" CaptureSource:InstabugCaptureSourceUIKit FeedbackEvent:InstabugFeedbackEventShake IsTrackingLocation:YES];

    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Found a cached session");
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        
        // If there's no cached session, we will show a login button
    }
    
    //set Menu Item
    
    [self setMenuItems];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //set period to default
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:3] forKey:@"period"];
    
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        
//        
//        self.window.clipsToBounds =YES;
//        self.window.frame =  CGRectMake(0,20, self.window.frame.size.width,self.window.frame.size.height - 20);
//        
//        //Added on 19th Sep 2013
//        NSLog(@"%f",self.window.frame.size.height);
//        self.window.bounds = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
//    }
    
    
    int count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"hashTagCount"] intValue];
    NSDate *lastUpdatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"HashtagUpdatedDate"];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval secondsBetween = [currentDate timeIntervalSinceDate:lastUpdatedDate];
    int numberOfDays = secondsBetween / 86400;
    
    if (count != 0 && numberOfDays <= 1) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"hashTagArray.plist"]; //3
        
        NSArray *hashArray = [[NSArray alloc] initWithContentsOfFile:path];
        for (int i = 0; i < [hashArray count]; i ++) {
            NSDictionary *hashList = [hashArray objectAtIndex:i];
            NSString *key = [[[hashList allKeys] objectAtIndex:0] lowercaseString];
            NSString *value = [hashList objectForKey:key];
            
            [[[AppSharedData sharedInstance] dHashtagList] setObject:value forKey:key];
        }
        
        
    }else {
        [self requestDefaultHashtag];
    }
    
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
	NSString *newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"deviceToken"];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (![[UserController instance] userUserID]) {
        return;
    }

    NSString *msg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];

    type = [[[userInfo objectForKey:@"aps"] objectForKey:@"type"] intValue];
    sid = [[userInfo objectForKey:@"aps"] objectForKey:@"id"];
    int badge = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    
    NSString *currentView = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentView"];
    
    if ([currentView isEqualToString:@"Home"]) {
        [[HomeViewController sharedInstance] setNotiButton_Red];
    }else if ([currentView isEqualToString:@"Search"]) {
        [[SearchViewController sharedInstance] setNotiButton_Red];
    }else if ([currentView isEqualToString:@"SearchDetail"]) {
        [[SearchVideoDetailViewController sharedInstance] setNotiButton_Red];
    }else if ([currentView isEqualToString:@"Create"]) {
        [[CreateVideoItemViewController sharedInstance] setNotiButton_Red];
    }else if ([currentView isEqualToString:@"Profile"]) {
        [[ProfileViewController sharedInstance] setNotiButton_Red];
    }
    
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        
        if (![currentView isEqualToString:@"Notification"]) {
            [self showNotiView];
        }else {
            [[NotificationViewController sharedInstance] clear];
            [[NotificationViewController sharedInstance] requestRead];
        }
    } else if([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        if (![currentView isEqualToString:@"Notification"]) {
            [self showNotiView];
        }else {
            [[NotificationViewController sharedInstance] clear];
            [[NotificationViewController sharedInstance] requestRead];
        }
    } else {
        [MTDropDownView showDropDownViewInView:navigationController.view text:msg animated:YES target:self selector:@selector(showNotiView) hideAfter:4];
    }
}

- (void) showNotiView {
//    NotificationViewController *notiView = [[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:nil];

//    NSString *currentView = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentView"];
//    
//    if (![currentView isEqualToString:@"Notification"]) {
//        [navigationController pushViewController:notiView animated:YES];
//    }else {
//        [[NotificationViewController sharedInstance] clear];
//        [[NotificationViewController sharedInstance] requestRead];
//    }
    
    if (type == 3 || type == 5) {
        ProfileViewController *profileView = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        [profileView setUserId:sid];
        
        [navigationController pushViewController:profileView animated:YES];
    }else {
        [self requestVideoInfo];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)closeFacebookSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
    
    NSLog(@"%@", [[session accessTokenData] accessToken]);
    
    NSString *accessToken = [[session accessTokenData] accessToken];
    [[AppSharedData sharedInstance] setFacebookToken:accessToken];
    
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
                
                
                [[FBRequest requestForMe] startWithCompletionHandler:
                 ^(FBRequestConnection *connection,
                   NSDictionary<FBGraphUser> *user,
                   NSError *error) {
                     if (!error) {
                         
                         NSLog(@"%@",user);
                         
                         [[AppSharedData sharedInstance] setFacebookInfo:user];
                         
                     }}];
                break;
            case FBSessionStateClosed:
                break;
            case FBSessionStateClosedLoginFailed:
                [[FBSession activeSession] closeAndClearTokenInformation];
                
                break;
            default:
                break;
            }
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:error.localizedDescription
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
            
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    [FBSession.activeSession handleOpenURL:url];
    return YES;
}

#pragma mark - Other
- (void)restoreLastSessionIfExists {
    SocialAccountType lastActiveSocialAccountType = [[NSUserDefaults standardUserDefaults] integerForKey:kSocialAccountTypeKey];
    if(lastActiveSocialAccountType == SocialAccountTypeFacebook) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            //The session has not expired so this will not create any visible UI activity.
            [self openFacebookSession];
        }
    } else if(lastActiveSocialAccountType == SocialAccountTypeTwitter) {
        [self getTwitterAccountOnCompletion:^(ACAccount *twitterAccount){
            //If we successfully retrieved a Twitter account
            if(twitterAccount) {
                //Make sure anything UI related happens on the main queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    // HomeViewController *homeViewController = [[HomeViewController alloc] initWithSocialAccountType:SocialAccountTypeTwitter];
                    // [self.navigationController pushViewController:homeViewController animated:YES];
                });
            }
        }];
    }
}

#pragma mark - Facebook SDK
- (void)openFacebookSession {
    NSArray *facebookPermissions = [NSArray arrayWithObjects:@"user_about_me", @"user_status", nil];
    /* [FBSession sessionOpenWithPermissions:facebookPermissions completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
     [self sessionStateChanged:session state:state error:error];
     }];
     */
    [FBSession openActiveSessionWithReadPermissions:facebookPermissions
                                       allowLoginUI:NO
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      // Handler for session state changes
                                      // This method will be called EACH time the session state changes,
                                      // also for intermediate states and NOT just when the session open
                                      [self sessionStateChanged:session state:state error:error];
                                  }];
    
}

#pragma mark - Twitter SDK
- (void)getTwitterAccountOnCompletion:(void (^)(ACAccount *))completionHandler {
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [store requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            // Remember that twitterType was instantiated above
            NSArray *twitterAccounts = [store accountsWithAccountType:twitterType];
            
            // If there are no accounts, we need to pop up an alert
            if(twitterAccounts == nil || [twitterAccounts count] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                                message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
                //Get the first account in the array
                ACAccount *twitterAccount = [twitterAccounts objectAtIndex:0];
                //Save the used SocialAccountType so it can be retrieved the next time the app is started.
                [[NSUserDefaults standardUserDefaults] setInteger:SocialAccountTypeTwitter forKey:kSocialAccountTypeKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //Call the completion handler so the calling object can retrieve the twitter account.
                completionHandler(twitterAccount);
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                            message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}


#pragma mark -
#pragma mark Set Menu Items

- (void) setMenuItems {
    
    
    __block NSString *currentView = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentView"];
    
    __block NSArray *viewControllers = [self.navigationController viewControllers];
    
    
    REMenuItem *watchItem = [[REMenuItem alloc] initWithTitle:@"WATCH"
                                                        image:[UIImage imageNamed:@"watchMenu.png"]
                                             highlightedImage:nil
                                                       action:^(REMenuItem *item) {
                                                           NSLog(@"Item: %@", item);
                                                           if (![currentView isEqualToString:@"Search"]) {
                                                               UIViewController *vc;
                                                               int i;
                                                               
                                                               for (i = [viewControllers count] - 2; i >= 0; i--) {
                                                                   vc = [viewControllers objectAtIndex:i];
                                                                   
                                                                   if ([vc isKindOfClass:[SearchViewController class]]) {
                                                                       break;
                                                                   }
                                                               }
                                                               
                                                               if (i < 0) {
                                                                   SearchViewController *controller = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
                                                                   [navigationController pushViewController:controller animated:YES];
                                                               }else {
                                                                   [navigationController popToViewController:vc animated:YES];
                                                               }
                                                           }
                                                       }];
    
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"HOME"
                                                       image:[UIImage imageNamed:@"homeMenu.png"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          if (![currentView isEqualToString:@"Home"]) {
                                                              HomeViewController *controller = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
                                                              [navigationController pushViewController:controller animated:YES];
                                                              
                                                          }
                                                      }];
    
    REMenuItem *searchItem = [[REMenuItem alloc] initWithTitle:@"SEARCH"
                                                         image:[UIImage imageNamed:@"searchMenu.png"]
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            NSLog(@"Item: %@", item);
                                                            if (![currentView isEqualToString:@"Search"]) {
                                                                SearchViewController *controller = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
                                                                [navigationController pushViewController:controller animated:YES];
                                                            }
                                                        }];
    
    REMenuItem *notiItem = [[REMenuItem alloc] initWithTitle:@"NOTIFICATIONS"
                                                       image:[UIImage imageNamed:@"notiMenu.png"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          if (![currentView isEqualToString:@"Notification"]) {
                                                              UIViewController *vc;
                                                              int i;
                                                              
                                                              for (i = [viewControllers count] - 2; i >= 0; i--) {
                                                                  vc = [viewControllers objectAtIndex:i];
                                                                  
                                                                  if ([vc isKindOfClass:[NotificationViewController class]]) {
                                                                      break;
                                                                  }
                                                              }
                                                              
                                                              if (i < 0) {
                                                                  NotificationViewController *controller = [[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:nil];
                                                                  [navigationController pushViewController:controller animated:YES];
                                                              }else {
                                                                  [navigationController popToViewController:vc animated:YES];
                                                              }
                                                          }
                                                      }];
    
    REMenuItem *createItem = [[REMenuItem alloc] initWithTitle:@"SHARE"
                                                         image:[UIImage imageNamed:@"createMenu.png"]
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            NSLog(@"Item: %@", item);
                                                            if (![currentView isEqualToString:@"Create"]) {
                                                               
                                                                UIViewController *vc;
                                                                int i;
                                                                
                                                                for (i = [viewControllers count] - 2; i >= 0; i--) {
                                                                    vc = [viewControllers objectAtIndex:i];
                                                                    
                                                                    if ([vc isKindOfClass:[CreateVideoItemViewController class]]) {
                                                                        break;
                                                                    }
                                                                }
                                                                
                                                                if (i < 0) {
                                                                    CreateVideoItemViewController *controller = [[CreateVideoItemViewController alloc] initWithNibName:@"CreateVideoItemViewController" bundle:nil];
                                                                    [navigationController pushViewController:controller animated:YES];
                                                                }else {
                                                                    [navigationController popToViewController:vc animated:YES];
                                                                }
                                                            }
                                                        }];
    
    REMenuItem *profileItem = [[REMenuItem alloc] initWithTitle:@"PROFILE"
                                                          image:[UIImage imageNamed:@"profileMenu.png"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             if (![currentView isEqualToString:@"Profile"]) {

                                                                 UIViewController *vc;
                                                                 int i;
                                                                 
                                                                 for (i = [viewControllers count] - 2; i >= 0; i--) {
                                                                     vc = [viewControllers objectAtIndex:i];
                                                                     
                                                                     if ([vc isKindOfClass:[ProfileViewController class]]) {
                                                                         break;
                                                                     }
                                                                 }
                                                                 
                                                                 if (i < 0) {
                                                                     ProfileViewController *controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
                                                                     [navigationController pushViewController:controller animated:YES];
                                                                 }else {
                                                                     [navigationController popToViewController:vc animated:YES];
                                                                 }
                                                             }
                                                         }];
    
    REMenuItem *logoutItem = [[REMenuItem alloc] initWithTitle:@"LOG OUT"
                                                         image:[UIImage imageNamed:@"logoutMenu.png"]
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                                                            [alert show];
                                                        }];
    
    
    REMenuItem *dayItem = [[REMenuItem alloc] initWithTitle:@"Day"
                                                      image:nil
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"period"];
                                                         NSString *currentView = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentView"];
                                                         
                                                        
                                                         if ([currentView isEqualToString:@"Home"]){
                                                             [[HomeViewController sharedInstance] clear];
                                                             [[HomeViewController sharedInstance] requestCurrentTime];
                                                             
                                                         }else {
                                                             [[[SearchViewController sharedInstance] smenu] setSelectedNumber:1];
                                                             [[SearchViewController sharedInstance] clearScrollView];
                                                             [[SearchViewController sharedInstance] resetCntValues];
                                                             [[SearchViewController sharedInstance] requestCurrentTime];
                                                         }
                                                     }];
    REMenuItem *weekItem = [[REMenuItem alloc] initWithTitle:@"Week"
                                                       image:nil
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"period"];
                                                          NSString *currentView = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentView"];
                                                          
                                                          if ([currentView isEqualToString:@"Home"]){
                                                              [[HomeViewController sharedInstance] clear];
                                                              [[HomeViewController sharedInstance] requestCurrentTime];
                                                          }else {
                                                              [[[SearchViewController sharedInstance] smenu] setSelectedNumber:2];
                                                              [[SearchViewController sharedInstance] clearScrollView];
                                                              [[SearchViewController sharedInstance] resetCntValues];
                                                              [[SearchViewController sharedInstance] requestCurrentTime];
                                                          }
                                                      }];
    REMenuItem *alwaysItem = [[REMenuItem alloc] initWithTitle:@"Always"
                                                         image:nil
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:3] forKey:@"period"];
                                                            NSString *currentView = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentView"];
                                                            
                                                            if ([currentView isEqualToString:@"Home"]){
                                                                [[HomeViewController sharedInstance] clear];
                                                                [[HomeViewController sharedInstance] requestCurrentTime];
                                                            }else {
                                                                [[[SearchViewController sharedInstance] smenu] setSelectedNumber:3];
                                                                [[SearchViewController sharedInstance] clearScrollView];
                                                                [[SearchViewController sharedInstance] resetCntValues];
                                                                [[SearchViewController sharedInstance] requestCurrentTime];
                                                            }
                                                        }];
    
    dayItem.tag = 0;
    weekItem.tag = 1;
    alwaysItem.tag = 2;
    
    // You can also assign a custom view for any particular item
    // Uncomment the code below and add `customViewItem` to `initWithItems` array, for example:
    // self.menu = [[REMenu alloc] initWithItems:@[homeItem, exploreItem, activityItem, profileItem, customViewItem]]
    //
    /*
     UIView *customView = [[UIView alloc] init];
     customView.backgroundColor = [UIColor blueColor];
     customView.alpha = 0.4;
     REMenuItem *customViewItem = [[REMenuItem alloc] initWithCustomView:customView action:^(REMenuItem *item) {
     NSLog(@"Tap on customView");
     }];
     */
    
    homeItem.tag = 0;
    searchItem.tag = 1;
    notiItem.tag = 2;
    createItem.tag = 3;
    profileItem.tag = 4;
    
    
    if (![currentView isEqualToString:@"Profile"]) {
        self.menu = [[REMenu alloc] initWithItems:@[watchItem, notiItem, createItem, profileItem]];
        self.menu.itemHeight = 40;
    }else {
        self.menu = [[REMenu alloc] initWithItems:@[watchItem, notiItem, createItem, profileItem, logoutItem]];
        self.menu.itemHeight = 40;
    }
    self.menu.startNumber = 1;
    
    self.smenu = [[REMenu alloc] initWithItems:@[dayItem, weekItem, alwaysItem]];
    self.smenu.itemHeight = 35;
    self.smenu.startNumber = 1;
    
    
    // Background view
    //
    //self.menu.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    //self.menu.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.menu.backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    
    //self.menu.imageAlignment = REMenuImageAlignmentRight;
    //self.menu.closeOnSelection = NO;
    //self.menu.appearsBehindNavigationBar = NO; // Affects only iOS 7
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    // Blurred background in iOS 7
    //
    //self.menu.liveBlur = YES;
    //self.menu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleDark;
    //self.menu.liveBlurTintColor = [UIColor redColor];
    
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    self.smenu.waitUntilAnimationIsComplete = NO;
    self.smenu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    
    [self.menu setClosePreparationBlock:^{
        NSLog(@"Menu will close");
    }];
    
    [self.menu setCloseCompletionHandler:^{
        NSLog(@"Menu did close");
    }];
    
    
    
}

- (void)toggleMenu
{
    if (self.menu.isOpen)
        return [self.menu close];
    if (self.smenu.isOpen) {
        [self.smenu close];
    }
    
    [self.menu showFromNavigationController:self.navigationController];
}

#pragma mark-
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [alertView cancelButtonIndex]) {
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        NSString *devToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[NSUserDefaults standardUserDefaults] setObject:devToken forKey:@"deviceToken"];
        
        [navigationController popToRootViewControllerAnimated:NO];
        
        WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:Nil];
        
        [navigationController pushViewController:welcomeViewController animated:NO];
        
        [self request_deleteDevToken];
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    NSArray *stackViewControllers = self.navigationController.viewControllers;
    UIViewController *rvc = [stackViewControllers objectAtIndex:stackViewControllers.count - 1];
    
    if([rvc isKindOfClass:[VideoPlayViewController class]])
    {
        id presentedViewController = [rvc presentedViewController];
        
        NSString *viewControllerName = NSStringFromClass([presentedViewController class]);
        if([viewControllerName isEqual:@"MPInlineVideoFullscreenViewController"] || [VideoPlayViewController isVideoPlaying]) {
            return UIInterfaceOrientationMaskAll;
        }
    }
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


- (void) request_deleteDevToken {
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SET_DEV_TOKEN_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@", TAG_REQ_DEVTOKEN, [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]];
    
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

- (void) requestDefaultHashtag {
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_HASHTAG_URL];
    
    //make request
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *timestr = [NSString stringWithFormat:@"%f", ti];
    NSString *skv = [AppSharedData base64String:[NSString stringWithFormat:@"%@-%@", timestr, APP_SECRET_KEY]];
    [request addValue:timestr forHTTPHeaderField:hv1];
    [request addValue:skv forHTTPHeaderField:hv2];
    
    // clear data
    self.recvData = [NSMutableData data];
    
    //set Request Type
    requestType = REQUEST_GET_HASHTAG;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestVideoInfo {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFNotiLabelPostNotification object:self];
    
    //make URL
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, NOTI_GET_VIDEOINFO_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_VIDEOID, sid];
    
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
    
    requestType = REQUEST_VIDEO_INFO;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
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
        
        if ([requestType isEqualToString:REQUEST_VIDEO_INFO]) {
            
            NSDictionary *rdict = [dict objectForKey:TAG_RES_VIDEOITEM];
            
            SearchVideoDetailViewController *sVC = [[SearchVideoDetailViewController alloc] initWithNibName:@"SearchVideoDetailViewController" bundle:Nil];
            
            [sVC setData:rdict];
            
            [self.navigationController pushViewController:sVC animated:YES];
        }else if ([requestType isEqualToString:REQUEST_DELETE_DEV_TOKEN]){
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }else if ([requestType isEqualToString:REQUEST_GET_HASHTAG]) {
            NSArray *hashArray = [dict objectForKey:TAG_RES_HASHTAGLIST];
            NSMutableArray *rHashArray = [[NSMutableArray alloc] init];
            
            for (int i = 0 ; i < [hashArray count]; i++) {
                NSDictionary *hashList = [hashArray objectAtIndex:i];
                NSString *value = [hashList objectForKey:@"p"];
                NSString *key = [[hashList objectForKey:@"h"] lowercaseString];
                NSMutableDictionary *rhashList = [[NSMutableDictionary alloc] init];
                
                [rhashList setObject:value forKey:key];
                [rHashArray addObject:rhashList];
                
                [[[AppSharedData sharedInstance] dHashtagList] setObject:value forKey:key];
            }
            
            //check file exist;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[hashArray count]] forKey:@"hashTagCount"];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"HashtagUpdatedDate"];
            
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
            NSString *documentsDirectory = [paths objectAtIndex:0]; //2
            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"hashTagArray.plist"]; //3
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath: path]) //4
            {
                NSString *bundle = [[NSBundle mainBundle] pathForResource:@"hashTagArray" ofType:@"plist"];
                
                [fileManager copyItemAtPath:bundle toPath:path error:&error];
            }
            
            
            
            
            
            //NSLog(@"holdingArray: %@", holdingArray);
            
            BOOL success = [rHashArray writeToFile:path atomically:YES];
            NSAssert(success, @"writeToFile failed");
        }
        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        if (![errorMsg isEqualToString:@""] && errorMsg != Nil) {
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



@end
