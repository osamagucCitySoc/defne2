//
//  InAppController.h
//  twitterExampleIII
//
//  Created by Housein Jouhar on 19/10/14.
//  Copyright (c) 2014 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowersExchangePurchase.h"
#import <StoreKit/StoreKit.h>
#import <Accounts/Accounts.h>
#import "UIDevice+IdentifierAddition.h"
#import "OLGhostAlertView.h"
#import "UICKeyChainStore.h"
#import "ActionSheetPicker.h"

@interface InAppController : UIViewController
{
    UICKeyChainStore* store;
}

@property (strong, nonatomic) IBOutlet UIScrollView *allScrollView;
@property (strong, nonatomic) NSArray* products;

@end
