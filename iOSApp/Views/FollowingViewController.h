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
#import "SearchViewController.h"

@interface FollowingViewController : UIViewController {

    NSString *requestType;
    NSMutableData *recvData;
    NSMutableArray *followingItemArray;
    
    NSString *userid;
    
    CustomActivityIndicatorView *activityView;
    REMenu *menu;
    
    NSUInteger startY;
    
    int followingCount;
}

@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIView *descriptionContentView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (strong, nonatomic) IBOutlet UIView *mainContentView;


@property (nonatomic, retain) NSString *userid;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSMutableArray *followingItemArray;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) REMenu *menu;
@property (nonatomic) int followingCount;

- (IBAction)onBackButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;


@end
