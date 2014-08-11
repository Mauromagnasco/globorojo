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

@interface CreateVideoItemViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    
    CustomActivityIndicatorView *activityView;
    NSMutableData *recvData;
    NSMutableArray *hashtagList;
    NSMutableArray *menuArray;
    
    NSString *requestType;
    
    NSString *connectFacebook;
    NSString *connectTwitter;
    NSString *shareFacebook;
    NSString *shareTwitter;
    
    BOOL isScrolling;
    BOOL isLoading;
    BOOL confirmFlag;
    
    REMenu *menu;
    REMenu *smenu;
}

@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *videoUrlTextField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionLabelTextField;
@property (strong, nonatomic) IBOutlet UITextField *categoryTextField;
@property (strong, nonatomic) IBOutlet UILabel *hashTagLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *fbShareButton;
@property (strong, nonatomic) IBOutlet UIButton *twShareButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *categoryBoxView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (nonatomic, retain) NSMutableArray *menuArray;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) REMenu *menu;
@property (nonatomic, retain) REMenu *smenu;
@property (nonatomic, retain) NSString *connectFacebook;
@property (nonatomic, retain) NSString *connectTwitter;
@property (nonatomic, retain) NSString *shareFacebook;
@property (nonatomic, retain) NSString *shareTwitter;
@property (nonatomic, retain) NSMutableArray *hashtagList;
@property (nonatomic, retain) NSTimer *myTimer;


@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableData *recvData;

- (IBAction)onFBShareButton:(id)sender;
- (IBAction)onTWShareButton:(id)sender;
- (IBAction)onConfirmButton:(id)sender;
- (IBAction)onBackButton:(id)sender;
- (IBAction)onVideoUrlDeleteButton:(id)sender;
- (IBAction)onDescriptionDeleteButton:(id)sender;
- (IBAction)onCategoryDeleteButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;


+ (CreateVideoItemViewController *) sharedInstance;
- (void) setNotiButton_Red;



@end
