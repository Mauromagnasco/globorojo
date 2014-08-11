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

@interface DeleteVideoViewController : UIViewController<UITextFieldDelegate> {
    
    NSMutableData *recvData;
    NSString *requestType;
    NSString *videoID;
    NSMutableArray *hashtagList;
    NSMutableArray *menuArray;
    
    int number;
    
    BOOL isLoading;
    BOOL confirmFlag;
    REMenu *smenu;
    
}

- (IBAction)onBackButton:(id)sender;
- (IBAction)onRestHashButton:(id)sender;
- (IBAction)onDeleteVideoButton:(id)sender;
- (IBAction)onTextDeleteButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *desLabel;
@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *categoryBoxView;
@property (nonatomic, retain) NSMutableArray *menuArray;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (nonatomic, retain) NSTimer *myTimer;
@property (strong, nonatomic) IBOutlet UITextField *hashTestField;

@property (nonatomic, retain) CustomActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSString *videoID;
@property (nonatomic) int number;
@property (nonatomic, retain) REMenu *smenu;


@end
