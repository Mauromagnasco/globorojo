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

#import "AddCommentViewController.h"
#import "Constants.h"
#import "UserController.h"
#import "SBJson.h"
#import "AppSharedData.h"

@interface AddCommentViewController ()

@end

@implementation AddCommentViewController

@synthesize commentTextView;
@synthesize commentTextField;
@synthesize videoID;
@synthesize recvData;
@synthesize supernumber;
@synthesize content;

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
    
    connecting = false;
}

- (void)viewDidAppear:(BOOL)animated {

    [self setStyle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSendButton:(id)sender {
    [commentTextView resignFirstResponder];
    
    if ([commentTextView.text isEqualToString:@""] || connecting) {
        return;
    }
    connecting = true;
    [self requestAddComment];
}

- (IBAction)onDeleteButton:(id)sender {
    commentTextField.hidden = NO;
    commentTextView.text = @"";
}

- (void) setStyle {
    
    [commentTextField setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    [commentTextView setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
    
    commentTextField.enabled = NO;
    commentTextView.delegate = self;
    [commentTextView setContentSize:CGSizeMake(commentTextView.frame.size.width, commentTextView.frame.size.height / 2)];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyClose:) name:@"WatchScrollViewTapped" object:nil];
}

- (void) keyClose:(NSNotification *) notification  {
    [commentTextField resignFirstResponder];
    [commentTextView resignFirstResponder];
    
    NSString *superController = [[NSUserDefaults standardUserDefaults] objectForKey:@"SuperController"];
    if ([superController isEqualToString:@"Home"]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeViewHide" object:nil];
    }else if ([superController isEqualToString:@"Search"]){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchViewHide" object:nil];
    }else if ([superController isEqualToString:@"Profile"]){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileViewHide" object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchDetailViewShow" object:nil];
    }
}

#pragma mark -
#pragma mark UITextView Delegate Methods
- (void)textViewDidChange:(UITextView *)textView {
    if (![textView.text isEqualToString:@""]) {
        commentTextField.hidden = YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [commentTextView setContentOffset:CGPointMake(commentTextView.contentOffset.x, commentTextView.contentOffset.y + 30) animated:YES];
    }
    
    return YES;
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    CGPoint localPoint = [self.view bounds].origin;
    CGPoint basePoint = [self.view convertPoint:localPoint toView:nil];
    
    NSLog(@"%f, %f", localPoint.x, localPoint.y);
    NSLog(@"%f, %f", basePoint.x, basePoint.y);
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (screenSize.height - basePoint.y - 90 < 220) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:basePoint.y + 90] forKey:@"CurrentPosition"];

        NSString *superController = [[NSUserDefaults standardUserDefaults] objectForKey:@"SuperController"];
        if ([superController isEqualToString:@"Home"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeViewHide" object:nil];
        }else if ([superController isEqualToString:@"Search"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchViewHide" object:nil];
        }else if ([superController isEqualToString:@"Profile"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileViewHide" object:nil];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchDetailViewHide" object:nil];
        }
    }
    
    return YES;
}

#pragma mark - 
#pragma mark Request for Add Comment Function

- (void) requestAddComment {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, SAVE_COMMENT_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_VIDEOID, videoID,
                      TAG_REQ_TXTCOMMENT, commentTextView.text];
    
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
    
    //delete the text of commentTextView
    content = commentTextView.text;
    commentTextView.text = @"";
    commentTextField.hidden = NO;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    
    [self.recvData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    connecting = false;
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
        
        
        NSString *username = [dict objectForKey:TAG_RES_USERNAME];
        
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"CommentUserName"];
        [[NSUserDefaults standardUserDefaults] setObject:content forKey:@"CommentContent"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:supernumber] forKey:@"ViewNumber"];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:TAG_RES_COMMENTID] forKey:@"CommentID"];
        
        NSString *superController = [[NSUserDefaults standardUserDefaults] objectForKey:@"SuperController"];
        if ([superController isEqualToString:@"Home"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeAddCommentItem" object:nil];
        }else if ([superController isEqualToString:@"Search"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchAddCommentItem" object:nil];
        }else if ([superController isEqualToString:@"Profile"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileAddCommentItem" object:nil];
            
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchDetailAddCommentItem" object:nil];
        }
        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        if (![errorMsg isEqualToString:@""] && errorMsg != Nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            alert.delegate = self;
            [alert show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

@end
