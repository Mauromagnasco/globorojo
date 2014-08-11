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

#import "SignUpRegistrationViewController.h"
#import "Constants.h"
#import "SBJson.h"
#import "AppSharedData.h"
#import "MTHTTPClient.h"
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "HomeViewController.h"
#import "UserController.h"
#import "AppDelegate.h"
#import "SearchViewController.h"

@interface SignUpRegistrationViewController ()

@end

@implementation SignUpRegistrationViewController

@synthesize navTitleLabel;
@synthesize descriptionLabel;
@synthesize nameTextField;
@synthesize emailAddressTextField;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize profileImageView;
@synthesize viewLoading;
@synthesize scrollView;
@synthesize usernameDeleteButton;

@synthesize recvData;
@synthesize activityView;
@synthesize name;
@synthesize photoUrl;
@synthesize userSnsId;
@synthesize mainContentView;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setStyle];
}


#pragma mark -
#pragma mark Set Style Functions
- (void) setStyle {
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:22.f]];
    [descriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:18.f]];
    [emailAddressTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.f]];
    [passwordTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.f]];
    [usernameTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.f]];
    [nameTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:21.f]];
    
    usernameTextField.delegate = self;
    passwordTextField.delegate = self;
    emailAddressTextField.delegate = self;
    nameTextField.enabled = NO;
    usernameDeleteButton.enabled = NO;
    
    //add Activity Indicator View
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 100;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
    
    nameTextField.text = name;
    
    UIImage *pImage;
    
    pImage = [[[AppSharedData sharedInstance] storeImage] objectForKey:photoUrl];
    
    if (pImage == nil) {
        
        NSURL *url = [NSURL URLWithString:photoUrl];
        
        [self startLoading];
        AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:url] success:^(UIImage *image) {

            [self endLoading];
            [profileImageView setImage:image];
            
//            [[[AppSharedData sharedInstance] storeImage] setObject:image forKey:photoUrl];
            //[activityIndicator removeFromSuperview];
            
        }];
        
        
        [imageOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
         {
             float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
             NSLog(@"UserProfileImage ---------------- PROGRESS - %f -------- %f ---------- %lld", progress, (float)totalBytesRead, totalBytesExpectedToRead); //Can be deleted once the progress bar works.
             
         }];
        
        
        //        [httpClient enqueueHTTPRequestOperation:imageOperation];
        
        [[MTHTTPClient sharedClient] enqueueHTTPRequestOperation:imageOperation];
    }else {
        [profileImageView setImage:pImage];
    }
    
    [scrollView setContentSize:CGSizeMake(320, 568)];
    
}

#pragma mark -
#pragma mark IBAction Functions

- (IBAction)onBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onEmailAddressDeleteButton:(id)sender {
    emailAddressTextField.text = @"";
}


- (IBAction)onPasswordDeleteButton:(id)sender {
    passwordTextField.text = @"";
}

- (IBAction)onNameDeleteButton:(id)sender {
    nameTextField.text = @"";
}

- (IBAction)onUsernameDeleteButton:(id)sender {
    usernameTextField.text = @"";
}

- (IBAction)onConfirmButton:(id)sender {
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    if ([usernameTextField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Username mustn't include space, special characters." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
        return;
    }
    
    [self request_Registration];
}

#pragma mark -
#pragma mark Activity Loading View Show and Hidden Part

- (void)startLoading{
    [activityView startAnimation];
    viewLoading.hidden = NO;
}

- (void)endLoading{
    viewLoading.hidden = YES;
    [activityView stopAnimation];
}

#pragma mark -
#pragma mark Request Functions

- (void) request_Registration {

    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SIGNUP_REGISTRATION_URL];
    
    //make request
    
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",
                      TAG_REQ_USERSNSID, userSnsId,
                      TAG_REQ_USERNAME, usernameTextField.text,
                      TAG_REQ_EMAIL, emailAddressTextField.text,
                      TAG_REQ_NAME, name,
                      TAG_REQ_PASSWORD, passwordTextField.text,
                      TAG_REQ_PHOTO, photoUrl];
    
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

        NSString *userid = [NSString stringWithFormat:@"%@", [dict objectForKey:TAG_RES_USERID]];
        [[UserController instance] setUserUserID:userid];
        
//        HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:Nil];
//            
//        [self.navigationController pushViewController:homeViewController animated:YES];
        
        SearchViewController *searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
        
        [self.navigationController pushViewController:searchView animated:YES];

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

#pragma mark -
#pragma mark UITextField Resign First Responder Functions
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [usernameTextField resignFirstResponder];
    [emailAddressTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [usernameTextField resignFirstResponder];
    [emailAddressTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
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

@end
