//
//  tabBarViewController.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/20/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "tabBarViewController.h"

@interface tabBarViewController ()

@end

@implementation tabBarViewController

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
    [[self.navigationController navigationBar]setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tabBarController:(UITabBarController *)tabBarController
didSelectViewController:(UIViewController *)viewController {
  
}

@end
