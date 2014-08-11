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
#import "HMSegmentedControl.h"
#import "CustomActivityIndicatorView.h"
#import "REMenu.h"
#import "CollapseClickArrow.h"

@interface HomeViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate> {

    HMSegmentedControl *segmentedControl;
    HMSegmentedControl *userSegmentedControl;
    NSUInteger orderType;
    CustomActivityIndicatorView *activityView;
    NSMutableData *recvData;
    NSString *requestType;
    NSString *videoItemType;
    
    NSString *currentTime;
    NSUInteger cntLoaded;
    NSUInteger cntLazyLoad;
    NSUInteger userOrderType;
    
    NSUInteger startY;
    NSUInteger stepY;
    
    NSMutableArray *videoItemArray;
    NSMutableArray *heightArray;
    NSMutableArray *updateItemArray;
    BOOL lodingFlag;
    
    
    REMenu *menu;
    REMenu *smenu;
    
    int showCount;
}

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIView *segmentContainerView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (strong, nonatomic) IBOutlet UIButton *notificationButton;
@property (strong, nonatomic) IBOutlet UIView *navBarView;
@property (strong, nonatomic) IBOutlet UIView *descriptionContentView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *findFriendsButton;
@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (nonatomic, retain) NSMutableArray *heightArray;
@property (strong, nonatomic) IBOutlet UIButton *hashtagHomeButton;
@property (strong, nonatomic) IBOutlet UIButton *hashtagListButton;
@property (strong, nonatomic) IBOutlet UIButton *hashtagDetailButton;
@property (strong, nonatomic) IBOutlet UIButton *usernameButton;
@property (nonatomic, retain) NSString *videoItemType;
@property (nonatomic) NSUInteger userOrderType;



- (IBAction)onProfileButton:(id)sender;
- (IBAction)onNotificationButton:(id)sender;
- (IBAction)onSearchButton:(id)sender;
- (IBAction)onAddVideoButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (IBAction)onFindFriendsButton:(id)sender;
- (IBAction)onHashtagHomeButton:(id)sender;
- (IBAction)onHashtagListButton:(id)sender;
- (IBAction)onHashtagDetailButton:(id)sender;
- (IBAction)onUsernameButton:(id)sender;
- (IBAction)onBigWatchButton:(id)sender;

- (void) requestCurrentTime;
- (void) clear;
- (void) setNotiButton_Red;
- (void) removeVideoItem;

+ (HomeViewController *) sharedInstance;

@property (nonatomic, retain) HMSegmentedControl *segmentedControl;
@property (nonatomic, retain) HMSegmentedControl *userSegmentedControl;
@property (nonatomic) NSUInteger orderType;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) CollapseClickArrow *arrow;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSString *currentTime;
@property (nonatomic, retain) NSMutableArray *videoItemArray;
@property (nonatomic, retain) NSMutableArray *updateItemArray;
@property (nonatomic, retain) REMenu *menu;
@property (nonatomic, retain) REMenu *smenu;


@end
