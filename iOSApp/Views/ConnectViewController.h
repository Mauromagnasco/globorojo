//
//  ConnectViewController.h
//  BalloonRed
//
//  Created by Mr. RI on 3/7/14.
//  Copyright (c) 2014 Mr. RI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "CustomActivityIndicatorView.h"

@interface ConnectViewController : UIViewController<UIActionSheetDelegate> {

    NSString *requestType;
    NSMutableData *recvData;
    REMenu *menu;
    CustomActivityIndicatorView *activityView;
}


@property (strong, nonatomic) IBOutlet UILabel *navTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, retain) NSMutableData *recvData;
@property (nonatomic, retain) REMenu *menu;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (nonatomic, retain) CustomActivityIndicatorView *activityView;

- (IBAction)onBackButton:(id)sender;
- (IBAction)onMenuButton:(id)sender;
- (IBAction)onCFBButton:(id)sender;
- (IBAction)onCTWButton:(id)sender;


@end
