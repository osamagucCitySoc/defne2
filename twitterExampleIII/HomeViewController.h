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
#import <QuartzCore/QuartzCore.h>

#import <Social/Social.h>
#import "OLGhostAlertView.h"

#import "UIDevice+IdentifierAddition.h"
<<<<<<< HEAD
#import "GADBannerView.h"
#import <Security/Security.h>
#import "UICKeyChainStore.h"
#import "GADInterstitial.h"
=======
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Security/Security.h>
#import "UICKeyChainStore.h"
//#import "GADInterstitial.h"
>>>>>>> localmaster

@interface HomeViewController : UITableViewController<NSURLConnectionDelegate,NSURLConnectionDataDelegate,UIActionSheetDelegate,UIWebViewDelegate,GADInterstitialDelegate,UIAlertViewDelegate>
{
    BOOL isSpecial,isAutoFollows,isNoFollows,isDiamond;
    UICKeyChainStore* store;
    int numberOfLoads;
}

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (strong, nonatomic) IBOutlet UIProgressView *myProgress;

@property (nonatomic, strong) ACAccountStore *accountStore;

@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic) int accountIndex;
@property (nonatomic, strong) NSURLConnection* loadProfilesConnection;
@property (nonatomic, strong) NSURLConnection* autoFollowConnection;
@property (nonatomic, strong) NSURLConnection* blockRequestConnection;
@property (nonatomic, strong) NSURLConnection* deleteConnection;
@property (nonatomic, strong) NSURLConnection* checkMyAccountConnection;

@property (nonatomic, strong) NSMutableArray* dataSource;
@property (nonatomic, strong) NSMutableArray* dataSourceAuto;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic) int selected;
@property (nonatomic) BOOL loadingProfiles;
@property (nonatomic) BOOL followingProfiles;
@property (nonatomic) BOOL FB;

@property (strong, nonatomic)GADBannerView* bannerView;
@property (strong, nonatomic) IBOutlet UIView *waitView;
@property (strong, nonatomic) IBOutlet UIView *theHeaderView;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UIView *theFooterView;
@property (strong, nonatomic) IBOutlet UILabel *waitLabel;

@property (strong, nonatomic) IBOutlet UIImageView *unlimitedImage;
@property (strong, nonatomic) IBOutlet UILabel *unlimitedLabel;

@property (strong, nonatomic) IBOutlet UIImageView *autoFollowImage;
@property (strong, nonatomic) IBOutlet UILabel *autoFollowLabel;
@property (strong, nonatomic) IBOutlet UIView *theMainView;
@property (strong, nonatomic) IBOutlet UINavigationItem *theMainLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) GADInterstitial *interstitial_;

- (IBAction)backClicked:(id)sender;
- (IBAction)followAll:(id)sender;
- (IBAction)cancelMyAccount:(id)sender;

@end
