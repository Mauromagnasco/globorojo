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
#import "HMSegmentedControl.h"
#import "SearchViewController.h"

@interface FindFriendsViewController : UIViewController {

    NSString *requestType;
    NSMutableData *recvData;
    NSMutableArray *friendsItemArray;
    
    CustomActivityIndicatorView *activityView;
    REMenu *menu;
    HMSegmentedControl *segmentedControl;
    
    NSString *connectFacebook;
    NSString *connectTwitter;
    
    NSUInteger startY;
}

@property (strong, nonatomic) IBOutlet UIView *mainContentView;

@property (strong, nonatomic) IBOutlet UIView *segmentContainerView;
@property (strong, nonatomic) IBOutlet UILabel *navTitlelabel;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *applicationButton;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) REMenu *menu;
@property (nonatomic, retain) HMSegmentedControl *segmentedControl;
@property (nonatomic, retain) NSString *connectFacebook;
@property (nonatomic, retain) NSString *connectTwitter;
@property (nonatomic, retain) NSMutableArray *friendsItemArray;


- (IBAction)onBackButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (IBAction)onApplicationButton:(id)sender;

@end
