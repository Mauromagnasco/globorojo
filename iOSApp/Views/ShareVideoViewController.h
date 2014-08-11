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
#import <MessageUI/MessageUI.h>
#import "SearchViewController.h"

@interface ShareVideoViewController : UIViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate> {

    NSString *videoUrl;
    NSString *videoId;
    NSString *changedURL;
    NSString *videoTitle;
    NSString *username;
    NSString *postData;
    NSString *hashtag;
    
    NSMutableData *recvData;
    
    BOOL isScrolling;
    
}

- (IBAction)onBackButton:(id)sender;
- (IBAction)onFBShareButton:(id)sender;
- (IBAction)onTWShareButton:(id)sender;
- (IBAction)onEmailShareButton:(id)sender;
- (IBAction)onCopyUrlButton:(id)sender;
+ (NSString *)base64String:(NSString *)str;



@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSString *videoUrl;
@property (nonatomic, retain) NSString *videoId;
@property (nonatomic, retain) NSString *changedURL;
@property (nonatomic, retain) NSString *videoTitle;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *postData;
@property (nonatomic, retain) NSString *hashtag;
@property (nonatomic, retain) NSMutableData *recvData;


@end
