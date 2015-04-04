//
//  HomeViewController.h
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TWAPIManager.h"
#import "TWAPIManagerTemp.h"

#import "TWAPIManagerSource1.h"
#import "TWAPIManagerSource2.h"
#import "TWAPIManagerSource3.h"
#import "TWAPIManagerSource4.h"

#import "AsyncImageView.h"
#import "RNBlurModalView.h"
#import <QuartzCore/QuartzCore.h>
#import "SIAlertView.h"
#import "OLGhostAlertView.h"
#import <StoreKit/StoreKit.h>
#import "FollowersExchangePurchase.h"
#import "UIDevice+IdentifierAddition.h"
#import "GADInterstitial.h"
#import "GADBannerView.h"
#import <Social/Social.h>

@interface HomeTwoViewController : UITableViewController<NSURLConnectionDelegate,UIActionSheetDelegate,GADInterstitialDelegate>
{
    int actionFlag;
}
- (IBAction)backClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *myProgress;
@property (strong, nonatomic) NSString *oauthToken;
@property (strong, nonatomic) NSString *oauthTokenSecret;
@property (strong, nonatomic) IBOutlet UIView *followingView;

@property (strong, nonatomic) NSString *oauthTokenTemp;
@property (strong, nonatomic) NSString *oauthTokenSecretTemp;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) TWAPIManagerTemp *apiManagerTemp;

@property (nonatomic, strong) TWAPIManagerSource1 *apiManagerTempS1;
@property (nonatomic, strong) TWAPIManagerSource2 *apiManagerTempS2;
@property (nonatomic, strong) TWAPIManagerSource3 *apiManagerTempS3;
@property (nonatomic, strong) TWAPIManagerSource4 *apiManagerTempS4;

@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic) int accountIndex;

@property (nonatomic, strong) NSURLConnection* autoFollowConnection;
@property (nonatomic, strong) NSURLConnection* loadProfilesConnection;
@property (nonatomic, strong) NSURLConnection* checkSpecialConnection;
@property (nonatomic, strong) NSURLConnection* specialConnection;
@property (nonatomic, strong) NSURLConnection* followOthersConnection;
@property (nonatomic, strong) NSURLConnection* registerConnection;
@property (nonatomic, strong) NSURLConnection* registerConnectionTemp;
@property (nonatomic, strong) NSURLConnection* pointsConnection;
@property (nonatomic, strong) NSMutableArray* dataSource;
@property (nonatomic, strong)RNBlurModalView *modal;
@property (strong, nonatomic) IBOutlet UIView *waitView;
@property (strong, nonatomic) IBOutlet UIView *theHeaderView;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UIView *theFooterView;
@property (strong, nonatomic) IBOutlet UILabel *waitLabel;
@property (strong, nonatomic) NSArray* products;
@property (nonatomic) int followTimes;
@property (strong, nonatomic) GADInterstitial *interstitial_;
@property (strong, nonatomic)GADBannerView* bannerView;

@property (weak, nonatomic) IBOutlet UIButton *specialButton;
@property (nonatomic) BOOL loadingProfiles;
@property (nonatomic) BOOL FB;
@property (nonatomic) BOOL followingProfiles;
- (IBAction)followAll:(id)sender;
- (IBAction)makeMeFac:(id)sender;

@end
