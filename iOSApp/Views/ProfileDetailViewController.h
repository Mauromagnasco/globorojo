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

@interface ProfileDetailViewController : UIViewController <UIScrollViewDelegate> {
    
    CustomActivityIndicatorView *activityView;
    NSMutableData *recvData;
    NSString *userId;
}

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
@property (strong, nonatomic) IBOutlet UIButton *followButton;


@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *userId;


- (IBAction)onBackButton:(id)sender;
- (IBAction)onVideosCountButton:(id)sender;
- (IBAction)onFollowersCountButton:(id)sender;
- (IBAction)onFollowingCountButton:(id)sender;
- (IBAction)onFollowButton:(id)sender;
- (IBAction)onVideosHomeButton:(id)sender;
- (IBAction)onVideosListButton:(id)sender;
- (IBAction)onVideosDetailButton:(id)sender;
- (IBAction)onMeritButton:(id)sender;


@end
