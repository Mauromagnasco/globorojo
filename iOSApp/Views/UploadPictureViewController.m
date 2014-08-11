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

#import "UploadPictureViewController.h"
#import "Constants.h"
#import "UserController.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import "AppSharedData.h"
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "MTHTTPClient.h"
#import "NSData+Base64.h"
#import "UserController.h"


#define REQUEST_FOR_UPLOADPICTURE                   @"uploadpicture"
#define REQUEST_FOR_CROPPICTURE                     @"croppicture"
#define REQUEST_FOR_NOTIFICATION                    @"notification"


@interface UploadPictureViewController ()

@end

@implementation UploadPictureViewController

@synthesize userPhotoUrl;
@synthesize recvData;
@synthesize requestType;
@synthesize activityView;
@synthesize menu;
@synthesize navTitleLabel;
@synthesize uploadPictureButton;
@synthesize profileImageView;
@synthesize viewLoading;
@synthesize uploadImage;
@synthesize imageCropper;
@synthesize contentView;
@synthesize menuButton;
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
    
    [self setStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self requestCheckNotification];

    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) setMenuItems];
    
    menu = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).menu;
    
    userPhotoUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPhotoUrl"];
    
    [self resetProfileImageView];
    
    if (userPhotoUrl != nil && ![userPhotoUrl isEqualToString:@""]) {
        imageCropper.hidden = NO;
    }else {
        imageCropper.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)onMenuButton:(id)sender {
    
    if (menu.isOpen)
        return [menu close];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [menu showFromRect:CGRectMake(0, 65, screenSize.width, screenSize.height - 45) inView:self.view];
    }else {
        [menu showFromRect:CGRectMake(0, 45, screenSize.width, screenSize.height - 45) inView:self.view];
    }
    
}

- (IBAction)onUploadPictureButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
        
        [actionSheet showInView:self.view];
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Choose Existing", nil];
        
        [actionSheet showInView:self.view];
    }
}

- (IBAction)onConfirmButton:(id)sender {
    
    if (menu.isOpen) [menu close];
    
    [self requestCropPicture];
}


#pragma mark-
#pragma mark Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"current button index : %ld", (long)buttonIndex);
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    imagePicker.allowsEditing = YES;
    
    BOOL cancel = false;
    
    if (buttonIndex == 0) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }else {
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && buttonIndex == 1) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }else {
            cancel = true;
        }
    }
    
    if (!cancel) {
        
        UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
        
//        navigationController.delegate = self;
        
        [navigationController presentViewController:imagePicker animated:YES completion:Nil];
    }
}

#pragma mark-
#pragma mark UIImagePickerController Delegate Methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {

    uploadImage = image;

    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    [navigationController dismissViewControllerAnimated:YES completion:^{
        [self requestUploadPicture];
    }];
    
    
//    [self.navigationController dismissViewControllerAnimated:YES completion:^{
//        [self requestUploadPicture];
//    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    
    [navigationController dismissViewControllerAnimated:YES completion:Nil];
    
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark Set Style Funciton

- (void) setStyle {
    
    [navTitleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    [uploadPictureButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:21.0]];
    
    //add Activity Indicator View
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat viewSize = 100;
    activityView = [[CustomActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - viewSize / 2, screenSize.height / 2 - viewSize / 2, viewSize, viewSize)];
    [viewLoading addSubview:activityView];
    viewLoading.hidden = YES;
    
    imageCropper = [[NLImageCropperView alloc] initWithFrame:profileImageView.frame];
    [contentView addSubview:imageCropper];
    [imageCropper setCropRegionRect:CGRectMake(0, 0, 28, 28)];
}

#pragma mark - 
#pragma mark Change Profile Image with userPhotoUrl

- (void) resetProfileImageView {
    
    UIImage *pImage;
    if ([userPhotoUrl isEqualToString:@""] || userPhotoUrl == nil) {
        pImage = [UIImage imageNamed:@"profileImage.png"];
        [profileImageView setImage:pImage];
    }else{
        pImage = [[[AppSharedData sharedInstance] storeImage] objectForKey:userPhotoUrl];
        
        if (pImage == nil) {
            
            NSURL *url = [NSURL URLWithString:userPhotoUrl];
            
            AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:url] success:^(UIImage *image) {
                
                [profileImageView setImage:image];
                [imageCropper setImage:image];
                [imageCropper setCropRegionRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                
                [[[AppSharedData sharedInstance] storeImage] setObject:image forKey:userPhotoUrl];
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
            [imageCropper setImage:pImage];
            [imageCropper setCropRegionRect:CGRectMake(0, 0, pImage.size.width, pImage.size.height)];
            [profileImageView setImage:pImage];
        }
    }

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
#pragma mark Request Funcitons

- (void) requestUploadPicture {
    
    [self startLoading];
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, UPLOAD_PICTURE_URL];
    
    NSData *imageData = UIImagePNGRepresentation([self resizeImage:uploadImage]);
    NSString *imageDataEncodedeString = [imageData base64Encoding];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            imageDataEncodedeString, TAG_REQ_IMAGEDATA,
                            @"png", TAG_REQ_IMAGETYPE,
                            nil];
    
    [[MTHTTPClient sharedClient] postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self endLoading];
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
        
        [self parseData:responseStr];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self endLoading];
        
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void) requestCropPicture {

    [self startLoading];
    
    //make URL
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", SERVER_HOST, CROP_PICTURE_URL];
    
    CGRect cropRect = [imageCropper getCropRect];
    
    //make request
    NSString * key = [NSString stringWithFormat:@"%@=%@&%@=%f&%@=%f&%@=%f&%@=%f&%@=%d&%@=%d&%@=%@",
                      TAG_REQ_USERID, [[UserController instance] userUserID],
                      TAG_REQ_X, cropRect.origin.x,
                      TAG_REQ_Y, cropRect.origin.y,
                      TAG_REQ_W, cropRect.size.width,
                      TAG_REQ_H, cropRect.size.height,
                      TAG_REQ_SWITDH, 240,
                      TAG_REQ_SHEIGHT, 240,
                      TAG_REQ_SRCIMG, userPhotoUrl];
    
    
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
    
    requestType = REQUEST_FOR_CROPPICTURE;
    
    // connect server
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) requestCheckNotification {
    
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
    
    dict = (NSDictionary*)[jsonParser objectWithString:text];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        if ([requestType isEqualToString:REQUEST_FOR_CROPPICTURE]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your image saved successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [alert show];
        }else if ([requestType isEqualToString:REQUEST_FOR_NOTIFICATION]){
            
            NSString *checkFlag = [dict objectForKey:TAG_RES_ISNEWNOTIFICATION];
            
            if ([checkFlag isEqualToString:@"Y"]) {
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenuRed.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notificationrise"];
            }else {
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btnMenu.png"] forState:UIControlStateNormal];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notificationrise"];
            }
            
        }
        

        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        if ([errorMsg isEqualToString:@""]) {
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
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
#pragma mark Parse Data with Response Data

- (void) parseData: (NSString *) responseStr {
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    
    NSDictionary *dict;
    
    dict = (NSDictionary*)[jsonParser objectWithString:responseStr];
    
    NSString *successFlag = [dict objectForKey:TAG_RES_RESULT];
    
    if ([successFlag isEqualToString:TAG_SUCCCESS]) {
        
        userPhotoUrl = [dict objectForKey:TAG_RES_PHOTO];
        
        [self resetProfileImageView];
        
    }else {
        NSString *errorMsg = [dict objectForKey:TAG_RES_ERROR];
        if ([errorMsg isEqualToString:@""]) {
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
    }
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

#pragma mark - Resize Image

- (UIImage *)resizeImage:(UIImage *)image {
    
    CGFloat w = 320;
    CGFloat h = image.size.height * w / image.size.width;
    
    CGSize newSize = CGSizeMake(w, h);  //whaterver size
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark -
#pragma mark NavigationController Delegate Functions

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//}

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
