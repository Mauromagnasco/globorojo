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
#import "RBVideoViewController.h"
#import "REMenu.h"
#import "SearchViewController.h"

@interface SearchVideoDetailViewController : UIViewController {

    NSDictionary *data;
    NSMutableData *recvData;
    CustomActivityIndicatorView *activityView;
    RBVideoViewController *rbVC;
    float startY;
    float stepY;
    
    REMenu *menu;
}

@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UIButton *notiButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;

@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) RBVideoViewController *rbVC;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic, retain) REMenu *menu;

- (IBAction)onBackButton:(id)sender;
- (IBAction)onNotiButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (IBAction)onSearchButton:(id)sender;

+ (SearchVideoDetailViewController *) sharedInstance;
- (void) setNotiButton_Red;

@end
