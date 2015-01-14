//
//  ChooseAccountViewController.h
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AboutViewController.h"
#import "UIDevice+IdentifierAddition.h"
#import "GADBannerView.h"
#import "UICKeyChainStore.h"


@class AboutViewController;

BOOL isCloseAbout,isFinishLoading,isFirstL,isDoneHelpView,firImageShowing,secImageShowing;

NSInteger tableClickedIndex;

@interface ChooseAccountViewController : UITableViewController<UIActionSheetDelegate,UIAlertViewDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    UICKeyChainStore *store;
}

@property (strong, nonatomic) IBOutlet UIButton *helpButton;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage;
@property (strong, nonatomic)GADBannerView* bannerView;
@property (strong, nonatomic) IBOutlet AboutViewController *aboutController;
@property (strong, nonatomic) NSArray* accounts;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (strong, nonatomic) IBOutlet UIView *mainWaitView;
@property (nonatomic, strong) NSURLConnection *buyFollowerConnection;
@property (nonatomic, strong) NSURLConnection *pointsConnection;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *topAboutButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *topBuyButton;

@end
