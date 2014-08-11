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
#import "CustomActivityIndicatorView.h"
#import "REMenu.h"
#import "SettingsViewController.h"
#import "MeritViewController.h"
#import "SearchViewController.h"

@interface ProfileViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate> {
    
    CustomActivityIndicatorView *activityView;
    NSMutableData *recvData;
    
    NSString *rbUserName;
    NSString *rbName;
    NSString *rbCred;
    NSString *rbEmail;
    NSString *requestType;
    NSString *videoItemType;
    NSString *currentTime;
    NSString *userId;
    NSString *isFollowing;
    
    NSUInteger cntLoaded;
    NSUInteger cntLazyLoad;
    NSUInteger startY;
    NSUInteger stepY;
    
    NSMutableArray *videoItemArray;
    NSMutableArray *labelArray;
    NSMutableArray *categoryItemArray;

    CGRect meritFrame;
    
    REMenu *menu;

    BOOL isAnimating;
    
    int followingCount;
    
    MeritViewController *meritView;
    
    SettingsViewController *settingsViewController;
}

@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIButton *videosHomeButton;
@property (strong, nonatomic) IBOutlet UIButton *videosListButton;
@property (strong, nonatomic) IBOutlet UIButton *videosDetailButton;
@property (strong, nonatomic) IBOutlet UIButton *meritButton;
@property (strong, nonatomic) IBOutlet UIView *scrollContainerView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (nonatomic, retain) NSMutableArray *categoryItemArray;
@property (strong, nonatomic) IBOutlet UILabel *meritUsernameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *meritUserscoreImageView;
@property (strong, nonatomic) IBOutlet UILabel *meritUserscoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *meritDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *meritScrollView;
@property (strong, nonatomic) IBOutlet UIView *meritContentView;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UILabel *meritNameLabel;
@property (strong, nonatomic) IBOutlet UIView *commonContentView;
@property (strong, nonatomic) IBOutlet UILabel *commonDescriptionLabel;


@property (nonatomic, retain) NSString *isFollowing;

@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic) CGRect meritFrame;
@property (nonatomic, retain) NSMutableArray *labelArray;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSString *currentTime;
@property (nonatomic, retain) NSMutableArray *videoItemArray;
@property (nonatomic, retain) NSString *videoItemType;
@property (nonatomic, retain) REMenu *menu;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *rbEmail;
@property (nonatomic, retain) MeritViewController *meritView;
@property (strong, nonatomic) IBOutlet UIImageView *followerImageView;
@property (strong, nonatomic) IBOutlet UIImageView *followingImageView;


- (IBAction)onBackButton:(id)sender;
- (IBAction)onSignOutButton:(id)sender;
- (IBAction)onVideosCountButton:(id)sender;
- (IBAction)onFollowersCountButton:(id)sender;
- (IBAction)onFollowingCountButton:(id)sender;
- (IBAction)onSettingsButton:(id)sender;
- (IBAction)onVideosHomeButton:(id)sender;
- (IBAction)onVideosListButton:(id)sender;
- (IBAction)onVideosDetailButton:(id)sender;
- (IBAction)onMeritButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (IBAction)onPhotoViewButton:(id)sender;

+ (ProfileViewController *) sharedInstance;
- (void) setNotiButton_Red;
- (void) removeVideoItem;



@end
