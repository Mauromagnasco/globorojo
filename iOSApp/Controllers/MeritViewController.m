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

#import "MeritViewController.h"
#import "Constants.h"
#import "UserController.h"
#import "categoryIteminfo.h"
#import "IFTweetLabel.h"
#import "SearchViewController.h"
#import "AppDelegate.h"


@interface MeritViewController ()

@end

@implementation MeritViewController

@synthesize meritDescriptionLabel;
@synthesize meritNameLabel;
@synthesize meritUsernameLabel;
@synthesize meritUserscoreImageView;
@synthesize meritUserscoreLabel;

@synthesize data;
@synthesize categoryItemArray;
@synthesize rbCred;
@synthesize rbName;
@synthesize rbUserName;
@synthesize labelArray;

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
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"linkCount"];
    
    labelArray = [[NSMutableArray alloc] init];
    categoryItemArray = [[NSMutableArray alloc] init];
    
    [self parseData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchView:) name:IFTWeetLabelPostNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setStyle {
    [meritUserscoreLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
    [meritUsernameLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
    [meritDescriptionLabel setFont:[UIFont fontWithName:CUSTOM_FONT size:17.0]];
}

- (void) parseData {
    
    NSMutableArray *categoryList;
    
    categoryList = [data objectForKey:TAG_RES_CATEGORYLIST];
    
    for (int i = 0; i < [categoryList count]; i++) {
        NSDictionary *rdict = [categoryList objectAtIndex:i];
        
        categoryIteminfo *item = [[categoryIteminfo alloc] init];
        
        item.rbHashtag = [rdict objectForKey:TAG_RES_RB_HASHTAG];
        
        NSString *scoreStr = [rdict objectForKey:TAG_RES_SCORE];
        
        if ([scoreStr isEqual:[NSNull null]]) {
            scoreStr = @"0";
        }
        item.score = [scoreStr floatValue];
        
        [categoryItemArray addObject:item];
    }
    
    rbUserName = [data objectForKey:TAG_RES_RB_USERNAME];
    rbCred = [data objectForKey:TAG_RES_RB_CRED];
    rbName = [data objectForKey:TAG_RES_RB_NAME];
    
    [self applyMeritValue];
    
}


#pragma mark -
#pragma mark applyMeritValue

- (void) applyMeritValue {
    
    if ([rbCred isEqual:[NSNull null]]) {
        rbCred = @"0";
    }
    
    float userscore = [rbCred floatValue];
    
    [self changeMeritUserscoreImageView: userscore];
    
    if (![rbName isEqual:[NSNull null]] && ![rbName isEqualToString:@""]) {
        meritNameLabel.text = rbName;
    }
    
    
    if ([meritNameLabel.text isEqualToString:@""]) {
        meritUsernameLabel.center = CGPointMake(meritUsernameLabel.center.x, 37);
        meritUserscoreImageView.center = CGPointMake(meritUserscoreImageView.center.x, 155);
        meritUserscoreLabel.center = CGPointMake(meritUserscoreLabel.center.x, 155);
        meritDescriptionLabel.center = CGPointMake(meritDescriptionLabel.center.x, 290);
    }
    
    [labelArray removeAllObjects];
    
    meritUsernameLabel.text = [NSString stringWithFormat:@"@%@", rbUserName];
    
    if (![rbCred isEqual:[NSNull null]]) {
        meritUserscoreLabel.text = [NSString stringWithFormat:@"%.2f", [rbCred floatValue]];
    }
    
    
    int sy = 320;
    if ([meritNameLabel.text isEqualToString:@""]) {
        sy = 305;
    }
    
    NSString *txt;
    CGSize stringsize;
    
    for (int i = 0; i < [categoryItemArray count]; i++) {
        categoryIteminfo *item = [categoryItemArray objectAtIndex:i];
        
        txt = [NSString stringWithFormat:@"#%@ = %.2f", item.rbHashtag, item.score];
        stringsize = [txt sizeWithFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
        IFTweetLabel *label = [[IFTweetLabel alloc] initWithFrame:CGRectMake((320 - stringsize.width) / 2 ,sy, stringsize.width,18)];
        [label setText:txt];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setButtonFontColor:[UIColor whiteColor]];
        [label setFont:[UIFont fontWithName:CUSTOM_FONT size:14.f]];
        [label setButtonFontSize:14.f];
        label.linksEnabled = YES;
        
        
        [labelArray addObject:label];
        IFTweetLabel *rlabel = [labelArray objectAtIndex:i];
        
        [self.view addSubview:rlabel];
        sy += label.frame.size.height - 3;
        
    }
    
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, sy + 20)];
}

#pragma mark -
#pragma mark Change the User Score Image View

- (void) changeMeritUserscoreImageView: (float) videoScore {
    
    int score = (int) videoScore;
    
    float mv = videoScore - (float) score;
    
    if (mv >= 0.5) {
        score ++;
    }
    
    switch (score) {
        case 0:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed0.png"]];
            break;
            
        case 1:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed1.png"]];
            break;
            
        case 2:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed2.png"]];
            break;
            
        case 3:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed3.png"]];
            break;
            
        case 4:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed4.png"]];
            break;
            
        case 5:
            [meritUserscoreImageView setImage:[UIImage imageNamed:@"pieRed5.png"]];
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark NSNotication Functions

- (void) showSearchView: (NSNotification *) notification {
    
    int linkCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"linkCount"] intValue];
    
    if (linkCount != 0) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"linkCount"];
    
    UINavigationController *navigationController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController;
    
    SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    
    NSString *searchText = [[[NSUserDefaults standardUserDefaults] objectForKey:IFTweetLabelButtonTitle] substringFromIndex:1];
    
    [searchViewController setSearchText:searchText];
    
    [navigationController pushViewController:searchViewController animated:YES];
    
    
}

@end
