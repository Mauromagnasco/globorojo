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
#import "UICircularSlider.h"
#import "CustomActivityIndicatorView.h"
#import "SearchViewController.h"
#import "IFTweetLabel.h"

@interface RateViewController : UIViewController<UIAlertViewDelegate, UIActionSheetDelegate> {

    UICircularSlider *circleSlider;
    NSString *videoID;
    NSString *videoURL;
    NSString *userID;
    NSString *videoTitle;
    NSString *userName;
    NSString *hashTag;
    NSMutableData *recvData;
    
    CustomActivityIndicatorView *activityView;
    
    int number;
    int viewCount;
    int shareCount;
    int commentCount;
    int scoreCount;
    float givenScore;
    float avgScore;
    float videoScore;
    BOOL isScored;
    BOOL valueChanged;
    NSMutableArray *scoreList;
    
    IFTweetLabel *hashTWLabel;
    IFTweetLabel *usernameTWLabel;
    IFTweetLabel *myscoreTWLabel;
    
    float changedScore;
    
    NSString *requestType;
    
}

@property (nonatomic) int number;
@property (strong, nonatomic) IBOutlet UILabel *viewsCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *sharesCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *redImageView;
@property (strong, nonatomic) IBOutlet UILabel *scoresCountLabel;
@property (strong, nonatomic) IBOutlet UIView *sliderContentView;
@property (strong, nonatomic) IBOutlet UIImageView *sliderBackImageView;
@property (nonatomic, retain) UICircularSlider *circleSlider;
@property (nonatomic, retain) NSString *videoID;
@property (nonatomic, retain) NSString *videoURL;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *avgScoreLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (nonatomic, retain) NSMutableArray *scoreList;
@property (nonatomic, retain) NSString *videoTitle;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *hashTag;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic) float videoScore;
@property (nonatomic, retain) IFTweetLabel *hashTWLabel;
@property (nonatomic, retain) IFTweetLabel *usernameTWLabel;
@property (nonatomic, retain) IFTweetLabel *myscoreTWLabel;

@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
- (IBAction)onConfirmButton:(id)sender;
- (IBAction)onShareButton:(id)sender;
- (IBAction)onReportButton:(id)sender;
- (IBAction)onPlayButton:(id)sender;
- (IBAction)onBackButton:(id)sender;
@end
