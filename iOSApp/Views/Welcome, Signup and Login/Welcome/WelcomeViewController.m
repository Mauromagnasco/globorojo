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

#import "WelcomeViewController.h"
#import "Constants.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "AppDelegate.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

@synthesize descriptionLabel;
@synthesize rcodeTextField;
@synthesize mainContentView;
@synthesize signDesLabel;
@synthesize loginDesLabel;

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
    
    [self setStyle];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSignupButton:(id)sender {
    SignUpViewController *signupViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:Nil];
    
    [self.navigationController pushViewController:signupViewController animated:YES];
}

- (IBAction)onLoginButton:(id)sender {
    
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:Nil];
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (IBAction)onDeleteButton:(id)sender {
    rcodeTextField.text = @"";
}


#pragma mark Set Style of View Method
- (void) setStyle {
    [descriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:13.f]];
    [signDesLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:13.f]];
    [loginDesLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:13.f]];
    [descriptionLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
    [rcodeTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:19.f]];
    rcodeTextField.delegate = self;
}

#pragma mark - Textfield Delegate Functions
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [rcodeTextField resignFirstResponder];
    
    return YES;
}

#pragma mark - Touch Event Funtions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [rcodeTextField resignFirstResponder];
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
