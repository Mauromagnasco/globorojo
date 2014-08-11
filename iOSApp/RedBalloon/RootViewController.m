//
//  RootViewController.m
//  RedBalloon
//
//  Created by Mr. RI on 2/20/14.
//  Copyright (c) 2014 Mr. RI. All rights reserved.
//

#import "RootViewController.h"
#import "WelcomeViewController.h"
#import "UserController.h"
#import "HomeViewController.h"
#import "SearchViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    if ([[UserController instance] userUserID]) {
//        HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:Nil];
//        
//        [self.navigationController pushViewController:homeViewController animated:NO];
        
        SearchViewController *searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
        [self.navigationController pushViewController:searchView animated:NO];
    }else {
        WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:Nil];
    
        [self.navigationController pushViewController:welcomeViewController animated:NO];
    }
}


@end
