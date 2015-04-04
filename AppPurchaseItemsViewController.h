//
//  AppPurchaseItemsViewController.h
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/19/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowersExchangePurchase.h"
#import <StoreKit/StoreKit.h>
#import <Accounts/Accounts.h>
#import "UIDevice+IdentifierAddition.h"
#import "OLGhostAlertView.h"
#import "UICKeyChainStore.h"

int buyInt;
@interface AppPurchaseItemsViewController : UITableViewController<NSURLConnectionDelegate,NSURLConnectionDataDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    UICKeyChainStore* store;
}

@property (strong, nonatomic) NSArray* products;
@property (strong, nonatomic) UIPickerView* accountsPicker;
@property (strong, nonatomic) UIPickerView* privacePicker;
@property (strong, nonatomic) NSMutableArray* accounts;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) UIActionSheet* actionSheet;
@property (nonatomic) int selectedTwitterAccount;
@property (nonatomic, strong) NSURLConnection* dontFollowConnection;
@property (nonatomic, strong) NSURLConnection* autoFollowConnection;
@property (nonatomic, strong) NSURLConnection* alwaysOnlineConnection;
@property (nonatomic, strong) NSURLConnection* noFollowConnection;

@property (strong, nonatomic) IBOutlet UIView *waitView;
@property (strong, nonatomic) IBOutlet UILabel *waitLabel;
@property (strong, nonatomic) NSURLConnection* pointsConnection;
@property (nonatomic)int which;

@end
