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

@interface RBUserListViewController : UIViewController {
    
    int number;
    NSDictionary *data;
    NSMutableData *recvData;
    NSString *userId;
    NSString *requestType;
    NSString *isFollowing;
}

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *credRankLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIImageView *scoreImageView;
@property (strong, nonatomic) IBOutlet UIButton *followingButton;
@property (strong, nonatomic) IBOutlet UIButton *followerButton;

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic) int number;
@property (nonatomic, retain) NSString *isFollowing;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSString *userId;

- (IBAction)onViewButton:(id)sender;
- (IBAction)onFollowingButton:(id)sender;

@end
