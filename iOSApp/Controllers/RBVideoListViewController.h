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
#import "IFTweetLabel.h"

@interface RBVideoListViewController : UIViewController {
    
    int number;
    NSDictionary *data;
    NSString *videoURL;
    NSString *userId;
    NSMutableData *recvData;
    NSString *requestType;
    NSString *videoID;
    float videoScore;
    
    
    IFTweetLabel *hashTWLabel;
    IFTweetLabel *usernameTWLabel;
    
}


@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *hashLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *videoThumbImageView;
@property (strong, nonatomic) IBOutlet UIImageView *scoreImageView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *rateButton;

@property (nonatomic, retain) NSString *videoID;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic) int number;
@property (nonatomic, retain) IFTweetLabel *hashTWLabel;
@property (nonatomic, retain) IFTweetLabel *usernameTWLabel;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSString *videoURL;
@property (nonatomic, retain) NSString *userId;

- (IBAction)onViewButton:(id)sender;
- (void) clear;
- (void) parseData;
- (IBAction)onPlayButton:(id)sender;
- (IBAction)onRateButton:(id)sender;

@end
