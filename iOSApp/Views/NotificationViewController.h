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
#import "SearchViewController.h"

@interface NotificationViewController : UIViewController<UIScrollViewDelegate> {
    
    int cntLoaded;
    int cntLazyLoad;
    int startY;
    int stepY;
    
    NSString *requestType;
    NSString *currentTime;
    NSMutableData *recvData;
    NSMutableArray *notiItemArray;
    
    CustomActivityIndicatorView *activityView;
    
    REMenu *menu;
}

@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *descriptionContentView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionContentLabel;

@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSString *currentTime;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSMutableArray *notiItemArray;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) REMenu *menu;

- (IBAction)onBackButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (void) clear;
- (void) requestRead;
+ (NotificationViewController *) sharedInstance;



@end
