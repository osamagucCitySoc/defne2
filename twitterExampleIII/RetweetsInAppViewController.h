//
//  RetweetsInAppViewController.h
//  twitterExampleIII
//
//  Created by Osama Rabie on 1/3/15.
//  Copyright (c) 2015 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowersExchangePurchase.h"
#import <StoreKit/StoreKit.h>
#import <Accounts/Accounts.h>
#import "UIDevice+IdentifierAddition.h"
#import "OLGhostAlertView.h"
#import "UICKeyChainStore.h"
#import "ActionSheetPicker.h"

@interface RetweetsInAppViewController : UIViewController<NSURLConnectionDataDelegate, NSURLConnectionDelegate>


@property (strong, nonatomic) NSArray* products;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
