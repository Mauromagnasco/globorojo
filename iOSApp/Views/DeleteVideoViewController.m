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

#import "DeleteVideoViewController.h"
#import "Constants.h"
#import "SearchViewController.h"
#import "SearchVideoDetailViewController.h"
#import "AppSharedData.h"
#import "SBJson.h"
#import "HomeViewController.h"
#import "RateViewController.h"
#import "ProfileViewController.h"
#import "VideoPlayViewController.h"

#define REQUEST_DELETE_VIDEO           @"deleteVideo"
#define REQUEST_RESET_HASHTAG          @"resetHashtag"
#define REQUEST_FOR_GETHASHTAGS        @"hashtaglist"

@interface DeleteVideoViewController ()

@end

@implementation DeleteVideoViewController

@synthesize mainContentView;
@synthesize scrollView;
@synthesize desLabel;
@synthesize hashTestField;
@synthesize activityView;
@synthesize recvData;
@synthesize requestType;
@synthesize videoID;
@synthesize number;
@synthesize smenu;
@synthesize resetButton;
@synthesize categoryBoxView;
@synthesize menuArray;
@synthesize myTimer;

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
    
    smenu = [[REMenu alloc] init];
    smenu.itemHeight = 30;
    smenu.startNumber = 1;
    self.smenu.waitUntilAnimationIsComplete = YES;
    self.smenu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 80;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    activityView.hidden = YES;
    [mainContentView addSubview:activityView];
    
    hashTestField.delegate = self;
    
    [hashTestField setFont:[UIFont fontWithName:CUSTOM_FONT size:14.0]];
    [desLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:11.0]];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"DeleteVideo" forKey:@"lastView"];
    
//    [resetButton setEnabled:NO];
    [hashTestField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self initMenuArray];
    [self requestHashtagList];
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

- (IBAction)onBackButton:(id)sender {
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *aController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    if ([aController isKindOfClass:[SearchViewController class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"returnSearch"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onRestHashButton:(id)sender {
    [hashTestField resignFirstResponder];
    [self requestResetHashtag];
}

- (IBAction)onDeleteVideoButton:(id)sender {
    [self requestDeleteVideo];
}

- (IBAction)onTextDeleteButton:(id)sender {
    hashTestField.text = @"";
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


- (void) requestDeleteVideo {
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, DELETE_VIDEO_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",
                      TAG_REQ_VIDEOID, videoID];
    
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
    
    requestType = REQUEST_DELETE_VIDEO;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestResetHashtag {
    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, RESET_HASHTAG_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@",
                      TAG_REQ_VIDEOID, videoID,
                      TAG_REQ_HASHTAG, hashTestField.text];
    
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
    
    requestType = REQUEST_RESET_HASHTAG;
    
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
    didReceiveData:(NSData *)rdata
{
    
    [self.recvData appendData:rdata];
    
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
    
    [self endLoading];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:REQUEST_DELETE_VIDEO]) {
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:number] forKey:@"RemoveVideoNumber"];
            
            NSString *superController = [[NSUserDefaults standardUserDefaults] objectForKey:@"SuperController"];
            
            if ([superController isEqualToString:@"Home"]) {
                [[HomeViewController sharedInstance] removeVideoItem];
            }else if ([superController isEqualToString:@"Search"]){
//                [[SearchViewController sharedInstance] removeVideoItem];
            }else if ([superController isEqualToString:@"Profile"]){
//                [[ProfileViewController sharedInstance] removeVideoItem];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchDetailRemoveVideoItem" object:Nil];
            }
            
            
            [[AppSharedData sharedInstance] setDeleteFlag:YES];
            
            NSArray *viewControllers = [self.navigationController viewControllers];
            UIViewController *aController;
            for (int i = [viewControllers count] - 2; i >= 0; i--) {
                aController = [viewControllers objectAtIndex:i];
                if ([aController isKindOfClass:[SearchVideoDetailViewController class]]) {
                    continue;
                }
                if ([aController isKindOfClass:[RateViewController class]]) {
                    continue;
                }
                if ([aController isKindOfClass:[VideoPlayViewController class]]) {
                    continue;
                }
                break;
            }
            
            [self.navigationController popToViewController:aController animated:YES];
            
        }else if ([requestType isEqualToString:REQUEST_RESET_HASHTAG]) {
            [[NSUserDefaults standardUserDefaults] setObject:videoID forKey:@"changedVideoId"];
            [[NSUserDefaults standardUserDefaults] setObject:hashTestField.text forKey:@"changedHashtag"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HashtagChanged" object:Nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sHashtagChanged" object:Nil];
            
            UIViewController *acontroller = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2];
            
            if ([acontroller isKindOfClass:[VideoPlayViewController class]]) {
                VideoPlayViewController *vc = (VideoPlayViewController *)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2];
                [vc setHashTag:hashTestField.text];
                [vc setVideoScore:0];
                
                [self.navigationController popToViewController:vc animated:YES];
            }else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else if ([requestType isEqualToString:REQUEST_FOR_GETHASHTAGS]) {
            
            [self endLoading];
            
            hashtagList = [dict objectForKey:TAG_RES_HASHTAGLIST];
        }
        
    }else {
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

-(void)viewWillLayoutSubviews{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.view.clipsToBounds = YES;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        
        self.mainContentView.frame =  CGRectMake(0, 20, self.mainContentView.frame.size.width,screenHeight-20);
        
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
    }else {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        mainContentView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 20);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [hashTestField resignFirstResponder];
}

#pragma mark -
#pragma mark Textfield Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self textChanged:hashTestField];
}

-(void)textChanged:(UITextField *)textField
{
    NSString *searchText = [hashTestField.text lowercaseString];
    
    if ([searchText length] == 0)
    {
        [self closeMenu];
        return;
    }
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
//    [resetButton setEnabled:NO];
    
    int i;
    
    NSString *childhashtag;
    NSString *parenthashtag;
    NSString *opa;
    
    myTimer = nil;
    myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                               target: self
                                             selector: @selector(closeSMenu:)
                                             userInfo: nil
                                              repeats: NO];
    
    for (i = 0; i < [hashtagList count]; i++) {
        NSDictionary *eobj = [hashtagList objectAtIndex:i];
        
        childhashtag =  [[eobj objectForKey:TAG_RES_RB_HASHTAG] lowercaseString];
        parenthashtag = [eobj objectForKey:TAG_RES_RB_PARENT_HASHTAG];
        opa = [parenthashtag lowercaseString];
        
        if ([searchText isEqualToString:childhashtag] && ![opa isEqualToString:childhashtag]) {
            break;
        }
    }
    
    if (i != [hashtagList count]) {
        confirmFlag = YES;
        for (int i = 0 ; i < 2; i++) {
            smenu = [menuArray objectAtIndex: i];
            if ([smenu isOpen]) {
                [smenu close];
            }else {
                [self setMenuItems: parenthashtag];
                [smenu showFromRect:CGRectMake(categoryBoxView.frame.origin.x, categoryBoxView.frame.origin.y + 30, categoryBoxView.frame.size.width, screenSize.height - categoryBoxView.frame.origin.y) inView:self.mainContentView];
                break;
            }
        }
        
    }else {
        for (int i = 0; i < 2; i++) {
            smenu = [menuArray objectAtIndex:i];
            if ([smenu isOpen] || [smenu isAnimating]) {
                [smenu close];
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
//                    [smenu showFromRect:CGRectMake(categoryBoxView.frame.origin.x, categoryBoxView.frame.origin.y + 30, categoryBoxView.frame.size.width, screenSize.height - categoryBoxView.frame.origin.y) inView:self.mainContentView];
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
//                [smenu showFromRect:CGRectMake(categoryBoxView.frame.origin.x, categoryBoxView.frame.origin.y + 30, categoryBoxView.frame.size.width, screenSize.height - categoryBoxView.frame.origin.y) inView:self.mainContentView];
//            }
//        }
//        confirmFlag = NO;
//    }
    
}

-(void) closeSMenu:(NSTimer*) t
{
    NSString *searchText = [hashTestField.text lowercaseString];
    
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
            }
        }
    }
}

- (void) changeCategoryTextField {
    
    NSString *searchText = hashTestField.text;
    
    int i;
    
    for (i = 0; i < [hashtagList count]; i++) {
        NSDictionary *eobj = [hashtagList objectAtIndex:i];
        
        NSString *childhashtag =  [[eobj objectForKey:TAG_RES_RB_HASHTAG] lowercaseString];
        NSString *parenthashtag = [eobj objectForKey:TAG_RES_RB_PARENT_HASHTAG];
        
        if ([searchText isEqualToString:childhashtag]) {
            hashTestField.text = parenthashtag;
            break;
        }
    }
}

- (void) closeMenu {
    for (int i = 0; i < 2; i++) {
        smenu = [menuArray objectAtIndex:i];
        if ([smenu isOpen]) {
            [smenu close];
        }
    }
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
                                                     [resetButton setEnabled:YES];
                                                     [hashTestField resignFirstResponder];
                                                 }];
        
        [smenu setStartNumber:0];
    }else {
        defaultItem = [[REMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"USE '%@' INSTEAD", title]
                                                  image:nil
                                       highlightedImage:nil
                                                 action:^(REMenuItem *item) {
                                                     [self changeCategoryTextField];
                                                     [resetButton setEnabled:YES];
                                                     [hashTestField resignFirstResponder];
                                                 }];
        
        [smenu setStartNumber:1];
    }
    
    
    
    defaultItem.tag = 0;
    [smenu setItems:@[defaultItem]];
}




@end
