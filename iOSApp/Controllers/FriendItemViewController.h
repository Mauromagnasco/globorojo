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
#import "IFNotiLabel.h"

@interface FriendItemViewController : UIViewController {
    
    int number;
    
    NSDictionary *data;
    IFNotiLabel *usernameLabel;

    NSMutableData *recvData;
    NSString *requestType;
    NSString *userId;
    
    int followingCount;
}

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *credLabel;
@property (nonatomic, retain) IFNotiLabel *usernameLabel;
@property (nonatomic, retain) NSDictionary *data;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIImageView *scoreImageView;
@property (strong, nonatomic) IBOutlet UIButton *followerButton;
@property (strong, nonatomic) IBOutlet UIButton *followingButton;
@property (nonatomic, retain) NSString *isFollowing;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSString *userId;

@property (nonatomic) int number;
@property (nonatomic) int followingCount;

- (IBAction)onViewButton:(id)sender;
- (IBAction)onFollowingButton:(id)sender;

@end
