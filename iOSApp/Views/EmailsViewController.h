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

@interface EmailsViewController : UIViewController {
    
    BOOL isLoading;
    NSMutableData *recvData;
    NSString *requestType;
    
    BOOL mentionFlag;
    BOOL scoreFlag;
    BOOL commentFlag;
    BOOL followFlag;
    BOOL unfollowFlag;
    
    
    REMenu *menu;
    
}

@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *mentionLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UILabel *followLabel;
@property (strong, nonatomic) IBOutlet UILabel *unfollowLabel;
@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIButton *mentionButton;
@property (strong, nonatomic) IBOutlet UIButton *scoreButton;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) IBOutlet UIButton *unfollowButton;


@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) REMenu *menu;


- (IBAction)onBackButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (IBAction)onMentionButton:(id)sender;
- (IBAction)onScoreButton:(id)sender;
- (IBAction)onCommentButton:(id)sender;
- (IBAction)onFollowButton:(id)sender;
- (IBAction)onUnfollowButton:(id)sender;
- (IBAction)onConfirmButton:(id)sender;


@end
