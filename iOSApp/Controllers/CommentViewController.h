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

@interface CommentViewController : UIViewController <UIAlertViewDelegate>{

    NSString *contentText;
    IFTweetLabel *tweetLabel;
    NSDictionary *data;
    
    NSString *commentUserId;
    NSString *commentId;
    NSMutableData *recvData;
    
    int commentNumber;
    int videoNumber;
    NSString *requestType;
}

- (IBAction)onShareButton:(id)sender;

@property (nonatomic, retain) NSString *contentText;
@property (nonatomic, retain) IFTweetLabel *tweetLabel;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSString *commentUserId;
@property (nonatomic, retain) NSString *commentId;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic) int commentNumber;
@property (nonatomic) int videoNumber;
@property (nonatomic, retain) NSString *requestType;


@end
