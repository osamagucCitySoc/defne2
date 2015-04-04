//
//  RulesViewController.m
//  twitterExampleIII
//
//  Created by Housein Jouhar on 2/16/14.
//  Copyright (c) 2014 MacBook. All rights reserved.
//

#import "RulesViewController.h"

@interface RulesViewController ()

@end

@implementation RulesViewController

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
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, 560)];
}

- (IBAction)closeTheView:(id)sender {
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newRules8"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
