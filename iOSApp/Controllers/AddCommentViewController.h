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

@interface AddCommentViewController : UIViewController <UITextViewDelegate> {
    
    NSString *videoID;
    NSMutableData *recvData;
    
    int supernumber;
    NSString *content;
    
    bool connecting;
    
}

- (IBAction)onSendButton:(id)sender;
- (IBAction)onDeleteButton:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) IBOutlet UITextView *commentTextView;
@property (nonatomic, retain) NSString *videoID;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic) int supernumber;
@property (nonatomic, retain) NSString *content;


@end
