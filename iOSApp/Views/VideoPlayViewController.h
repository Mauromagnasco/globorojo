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
#import <MediaPlayer/MediaPlayer.h>
#import "CustomActivityIndicatorView.h"
#import "IFTweetLabel.h"
#import "YTVimeoExtractor.h"

@interface VideoPlayViewController : UIViewController<UIActionSheetDelegate> {

    MPMoviePlayerController *moviePlayerController;
    NSString *videoUrl;
    NSString *videoID;
    NSString *userID;
    NSString *videoTitle;
    NSString *userName;
    NSString *hashTag;
    NSString *requestType;
    
    NSMutableData *recvData;
    int number;
    float videoScore;
    BOOL returnFlag;
    BOOL rotateFlag;
    
    IFTweetLabel *hashTWLabel;
    IFTweetLabel *usernameTWLabel;
    
    CustomActivityIndicatorView *activityView;
}

- (IBAction)onPrevButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *reportButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic, retain) NSString *videoUrl;
@property (strong, nonatomic) IBOutlet UIButton *rateButton;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSString *videoID;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *videoTitle;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *hashTag;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic) int number;
@property (nonatomic) float videoScore;
@property (nonatomic, retain) IFTweetLabel *hashTWLabel;
@property (nonatomic, retain) IFTweetLabel *usernameTWLabel;

+(BOOL)isVideoPlaying;
- (IBAction)onReportButton:(id)sender;
- (IBAction)onShareButton:(id)sender;
- (IBAction)onRateButton:(id)sender;


@end
