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

#import "CommentViewController.h"
#import "Constants.h"
#import "UserController.h"
#import "SBJson.h"
#import "AppSharedData.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

@synthesize contentText;
@synthesize tweetLabel;
@synthesize data;
@synthesize commentUserId;
@synthesize commentId;
@synthesize commentNumber;
@synthesize videoNumber;
@synthesize recvData;
@synthesize requestType;

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

- (void)viewDidAppear:(BOOL)animated {
    [self setStyle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onShareButton:(id)sender {
    
    if ([commentUserId isEqualToString:[[UserController instance] userUserID]]) {
        requestType = @"1";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to delete this comment?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    }else {

        requestType = @"3";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to report this comment?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
        
    }
}

- (void) setStyle {
    
    self.tweetLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(6, 0, 290, 36)];
    
    [self.tweetLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:11.5f]];
    [self.tweetLabel setButtonFontSize:11.5f];
    [self.tweetLabel setTextColor:[UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0]];
    [self.tweetLabel setButtonFontColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]];
	[self.tweetLabel setBackgroundColor:[UIColor clearColor]];
	[self.tweetLabel setNumberOfLines:0];
    
    contentText = [NSString stringWithFormat:@"@%@ : %@", [data objectForKey:TAG_RES_RB_USERNAME], [data objectForKey:TAG_RES_RB_CONTENT]];

    [self.tweetLabel setText:contentText];
	[self.tweetLabel setLinksEnabled:YES];
    [self.view addSubview:tweetLabel];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.tweetLabel.frame.size.height)];
    
    commentUserId = [data objectForKey:TAG_RES_RB_USER];
    commentId = [data objectForKey:TAG_RES_RB_USER_VIDEO_COMMENT];
}

#pragma mark-
#pragma mark UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [alertView cancelButtonIndex]) {
        if ([requestType isEqualToString:@"1"]) {
            [self requestDeleteComment];
        }else if ([requestType isEqualToString:@"3"]){
            [self requestReportComment];
        }

    }else {
        if ([requestType isEqualToString:@"2"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:videoNumber] forKey:@"RemoveVideoNumber"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:commentNumber] forKey:@"RemoveCommentNumber"];
            
            NSString *superController = [[NSUserDefaults standardUserDefaults] objectForKey:@"SuperController"];
            if ([superController isEqualToString:@"Home"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeRemoveCommentItem" object:Nil];
            }else if ([superController isEqualToString:@"Search"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchRemoveCommentItem" object:Nil];
            }else if ([superController isEqualToString:@"Profile"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileRemoveCommentItem" object:Nil];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchDetailRemoveCommentItem" object:Nil];                
            }
        }
    }
    
}

#pragma mark -
#pragma mark Request for Delete Comment
- (void) requestDeleteComment {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, DELETE_COMMENT_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@",TAG_REQ_COMMENTID, commentId];
    
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

- (void) requestReportComment {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, REPORT_COMMENT_URL];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_COMMENTID, commentId];
    
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
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:@"1"]) {
            requestType = @"2";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Comment deleted successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
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
    
    NSString *text = [error localizedDescription];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}


@end
