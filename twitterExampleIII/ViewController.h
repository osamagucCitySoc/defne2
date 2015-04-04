//
//  ViewController.h
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TWAPIManager.h"

@interface ViewController : UIViewController


@property (strong, nonatomic) NSString *oauthToken;
@property (strong, nonatomic) NSString *oauthTokenSecret;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic) int accountIndex;

@end
