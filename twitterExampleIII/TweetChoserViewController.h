//
//  TweetChoserViewController.h
//  retweetlyy
//
//  Created by OsamaMac on 1/5/14.
//  Copyright (c) 2014 OsamaMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "GADBannerView.h"
#import <StoreKit/StoreKit.h>
#import "FollowersExchangePurchase.h"

@interface TweetChoserViewController : UITableViewController
{
    NSMutableArray* dataSource;
    NSArray* accounts;
    ACAccountStore *accountStore;
    CGFloat screenHeight;
    CGFloat screenWidth;
}

@property (strong, nonatomic) NSArray* products;
@property (strong, nonatomic) IBOutlet UIView *waitView;
@property (strong, nonatomic) IBOutlet UILabel *waitLabel;
@property (strong, nonatomic) NSString* twitterAPI;
@property (strong, nonatomic)GADBannerView* bannerView;
@property (nonatomic) int twitterIndex;
@property (nonatomic, strong)SKProduct *productToBuy;

@end
