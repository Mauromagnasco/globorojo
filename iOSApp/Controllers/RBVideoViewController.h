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
#import "AddCommentViewController.h"
#import "CommentViewController.h"
#import "CustomActivityIndicatorView.h"
#import "IFTweetLabel.h"

@interface RBVideoViewController : UIViewController <UIActionSheetDelegate> {
    
    int number;
    
    NSDictionary *data;
    
    NSString *videoURL;
    NSString *videoID;
    NSString *userId;
    float userScore;
    float videoScore;
    float viewHeight;
    NSMutableArray *commentItemArray;
    NSMutableArray *heightArray;
    NSMutableArray *commentArray;
    NSMutableData *recvData;
    
    NSString *requestType;
    UIButton *showButton;
    
    BOOL showCommentButtonFlag;
    
    CGRect originFrame;
    
    IFTweetLabel *hashTWLabel;
    IFTweetLabel *usernameTWLabel;
    
    
    AddCommentViewController *addCommentView;
    CustomActivityIndicatorView *activityView;
}

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *hashLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeagoLabel;
@property (strong, nonatomic) IBOutlet UIImageView *videoThumbImageView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *ratingButton;
@property (strong, nonatomic) IBOutlet UIImageView *scoreImageView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic) float viewHeight;

@property (nonatomic, retain) IFTweetLabel *hashTWLabel;
@property (nonatomic, retain) IFTweetLabel *usernameTWLabel;
@property (strong, nonatomic) IBOutlet UIButton *reportButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;


- (IBAction)onReportButton:(id)sender;
- (IBAction)onShareButton:(id)sender;
- (IBAction)onPlayButton:(id)sender;
- (IBAction)onRatingButton:(id)sender;
- (IBAction)onProfileViewButton:(id)sender;

- (void) parseData;
- (void) move_addCommentView: (float) step;
- (float) addCommentItemView: (NSDictionary *) dict;
- (float) removeCommentItem: (int) commentNumber;
- (void) resetFrame;
- (void) clear;

@property (nonatomic, retain) UIButton *showButton;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSString *videoURL;
@property (nonatomic, retain) NSString *videoID;
@property (nonatomic, retain) NSMutableArray *commentItemArray;
@property (nonatomic, retain) AddCommentViewController *addCommentView;
@property (nonatomic, retain) NSMutableArray *heightArray;
@property (nonatomic) int number;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSMutableArray *commentArray;
@property (nonatomic) CGRect originFrame;


@end
