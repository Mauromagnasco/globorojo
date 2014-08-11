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

@interface SearchViewController : UIViewController<UIScrollViewDelegate, UITextFieldDelegate> {
    
    HMSegmentedControl *segmentedControl;
    HMSegmentedControl *userSegmentedControl;
    CustomActivityIndicatorView *activityView;
    NSUInteger orderType;
    NSUInteger userOrderType;
    NSString *requestType;
    NSString *videoItemType;
    
    NSString *currentTime;
    NSUInteger cntLoaded;
    NSUInteger cntLazyLoad;
    
    
    NSUInteger startY;
    NSUInteger stepY;
    NSString *searchText;
    
    NSMutableArray *heightArray;
    NSMutableData *recvData;
    NSMutableArray *videoItemArray;
    NSMutableArray *menuArray;
    
    CollapseClickArrow *arrow;
    
    REMenu *menu;
    REMenu *smenu;
    REMenu *dmenu;
    
    BOOL downHashDate;
    BOOL downHashScore;
    BOOL downHashMerit;
    BOOL downNameData;
    BOOL downNameAlpha;
    BOOL downNameMerit;
    
    BOOL isAnimating;
}

@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIButton *hashtagHomeButton;
@property (strong, nonatomic) IBOutlet UIButton *hashtagListButton;
@property (strong, nonatomic) IBOutlet UIButton *hashtagDetailButton;
@property (strong, nonatomic) IBOutlet UIButton *usernameButton;
@property (strong, nonatomic) IBOutlet UIView *segmentContainerView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (strong, nonatomic) IBOutlet UIView *scrollContainerView;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIView *descriptionContentView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *swipeButton;

@property (strong, nonatomic) IBOutlet UIButton *hashDateOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *hashScoreOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *hashMeritOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *nameDateOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *nameAlphaOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *nameMeritOrderButton;
@property (nonatomic, retain) NSMutableArray *menuArray;

@property (nonatomic, retain) HMSegmentedControl *segmentedControl;
@property (nonatomic, retain) HMSegmentedControl *userSegmentedControl;
@property (nonatomic, retain) CollapseClickArrow *arrow;
@property (nonatomic) NSUInteger orderType;
@property (nonatomic) NSUInteger userOrderType;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableArray *videoItemArray;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *currentTime;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSString *videoItemType;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, retain) REMenu *menu;
@property (nonatomic, retain) REMenu *smenu;
@property (nonatomic, retain) REMenu *dmenu;
@property (nonatomic, retain) NSMutableArray *heightArray;
@property (nonatomic, retain) NSString *currentWatchState;

- (IBAction)onDeleteTextButton:(id)sender;
- (IBAction)onBackButton:(id)sender;
- (IBAction)onSearchButton:(id)sender;
- (IBAction)onHashtagHomeButton:(id)sender;
- (IBAction)onHashtagListButton:(id)sender;
- (IBAction)onHashtagDetailButton:(id)sender;
- (IBAction)onUsernameButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (IBAction)onAddVideoButton:(id)sender;

- (IBAction)onHashDateOrderButton:(id)sender;
- (IBAction)onHashScoreOrderButton:(id)sender;
- (IBAction)onHashMeritOrderButton:(id)sender;
- (IBAction)onNameDateOrderButton:(id)sender;
- (IBAction)onNameAlphaOrderButton:(id)sender;
- (IBAction)onNameMeritOrderButton:(id)sender;



+ (SearchViewController *) sharedInstance;
- (void) setNotiButton_Red;
- (void) clearScrollView;
- (void) resetCntValues;
- (void) requestCurrentTime;
- (void) startLoading;
- (void) endLoading;
- (void) removeVideoItem;






@end
