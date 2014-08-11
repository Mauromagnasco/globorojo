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

#import "CreateVideoItemViewController.h"
#import "Constants.h"
#import "SBJson.h"
#import "UserController.h"
#import "AppDelegate.h"
#import "ConnectViewController.h"
#import "ApplicationViewController.h"
#import "SearchViewController.h"
#import "AppSharedData.h"

#define REQUEST_FOR_ADDVIDEO            @"addVideo"
#define REQUEST_FOR_NOTIFICATION        @"notification"
#define REQUEST_FOR_SOCIALCONNECT       @"socialConnect"
#define REQUEST_FOR_GETHASHTAGS         @"hashtaglist"

@interface CreateVideoItemViewController ()

@property (nonatomic, retain) UITapGestureRecognizer *singleTap;

@end

@implementation CreateVideoItemViewController

static CreateVideoItemViewController *sharedInstance = nil;

@synthesize navTitleLabel;
@synthesize descriptionLabel;
@synthesize descriptionLabelTextField;
@synthesize videoUrlTextField;
@synthesize categoryTextField;
@synthesize hashTagLabel;
@synthesize fbShareButton;
@synthesize twShareButton;
@synthesize activityView;
@synthesize recvData;
@synthesize menu;
@synthesize menuButton;
@synthesize requestType;
@synthesize connectFacebook;
@synthesize connectTwitter;
@synthesize shareFacebook;
@synthesize shareTwitter;
@synthesize mainContentView;
@synthesize scrollView;
@synthesize smenu;
@synthesize categoryBoxView;
@synthesize hashtagList;
@synthesize confirmButton;
@synthesize menuArray;
@synthesize myTimer;
@synthesize singleTap;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    descriptionLabelTextField.delegate = self;
    videoUrlTextField.delegate = self;
    categoryTextField.delegate = self;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    activityView.hidden = YES;
    [self.view addSubview:activityView];
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:20.0]];
    [videoUrlTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:14.0]];
    [descriptionLabelTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:14.0]];
    [categoryTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:14.0]];
    [hashTagLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:20.0]];
    [descriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:13.0]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    confirmFlag = false;
//    confirmButton.enabled = NO;
    
    categoryTextField.delegate = self;
    
    [categoryTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    hashtagList = [NSMutableArray array];
    
    sharedInstance = self;
    
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        [self setNotiButton_Red];
    }else {
        [self setNotiButton_Normal];
    }
    
    isScrolling = false;
    isLoading = FALSE;
    
    NSString *lastview = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastView"];
    
    if (![lastview isEqualToString:@"Application"]) {
        shareTwitter = @"N";
        shareFacebook = @"N";
        connectTwitter = @"N";
        connectFacebook = @"N";
        videoUrlTextField.text = @"";
        descriptionLabelTextField.text = @"";
        categoryTextField.text = @"";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"CreateVideo" forKey:@"lastView"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Create" forKey:@"currentView"];
    
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
    
    UIPasteboard *thePasteboard = [UIPasteboard generalPasteboard];
    NSString *pasteboardString = thePasteboard.string;
    
    if (pasteboardString.length > 0) {
        videoUrlTextField.text = pasteboardString;
    }
    
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
    [self initMenuArray];
    [self requsetCheckNotification];
}

- (void) initMenuArray {
    
    menuArray = [NSMutableArray array];
    
    for (int i = 0; i < 2; i++) {
        REMenu *dmenu = [[REMenu alloc] init];
        dmenu.itemHeight = 30;
        dmenu.startNumber = 1;
        dmenu.waitUntilAnimationIsComplete = YES;
        dmenu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
            badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
            badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
        };
        
        [menuArray addObject:dmenu];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onFBShareButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    if ([shareFacebook isEqualToString:@"N"]) {
        shareFacebook = @"Y";
        [fbShareButton setBackgroundImage:[UIImage imageNamed:@"btnCheckedFBShare.png"] forState:UIControlStateNormal];
        
        if ([connectFacebook isEqualToString:@"N"]) {
            ApplicationViewController *applicationViewController = [[ApplicationViewController alloc] initWithNibName:@"ApplicationViewController" bundle:Nil];
            [self.navigationController pushViewController:applicationViewController animated:YES];
        }
        
    }else {
        shareFacebook = @"N";
        [fbShareButton setBackgroundImage:[UIImage imageNamed:@"btnUncheckedFBShare.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)onTWShareButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    if ([shareTwitter isEqualToString:@"N"]) {
        shareTwitter = @"Y";
        [twShareButton setBackgroundImage:[UIImage imageNamed:@"btnCheckedTWShare.png"] forState:UIControlStateNormal];
        
        if ([connectTwitter isEqualToString:@"N"]) {
            ApplicationViewController *applicationViewController = [[ApplicationViewController alloc] initWithNibName:@"ApplicationViewController" bundle:Nil];
            [self.navigationController pushViewController:applicationViewController animated:YES];
        }
    }else {
        shareTwitter = @"N";
        [twShareButton setBackgroundImage:[UIImage imageNamed:@"btnUncheckedTWShare.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)onConfirmButton:(id)sender {
    
    if (isLoading) {
        return;
    }
    
    if ([videoUrlTextField.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please input the video url." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    if ([categoryTextField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Category name mustn't include space, special characters." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    
    
    if (menu.isOpen) [menu close];
    
    [self requestAddVideo];
}

- (IBAction)onBackButton:(id)sender {
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *aController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    if ([aController isKindOfClass:[SearchViewController class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"returnSearch"];
    }
    
    if (menu.isOpen) [menu close];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onVideoUrlDeleteButton:(id)sender {
    videoUrlTextField.text = @"";
}

- (IBAction)onDescriptionDeleteButton:(id)sender {
    descriptionLabelTextField.text = @"";
}

- (IBAction)onCategoryDeleteButton:(id)sender {
    categoryTextField.text = @"";
}

- (IBAction)onMenuButton:(id)sender {
    if (menu.isOpen)
        return [menu close];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [menu showFromRect:CGRectMake(0, 60, screenSize.width, screenSize.height - 40) inView:self.view];
    }else {
        [menu showFromRect:CGRectMake(0, 40, screenSize.width, screenSize.height - 40) inView:self.view];
    }
}

#pragma mark -
#pragma mark Touch Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [videoUrlTextField resignFirstResponder];
    [descriptionLabelTextField resignFirstResponder];
    [categoryTextField resignFirstResponder];
}

#pragma mark -
#pragma mark UITextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField == videoUrlTextField) {
        [descriptionLabelTextField becomeFirstResponder];
    }else if (textField == descriptionLabelTextField) {
        [categoryTextField becomeFirstResponder];
    }else {
        [categoryTextField resignFirstResponder];
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        if (screenSize.height <= 480) {
            isScrolling = NO;
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 30) animated:YES];
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (screenSize.height <= 480) {
        if (textField == categoryTextField && !isScrolling) {
            isScrolling = YES;
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 100) animated:YES];
        }
    }
    
    if (textField == categoryTextField) {
        [self textChanged:categoryTextField];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField != categoryTextField) {
        [self closeMenu];
    }
    return YES;
}

-(void)textChanged:(UITextField *)textField
{
    NSString *searchText = [categoryTextField.text lowercaseString];
    
    if ([searchText length] == 0)
    {
        [self closeMenu];
        return;
    }
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
//    [confirmButton setEnabled:NO];
    
    int i;
    
    NSString *childhashtag;
    NSString *parenthashtag;
    NSString *opa;
    
    
    for (i = 0; i < [hashtagList count]; i++) {
        NSDictionary *eobj = [hashtagList objectAtIndex:i];
        
        childhashtag =  [[eobj objectForKey:TAG_RES_RB_HASHTAG] lowercaseString];
        parenthashtag = [eobj objectForKey:TAG_RES_RB_PARENT_HASHTAG];
        opa = [parenthashtag lowercaseString];
        
        if ([searchText isEqualToString:childhashtag] && ![opa isEqualToString:childhashtag]) {
            break;
        }
    }
    
    myTimer = nil;
    myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                               target: self
                                             selector: @selector(closeSMenu:)
                                             userInfo: nil
                                              repeats: NO];
    
    if (i != [hashtagList count]) {
        confirmFlag = YES;
        for (int i = 0 ; i < [menuArray count]; i++) {
            smenu = [menuArray objectAtIndex: i];
            if ([smenu isOpen]) {
                [smenu close];
                [scrollView addGestureRecognizer:singleTap];
            }else {
                [self setMenuItems: parenthashtag];
                [smenu showFromRect:CGRectMake(categoryBoxView.frame.origin.x, categoryBoxView.frame.origin.y + 30, categoryBoxView.frame.size.width, screenSize.height - categoryBoxView.frame.origin.y) inView:self.scrollView];
                [scrollView removeGestureRecognizer:singleTap];
                break;
            }
        }
        
    }else {
        for (i = 0; i < [menuArray count]; i++) {
            smenu = [menuArray objectAtIndex:i];
            if ([smenu isOpen]) {
                [smenu close];
                [scrollView addGestureRecognizer:singleTap];
            }
        }
    }
//    else {
//       
//        if (confirmFlag) {
//            for (int i = 0; i < 2; i++) {
//                smenu = [menuArray objectAtIndex:i];
//                if ([smenu isOpen]) {
//                    [smenu close];
//                }else {
//                    [self setMenuItems: @""];
//                    [smenu showFromRect:CGRectMake(categoryBoxView.frame.origin.x, categoryBoxView.frame.origin.y + 30, categoryBoxView.frame.size.width, screenSize.height - categoryBoxView.frame.origin.y) inView:self.scrollView];
//                }
//            }
//        }else {
//            int i;
//            for (i = 0; i < 2; i++) {
//                smenu = [menuArray objectAtIndex:i];
//                if ([smenu isOpen]) break;
//            }
//            
//            if (i == 2) {
//                smenu = [menuArray objectAtIndex:0];
//                [self setMenuItems: @""];
//                [smenu showFromRect:CGRectMake(categoryBoxView.frame.origin.x, categoryBoxView.frame.origin.y + 30, categoryBoxView.frame.size.width, screenSize.height - categoryBoxView.frame.origin.y) inView:self.scrollView];
//            }
//        }
//        confirmFlag = NO;
//    }
}

-(void) closeSMenu:(NSTimer*) t
{
    NSString *searchText = [categoryTextField.text lowercaseString];
    
    int i;
    
    NSString *childhashtag;
    NSString *parenthashtag;
    NSString *opa;
    
    
    for (i = 0; i < [hashtagList count]; i++) {
        NSDictionary *eobj = [hashtagList objectAtIndex:i];
        
        childhashtag =  [[eobj objectForKey:TAG_RES_RB_HASHTAG] lowercaseString];
        parenthashtag = [eobj objectForKey:TAG_RES_RB_PARENT_HASHTAG];
        opa = [parenthashtag lowercaseString];
        
        if ([searchText isEqualToString:childhashtag] && ![opa isEqualToString:childhashtag]) {
            break;
        }
    }
    
    if (i == [hashtagList count]) {
        for (i = 0; i < [menuArray count]; i++) {
            smenu = [menuArray objectAtIndex:i];
            if ([smenu isOpen]) {
                [smenu close];
                [scrollView addGestureRecognizer:singleTap];
            }
        }
    }
}

- (void) changeCategoryTextField {
    
    NSString *searchText = categoryTextField.text;
    
    int i;
    
    for (i = 0; i < [hashtagList count]; i++) {
        NSDictionary *eobj = [hashtagList objectAtIndex:i];
        
        NSString *childhashtag =  [[eobj objectForKey:TAG_RES_RB_HASHTAG] lowercaseString];
        NSString *parenthashtag = [eobj objectForKey:TAG_RES_RB_PARENT_HASHTAG];
        
        if ([searchText isEqualToString:childhashtag]) {
            categoryTextField.text = parenthashtag;
            break;
        }
    }
}

- (void) closeMenu {
    for (int i = 0; i < [menuArray count]; i++) {
        smenu = [menuArray objectAtIndex:i];
        if ([smenu isOpen]) {
            [smenu close];
            [scrollView addGestureRecognizer:singleTap];
        }
    }
}


#pragma mark -
#pragma mark Request for Add Video Methods

- (void) requestHashtagList {
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_HASHTAGLIST_URL];
    
    //make request
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *timestr = [NSString stringWithFormat:@"%f", ti];
    NSString *skv = [AppSharedData base64String:[NSString stringWithFormat:@"%@-%@", timestr, APP_SECRET_KEY]];
    [request addValue:timestr forHTTPHeaderField:hv1];
    [request addValue:skv forHTTPHeaderField:hv2];
    
    // clear data
    self.recvData = [NSMutableData data];
    
    requestType = REQUEST_FOR_GETHASHTAGS;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestAddVideo {
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, REGISTER_VIDEO_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_VIDEOURL, videoUrlTextField.text,
                      TAG_REQ_DESCRIPTION, descriptionLabelTextField.text,
                      TAG_REQ_CATEGORY, categoryTextField.text,
                      TAG_REQ_SHAREFACEBOOK, shareFacebook,
                      TAG_REQ_SHARETWITTER, shareTwitter];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[key dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *timestr = [NSString stringWithFormat:@"%f", ti];
    NSString *skv = [AppSharedData base64String:[NSString stringWithFormat:@"%@-%@", timestr, APP_SECRET_KEY]];
    [request addValue:timestr forHTTPHeaderField:hv1];
    [request addValue:skv forHTTPHeaderField:hv2];
    
    // clear data
    self.recvData = [NSMutableData data];
    
    requestType = REQUEST_FOR_ADDVIDEO;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requsetCheckNotification {
    
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, CHECK_NOTIFICATION_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID]];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[key dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *timestr = [NSString stringWithFormat:@"%f", ti];
    NSString *skv = [AppSharedData base64String:[NSString stringWithFormat:@"%@-%@", timestr, APP_SECRET_KEY]];
    [request addValue:timestr forHTTPHeaderField:hv1];
    [request addValue:skv forHTTPHeaderField:hv2];
    
    // clear data
    self.recvData = [NSMutableData data];
    
    //set Request Type;
    requestType = REQUEST_FOR_NOTIFICATION;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    
}

- (void) requestSocialConnectInfo {
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, GET_SOCIALINFO_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID]];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[key dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString *timestr = [NSString stringWithFormat:@"%f", ti];
    NSString *skv = [AppSharedData base64String:[NSString stringWithFormat:@"%@-%@", timestr, APP_SECRET_KEY]];
    [request addValue:timestr forHTTPHeaderField:hv1];
    [request addValue:skv forHTTPHeaderField:hv2];
    
    // clear data
    self.recvData = [NSMutableData data];
    
    //set Request Type;
    requestType = REQUEST_FOR_SOCIALCONNECT;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    
}




- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    
    [self endLoading];
    
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    
    [self.recvData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%s", __FUNCTION__);
    /// This method is called when the receiving data is finished
    /*    NSString *text = [[[NSString alloc] initWithData:self.recvData encoding:NSUTF8StringEncoding] autorelease];
     self.textView.text = text;*/
    
    NSString *text = [[NSString alloc] initWithData:self.recvData encoding:NSUTF8StringEncoding];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    
    NSDictionary *dict;
    
    dict = (NSDictionary*)[jsonParser objectWithString:text ];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:REQUEST_FOR_ADDVIDEO]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your video registered successfuly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
            
        }else if ([requestType isEqualToString:REQUEST_FOR_NOTIFICATION]) {
            NSString *checkFlag = [dict objectForKey:TAG_RES_ISNEWNOTIFICATION];
            
            if ([checkFlag isEqualToString:@"Y"]) {
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
            }else {
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
            }
            
            [self requestSocialConnectInfo];
        }else if ([requestType isEqualToString:REQUEST_FOR_SOCIALCONNECT]) {
            
            connectFacebook = [dict objectForKey:TAG_RES_CONNECTFACEBOOK];
            connectTwitter = [dict objectForKey:TAG_RES_CONNECTTWITTER];
            
            if ([shareFacebook isEqualToString:@"Y"] && [connectFacebook isEqualToString:@"N"]) {
                [fbShareButton setBackgroundImage:[UIImage imageNamed:@"btnUncheckedFBShare.png"] forState:UIControlStateNormal];
            }
            
            if ([shareTwitter isEqualToString:@"Y"] && [connectTwitter isEqualToString:@"N"]) {
                [twShareButton setBackgroundImage:[UIImage imageNamed:@"btnUncheckedTWShare.png"] forState:UIControlStateNormal];
            }
            
            [self requestHashtagList];
        }else if ([requestType isEqualToString:REQUEST_FOR_GETHASHTAGS]) {
            
            [self endLoading];
            
            hashtagList = [dict objectForKey:TAG_RES_HASHTAGLIST];
        }
        
    }else {
        [self endLoading];
        
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        if (![errorMsg isEqualToString:@""] && errorMsg != Nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    [self endLoading];
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    [activityView startAnimation];
    isLoading = YES;
    activityView.hidden = NO;
    activityView.alpha = 1;
}

- (void)endLoading{
    isLoading = NO;
    
    [UIView animateWithDuration:.5
                     animations:^{
                         activityView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         activityView.hidden = YES;
                         [activityView stopAnimation];
                     }];
    
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark-
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)viewWillLayoutSubviews{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.view.clipsToBounds = YES;
        
        CGFloat screenHeight = screenRect.size.height;
        self.mainContentView.frame =  CGRectMake(0, 20, self.mainContentView.frame.size.width,screenHeight-20);
        
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
    }else {
        
        mainContentView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 20);
    }
    
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, screenRect.size.height - 60)];
}

+(CreateVideoItemViewController *) sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (void) setNotiButton_Red {
    [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
}

- (void) setNotiButton_Normal {
    [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
}

#pragma mark-
#pragma mark Set Menu Items
- (void) setMenuItems:(NSString *)title {
    
    REMenuItem *defaultItem;
    
    if ([title isEqualToString:@""]) {
        defaultItem = [[REMenuItem alloc] initWithTitle:@"CREATE NEW CATEGORY"
                                                  image:nil
                                       highlightedImage:nil
                                                 action:^(REMenuItem *item) {
                                                     [confirmButton setEnabled:YES];
                                                     [categoryTextField resignFirstResponder];
                                                 }];
        
        [smenu setStartNumber:0];
    }else {
        defaultItem = [[REMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"USE '%@' INSTEAD", title]
                                                  image:nil
                                       highlightedImage:nil
                                                 action:^(REMenuItem *item) {
                                                     [self changeCategoryTextField];
                                                     [confirmButton setEnabled:YES];
                                                     [categoryTextField resignFirstResponder];
                                                 }];
        
        [smenu setStartNumber:1];
    }
    
    [scrollView bringSubviewToFront:defaultItem.customView];
    
    defaultItem.tag = 0;
    [smenu setItems:@[defaultItem]];
}

#pragma mark-
#pragma mark Tap Gesture Function for ScrollView

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if ([smenu isOpen]) return;
    [videoUrlTextField resignFirstResponder];
    [categoryTextField resignFirstResponder];
    [descriptionLabelTextField resignFirstResponder];
}


@end
