//
//  AppDelegate.h
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowersExchangePurchase.h"
#import <AudioUnit/AudioUnit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray* accounts;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSURLConnection *buyFollowerConnection;
@property (nonatomic, strong) NSURLConnection *adsConnection;

@end
