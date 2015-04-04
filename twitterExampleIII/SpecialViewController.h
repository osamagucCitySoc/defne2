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

#import "AsyncImageView.h"
#import "RNBlurModalView.h"
#import <QuartzCore/QuartzCore.h>
#import "SIAlertView.h"
#import <Social/Social.h>
#import "OLGhostAlertView.h"
#import "MKNumberBadgeView.h"
#import "UIDevice+IdentifierAddition.h"
#import "GADBannerView.h"
#import <Security/Security.h>
#import "UICKeyChainStore.h"
#import "GADInterstitial.h"

@interface SpecialViewController : UITableViewController<NSURLConnectionDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIWebViewDelegate,GADInterstitialDelegate>
{
    BOOL isSpecial,isAutoFollows,isNoFollows,isDoneMsg;
    UICKeyChainStore* store;
    int numberOfLoads;
}

@property (strong, nonatomic) IBOutlet UIProgressView *myProgress;

@property (nonatomic, strong) ACAccountStore *accountStore;

@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic) int accountIndex;
@property (nonatomic) BOOL newFollowers;
@property (nonatomic, strong) NSURLConnection* loadProfilesConnection;
@property (nonatomic, strong) NSURLConnection* autoFollowConnection;
@property (nonatomic, strong) NSURLConnection* followedConnection;
@property (nonatomic, strong) NSURLConnection* followActionConnection;
@property (nonatomic, strong) NSURLConnection* blockRequestConnection;
@property (nonatomic, strong) NSURLConnection* deleteConnection;
@property (nonatomic, strong) NSURLConnection* checkMyAccountConnection;
@property (nonatomic, strong) NSURLConnection* onlineConnection;

@property (nonatomic, strong) NSMutableArray* dataSource;
@property (nonatomic, strong) NSMutableArray* dataSourceAuto;
@property (nonatomic, strong)RNBlurModalView *modal;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic) int selected;
@property (nonatomic) BOOL loadingProfiles;
@property (nonatomic) BOOL followingProfiles;
@property (strong, nonatomic) IBOutlet UIView *followingView;
@property (nonatomic) BOOL FB;
@property (nonatomic) int followTimes;


@property (strong, nonatomic) IBOutlet UIView *waitView;
@property (strong, nonatomic) IBOutlet UIView *theHeaderView;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UIView *theFooterView;
@property (strong, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic)GADBannerView* bannerView;
@property (strong, nonatomic) IBOutlet UIView *statusView;
@property (strong, nonatomic) IBOutlet UIImageView *specialImage;
@property (strong, nonatomic) IBOutlet UILabel *specialLabel;
@property (strong, nonatomic) IBOutlet UIImageView *unlimitedImage;
@property (strong, nonatomic) IBOutlet UILabel *unlimitedLabel;
@property (strong, nonatomic) IBOutlet UIImageView *noFollowImage;
@property (strong, nonatomic) IBOutlet UILabel *noFollowLabel;
@property (strong, nonatomic) IBOutlet UIImageView *autoFollowImage;
@property (strong, nonatomic) IBOutlet UILabel *autoFollowLabel;
@property (strong, nonatomic) IBOutlet UIView *theMainView;
@property (strong, nonatomic) IBOutlet UINavigationItem *theMainLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) GADInterstitial *interstitial_;

- (IBAction)backClicked:(id)sender;
- (IBAction)followAll:(id)sender;
- (IBAction)cancelMyAccount:(id)sender;
- (IBAction)checkMyAccount:(id)sender;

@end
