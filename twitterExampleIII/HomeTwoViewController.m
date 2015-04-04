//
//  HomeViewController.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "HomeTwoViewController.h"

@interface HomeTwoViewController ()

@end

@implementation HomeTwoViewController

@synthesize oauthToken,oauthTokenSecret,accounts,accountStore,apiManager,accountIndex,registerConnection,followOthersConnection,loadProfilesConnection,dataSource,modal,pointsLabel,products,specialConnection,specialButton,checkSpecialConnection,followingProfiles,loadingProfiles,pointsConnection,followTimes,interstitial_,bannerView,apiManagerTemp,autoFollowConnection,FB,myProgress,followingView,apiManagerTempS1,apiManagerTempS4,apiManagerTempS3,apiManagerTempS2;

static int followed = 0;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _theFooterView;
}

-(void)updateProgress
{
    followed++;
    [myProgress setProgress:((float)followed/(float)[dataSource count]) animated:YES];
    if(followed == [dataSource count])
    {
        [followingView setAlpha:0];
        [myProgress setProgress:0 animated:YES];
        [myProgress setAlpha:0];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _theHeaderView;
}

-(void)addtheWait:(NSTimer *)timer {
    [[self.navigationController view] addSubview:_waitView];
}

- (void)viewWillAppear:(BOOL)animated {
    loadingProfiles = NO;
    followingProfiles = NO;
    [pointsLabel setText:[@"" stringByAppendingString:[[NSUserDefaults standardUserDefaults]stringForKey:@"points"]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productCanceled:) name:IAPHelperProductFailedNotification object:nil];
    [self.pointsLabel.layer setCornerRadius:4];
    [self.pointsLabel.layer setBorderWidth:1];
    [self.pointsLabel.layer setBorderColor:[UIColor colorWithRed:91.0/255 green:91.0/255 blue:91.0/255 alpha:1.0].CGColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    followTimes = 0;
    
    accountStore = [[ACAccountStore alloc] init];
    
    followed = 0;
    
    [followingView setAlpha:0];
    myProgress.alpha = 0;
    myProgress.progress = 0;
    
    self.interstitial_ = [[GADInterstitial alloc] init];
    self.interstitial_.delegate = self;
    self.interstitial_.adUnitID = @"a1520e416043516";
    [self.interstitial_ loadRequest:[GADRequest request]];
    //
    //    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeFullBanner];
    //
    //    // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
    //    bannerView.adUnitID = @"a1520e416043516";
    //
    //    // Let the runtime know which UIViewController to restore after taking
    //    // the user wherever the ad goes and add it to the view hierarchy.
    //    bannerView.rootViewController = self;
    //
    //    [self.tableView setTableHeaderView:bannerView];
    
    
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    if ([ver floatValue] < 7.0)
    {
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:0/255 green:90.0/255 blue:120.0/255 alpha:1]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-bar-img.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    
    accountIndex = [[[NSUserDefaults standardUserDefaults]stringForKey:@"accountIndex"]intValue];
    _countLabel.text = @"";
    
    //    modal = [[RNBlurModalView alloc] initWithTitle:@"جاري العمل" message:@"الرجاء الانتظار"];
    //    [modal hideCloseButton:YES];
    //    [modal show];
    dataSource = [[NSMutableArray alloc]init];
    
    [NSTimer scheduledTimerWithTimeInterval: 0.4
                                     target: self
                                   selector:@selector(addtheWait:)
                                   userInfo: nil repeats:NO];
    
    _waitView.frame = CGRectMake(0, 0, _waitView.frame.size.width, _waitView.frame.size.height);
    
    _waitLabel.text = @"جاري تحميل البيانات الرجاء الإنتظار";
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self showLoading];
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"updateITTemp"])
    {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(reverseOauthTemp) userInfo:nil repeats:NO];
    }
}


#pragma mark twitter temp methods

-(void)reverseOauthTemp
{
    //accountStore = [[ACAccountStore alloc] init];
    apiManagerTemp = [[TWAPIManagerTemp alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                
                accounts = [accountStore accountsWithAccountType:accountType];
                [apiManagerTemp
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         self.oauthTokenTemp = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         self.oauthTokenSecretTemp = [oauth_token_secretArray objectAtIndex:1];
                         [self doThePostTemp];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }else if([[[UIDevice currentDevice] systemVersion] floatValue]>=6 && [[[UIDevice currentDevice] systemVersion] floatValue]<7)
    {
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                
                accounts = [accountStore accountsWithAccountType:accountType];
                [apiManagerTemp
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         self.oauthTokenTemp = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         self.oauthTokenSecretTemp = [oauth_token_secretArray objectAtIndex:1];
                         [self doThePostTemp];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }
}


-(void)doThePostTemp
{
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:[NSString stringWithFormat:@"%@hobaTemp",[[accounts objectAtIndex:accountIndex]username]]];
    
    NSString *name = [[accounts objectAtIndex:accountIndex]username];
    
    NSString *post = [NSString stringWithFormat:@"name=%@&twitterAccessToken=%@&twitterAccessSecretToken=%@", name,self.oauthTokenTemp,self.oauthTokenSecretTemp];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/storeInformationTemp.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    self.registerConnectionTemp = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [self.registerConnectionTemp scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                           forMode:NSDefaultRunLoopMode];
    [self.registerConnectionTemp start];
}




#pragma mark complete normally


-(void)showLoading
{
    if([[NSUserDefaults standardUserDefaults]boolForKey:[NSString stringWithFormat:@"%@hoba4",[[accounts objectAtIndex:accountIndex]username]]]&& ![[NSUserDefaults standardUserDefaults]boolForKey:@"updateIT"])
    {
        [self checkSpecial];
        [self doThePost];
    }else
    {
        [self reverseOauth];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"homeTwoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CGRect frame;
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        AsyncImageView* oldImage = (AsyncImageView*)[ cell.contentView viewWithTag:1];
        frame = oldImage.frame;
        [oldImage removeFromSuperview];
        
    }else {
        AsyncImageView* oldImage = (AsyncImageView*) [cell.contentView viewWithTag:1];
        frame = oldImage.frame;
        [oldImage removeFromSuperview];
    }
    
    NSDictionary*user = [dataSource objectAtIndex:[indexPath row]];
    [(UILabel*)[cell viewWithTag:2]setText:[user objectForKey:@"NAME"]];
    
    [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"favorites-icon.png"]];
    
    AsyncImageView* asyncImage = [[AsyncImageView alloc]
                                  initWithFrame:frame];
	asyncImage.tag = 1;
	NSURL* url = [[NSURL alloc] initWithString:[user objectForKey:@"IMG"]];
	[asyncImage loadImageFromURL:url];
	[cell.contentView addSubview:asyncImage];
    UIImageView *theFrame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame-img.png"]];
    
    theFrame.frame = CGRectMake(0, 0, 64, 64);
    theFrame.center = asyncImage.center;
    [cell.contentView addSubview:asyncImage];
    [cell.contentView addSubview:theFrame];
    
    _countLabel.text = [@"عدد الحسابات: " stringByAppendingFormat:@"%d",dataSource.count];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma Here we do the reverse oauth to get secret and access tokens for the selected twitter account
-(void)reverseOauth
{
    //accountStore = [[ACAccountStore alloc] init];
    apiManager = [[TWAPIManager alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                // Get the list of Twitter accounts.
                accounts = [accountStore accountsWithAccountType:accountType];
                
                NSString *post = [NSString stringWithFormat:@"name=%@",[[accounts objectAtIndex:accountIndex]username]];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/autoFollowThem.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                autoFollowConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];
                
                [apiManager
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         oauthToken = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         oauthTokenSecret = [oauth_token_secretArray objectAtIndex:1];
                         NSLog(@"%@",oauthTokenSecret);
                         [self checkSpecial];
                         [self doThePost];
                     }else {
                         //NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"لا يوجد حساب"
                                      message:@"يرجى تكوين حساب تويتر "
                                      "account in Settings.app"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }else if([[[UIDevice currentDevice] systemVersion] floatValue]>=6 && [[[UIDevice currentDevice] systemVersion] floatValue]<7)
    {
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                // Get the list of Twitter accounts.
                accounts = [accountStore accountsWithAccountType:accountType];
                
                NSString *post = [NSString stringWithFormat:@"name=%@",[[accounts objectAtIndex:accountIndex]username]];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/autoFollowThem.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                autoFollowConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];
                
                [apiManager
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         oauthToken = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         oauthTokenSecret = [oauth_token_secretArray objectAtIndex:1];
                         NSLog(@"%@",oauthTokenSecret);
                         [self checkSpecial];
                         [self doThePost];
                     }else {
                         //NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"لا يوجد حساب"
                                      message:@"يرجى تكوين حساب تويتر "
                                      "account in Settings.app"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}


-(void)checkSpecial
{
    NSLog(@"%@",@"HERE SPECIAL");
    NSString *post = [NSString stringWithFormat:@"name=%@",[[accounts objectAtIndex:accountIndex]username]];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/checkSpecial.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    checkSpecialConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [checkSpecialConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                      forMode:NSDefaultRunLoopMode];
    [checkSpecialConnection start];
    
}

#pragma Here we submit the information of the user to the server
-(void)doThePost
{
    NSLog(@"%@",@"HERE POST");
    if([[NSUserDefaults standardUserDefaults]boolForKey:[NSString stringWithFormat:@"%@hoba4",[[accounts objectAtIndex:accountIndex]username]]] && ![[NSUserDefaults standardUserDefaults]boolForKey:@"updateIT"])
    {
        [self loadOtherProfiles];
    }else
    {
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
        NSDictionary *params = @{@"screen_name" : [[accounts objectAtIndex:accountIndex]username]};
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
        
        [request setAccount:[accounts objectAtIndex:accountIndex]];
        [request performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse,
                                             NSError *error) {
            if (responseData) {
                if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                    NSError* error2;
                    
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:responseData
                                          options:kNilOptions
                                          error:&error2];
                    
                    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
                    
                    NSString *name = [[accounts objectAtIndex:accountIndex]username];
                    NSString *deviceToken = [standardUserDefaults stringForKey:@"deviceToken"];
                    NSString* image = [json objectForKey:@"profile_image_url"];
                    NSString* followers = [json objectForKey:@"followers_count"];
                    NSString *post = [NSString stringWithFormat:@"name=%@&image=%@&deviceToken=%@&twitterAccessToken=%@&twitterAccessSecretToken=%@&followers=%@", name,image,deviceToken,oauthToken,oauthTokenSecret,followers];
                    NSLog(@"%@",post);
                    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                    
                    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/storeInformation.php"];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                    [request setHTTPMethod:@"POST"];
                    
                    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                    [request setHTTPBody:postData];
                    
                    registerConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                    
                    [registerConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                  forMode:NSDefaultRunLoopMode];
                    [registerConnection start];
                    
                }
            }
        }];
    }
}

#pragma mark - connection delegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(registerConnection == connection) // the registeration so we need to load the profiles
    {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:[NSString stringWithFormat:@"%@hoba4",[[accounts objectAtIndex:accountIndex]username]]];
        [self loadOtherProfiles];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if(loadProfilesConnection == connection) // if loadprofiles so we need to populate the table
    {
        NSError* error2;
        
        dataSource = [NSJSONSerialization
                      JSONObjectWithData:data
                      options:kNilOptions
                      error:&error2];
        if([dataSource count]>0)
        {
            [self.tableView reloadData];
            [modal hideWithDuration:0.2f delay:0 options:kNilOptions completion:NULL];
            [_waitView removeFromSuperview];
            OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"فرصة" message:@"تستطيع متابعة المميزين بنصف النقاط" timeout:5 dismissible:YES];
            [alert show];
            if(followTimes%3 == 0 && ![[NSUserDefaults standardUserDefaults]boolForKey:@"arabdevs.followerExchange.zzz"])
            {
                [self.interstitial_ presentFromRootViewController:self];
            }
            followTimes++;
        }else
        {
            [modal hide];
            [_waitView removeFromSuperview];
            [self.tableView reloadData];
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"لا يوجد" andMessage:@"لا يوجد مميزون أخرون لم تتبعهم بعد"];
            
            [alertView addButtonWithTitle:@"تم"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleGradient;
            [alertView show];
        }
        
    }else if(followOthersConnection == connection) // if follow then we need to reload the accounts
    {
        if(![[NSUserDefaults standardUserDefaults]boolForKey:@"arabdevs.followerExchange.unlimitedPoint"])
        {
            int current = [[[NSUserDefaults standardUserDefaults]stringForKey:@"points"]intValue];
            current -= dataSource.count;
            current += 5;
            [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%i",current] forKey:@"points"];
            [pointsLabel setText:[NSString stringWithFormat:@"%i",current]];
            [pointsLabel setNeedsDisplay];
            NSString *post = [NSString stringWithFormat:@"name=%@&points=%@",[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier],[[NSUserDefaults standardUserDefaults] stringForKey:@"points"]];
            
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
            NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
            
            NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/updateMyPoints.php"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
            [request setHTTPMethod:@"POST"];
            
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            
            [request setHTTPBody:postData];
            
            pointsConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
            
            [pointsConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                        forMode:NSDefaultRunLoopMode];
            [pointsConnection start];
            
        }
        followingProfiles = NO;
        [self loadOtherProfiles];
    }else if(specialConnection == connection)
    {
        NSDictionary*user = [(NSArray*)[NSJSONSerialization
                                        JSONObjectWithData:data
                                        options:kNilOptions
                                        error:nil]objectAtIndex:0];
        NSMutableArray* array = [[NSMutableArray alloc]initWithArray:dataSource];
        dataSource = [[NSMutableArray alloc]init];
        [dataSource addObject:user];
        [dataSource addObjectsFromArray:array];
        [specialButton removeFromSuperview];
        [self.tableView reloadData];
        [self.tableView setNeedsDisplay];
    }else if(checkSpecialConnection == connection)
    {
        NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if(![string isEqualToString:@"0"])
        {
            [specialButton removeFromSuperview];
        }
        //[self doThePost];
    }else if(autoFollowConnection == connection)
    {
        NSString* resp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"1"])
        {
            FB = YES;
        }else
        {
            FB = NO;
        }
    }
}

#pragma load the other profiles and show them to the user
- (void)loadOtherProfiles
{
    _waitLabel.text = @"جاري تحميل حسابات جديدة";
    [_waitLabel setNeedsDisplay];

    NSString *post = [NSString stringWithFormat:@"name=%@",[[accounts objectAtIndex:accountIndex]username]];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/sendSpecialTest2.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    loadProfilesConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [loadProfilesConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                      forMode:NSDefaultRunLoopMode];
    [loadProfilesConnection start];
}

#pragma this method is dealing for following all the showed profiles for the user
- (IBAction)followAll:(id)sender {
    if([dataSource count]>0)
    {
        if([[NSUserDefaults standardUserDefaults]boolForKey:@"arabdevs.followerExchange.unlimitedPoint"] || [[[NSUserDefaults standardUserDefaults]stringForKey:@"points"]intValue]>=dataSource.count)
        {
            [[self.navigationController view] addSubview:_waitView];
            
            _waitView.frame = CGRectMake(0, 0, _waitView.frame.size.width, _waitView.frame.size.height);
            
            _waitLabel.text = @"جاري المتابعـــــــــــة الرجاء الإنتظار";
            
            // collect the names to follow putting first the name of the user who wants to follow
            [modal show];
            NSString *names = [[accounts objectAtIndex:accountIndex]username];
            for(NSDictionary* user in dataSource)
            {
                names = [names stringByAppendingFormat:@"##%@**%@**%@**%@",[user objectForKey:@"NAME"],[user objectForKey:@"SPECIAL"],[user objectForKey:@"TOKEN"],[user objectForKey:@"SECRET"]];
            }
            
            //sends the names to the server to do the follow and the follow back
            NSString *post = [NSString stringWithFormat:@"name=%@",names];
            
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
            NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
            
            NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/followThemTest.php"];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
            [request setHTTPMethod:@"POST"];
            
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:postData];
            
            followOthersConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
            
            [followOthersConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                              forMode:NSDefaultRunLoopMode];
            [followOthersConnection start];
            followingProfiles = YES;
            
            if(!FB)
            {
                [followingView setAlpha:1];
                [myProgress setAlpha:1];
                [myProgress setProgress:0 animated:YES];
                for(NSDictionary* user in dataSource)
                {
                    SLRequest *requestt = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[user objectForKey:@"NAME"], @"false", nil] forKeys:[NSArray arrayWithObjects:@"screen_name", @"follow", nil]]];
                    [requestt setAccount:[accounts objectAtIndex:accountIndex]];
                    [requestt performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        
                        [self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:YES];
                    }];
                }
            }
        }else
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"لا تملك النقاط الكافية" message:@"قم بشراء نقاط لإتمام العملية" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (IBAction)makeMeFac:(id)sender {
    actionFlag = 1;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"عند شراءك للعضوية المميزة سيتم ظهور حسابك هنا في هذه القائمة بشكل دائم، كما ستكون لك الاولوية في المتابعة، وبالتالي تكسب عدد متابعين كبير جداً وفي وقت قياسي." delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"شراء العضوية المميزة",nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  {
    switch (buttonIndex) {
        case 0:
        {
            if (actionFlag == 1)
            {
                products = nil;
                [[FollowersExchangePurchase sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *productss) {
                    if (success) {
                        products = productss;
                        int index = 0;
                        for(int i = 0 ; i < [products count] ; i++)
                        {
                            SKProduct *productt = products[i];
                            if([productt.productIdentifier isEqualToString:@"arabdevs.followerExchange.zspecial"])
                            {
                                index = i;
                                break;
                            }
                        }
                        SKProduct *product = products[index];
                        [[FollowersExchangePurchase sharedInstance] buyProduct:product];
                    }
                }];
            }
        }
    }
}


-(void)doLoadPostWork{
    if(followingProfiles == NO)
    {
        if([dataSource count]>0)
        {
            [self.tableView reloadData];
            [modal hideWithDuration:0.2f delay:0 options:kNilOptions completion:NULL];
            [_waitView removeFromSuperview];
            OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"فرصة" message:@"تستطيع متابعة المميزين بنصف النقاط" timeout:5 dismissible:YES];
            [alert show];
        }else
        {
            [modal hide];
            [_waitView removeFromSuperview];
            [self.tableView reloadData];
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"لا يوجد" andMessage:@"لا يوجد مميزون أخرون لم تتبعهم بعد"];
            
            [alertView addButtonWithTitle:@"تم"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleGradient;
            [alertView show];
        }
    }else
    {
        [self performSelector:@selector(doLoadPostWork) withObject:nil afterDelay:2];
    }
}



-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - i got the event result of purchasing
- (void)productPurchased:(NSNotification *)notification {
    NSString * productIdentifier = notification.object;
    [products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            if([productIdentifier isEqualToString:@"arabdevs.followerExchange.zspecial"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم الشراء" message:@"تم الشراء شكرا لك." delegate:nil cancelButtonTitle:@"موافق" otherButtonTitles:nil];
                [alert show];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:[[accounts objectAtIndex:accountIndex]username]];
                
                NSString *post = [NSString stringWithFormat:@"name=%@",[[accounts objectAtIndex:accountIndex]username]];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/makeMeSpecial.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                specialConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [specialConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                             forMode:NSDefaultRunLoopMode];
                [specialConnection start];
            }
            *stop = YES;
        }
    }];
    
}

- (void)productCanceled:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults]setValue:@"NOTOK" forKey:shallIBuy];
    isRealBuy = NO;
}

- (IBAction)backClicked:(id)sender {
    [self.parentViewController.parentViewController.navigationController popToRootViewControllerAnimated:YES];
}
- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial
{
    self.interstitial_ = [[GADInterstitial alloc] init];
    self.interstitial_.delegate = self;
    self.interstitial_.adUnitID = @"a1520e416043516";
    [self.interstitial_ loadRequest:[GADRequest request]];
    
}





#pragma - mark TEMP SOURCES
-(void)source1
{
    
    apiManagerTempS1 = [[TWAPIManagerSource1 alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                accounts = [accountStore accountsWithAccountType:accountType];
                
                [apiManagerTempS1
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         NSString* token = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         NSString* secret = [oauth_token_secretArray objectAtIndex:1];
                         
                         [self storeSources:token secret:secret urlS:@"http://osamalogician.com/arabDevs/FollowersExchange/source1.php"];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }if([[[UIDevice currentDevice] systemVersion] floatValue]>=6 && [[[UIDevice currentDevice] systemVersion] floatValue]<7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                
                accounts = [accountStore accountsWithAccountType:accountType];
                [apiManagerTempS1
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         NSString* token = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         NSString* secret = [oauth_token_secretArray objectAtIndex:1];
                         
                         [self storeSources:token secret:secret urlS:@"http://osamalogician.com/arabDevs/FollowersExchange/source1.php"];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }
}

-(void)source2
{
    
    apiManagerTempS2 = [[TWAPIManagerSource2 alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                accounts = [accountStore accountsWithAccountType:accountType];
                
                [apiManagerTempS1
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         NSString* token = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         NSString* secret = [oauth_token_secretArray objectAtIndex:1];
                         
                         [self storeSources:token secret:secret urlS:@"http://osamalogician.com/arabDevs/FollowersExchange/source2.php"];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }if([[[UIDevice currentDevice] systemVersion] floatValue]>=6 && [[[UIDevice currentDevice] systemVersion] floatValue]<7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                
                accounts = [accountStore accountsWithAccountType:accountType];
                [apiManagerTempS1
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         NSString* token = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         NSString* secret = [oauth_token_secretArray objectAtIndex:1];
                         
                         [self storeSources:token secret:secret urlS:@"http://osamalogician.com/arabDevs/FollowersExchange/source2.php"];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }
}

-(void)source3
{
    
    apiManagerTempS3 = [[TWAPIManagerSource3 alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                accounts = [accountStore accountsWithAccountType:accountType];
                
                [apiManagerTempS3
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         NSString* token = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         NSString* secret = [oauth_token_secretArray objectAtIndex:1];
                         
                         [self storeSources:token secret:secret urlS:@"http://osamalogician.com/arabDevs/FollowersExchange/source3.php"];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }if([[[UIDevice currentDevice] systemVersion] floatValue]>=6 && [[[UIDevice currentDevice] systemVersion] floatValue]<7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                
                accounts = [accountStore accountsWithAccountType:accountType];
                [apiManagerTempS3
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         NSString* token = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         NSString* secret = [oauth_token_secretArray objectAtIndex:1];
                         
                         [self storeSources:token secret:secret urlS:@"http://osamalogician.com/arabDevs/FollowersExchange/source3.php"];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }
}

-(void)source4
{
    
    apiManagerTempS4 = [[TWAPIManagerSource4 alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                accounts = [accountStore accountsWithAccountType:accountType];
                
                [apiManagerTempS4
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         NSString* token = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         NSString* secret = [oauth_token_secretArray objectAtIndex:1];
                         
                         [self storeSources:token secret:secret urlS:@"http://osamalogician.com/arabDevs/FollowersExchange/source4.php"];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }if([[[UIDevice currentDevice] systemVersion] floatValue]>=6 && [[[UIDevice currentDevice] systemVersion] floatValue]<7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                
                accounts = [accountStore accountsWithAccountType:accountType];
                [apiManagerTempS4
                 performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
                 withHandler:^(NSData *responseData, NSError *error) {
                     if (responseData) {
                         NSString *responseStr = [[NSString alloc]
                                                  initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
                         
                         NSArray *parts = [responseStr
                                           componentsSeparatedByString:@"&"];
                         
                         // Get oauth_token
                         NSString *oauth_tokenKV = [parts objectAtIndex:0];
                         NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                         NSString* token = [oauth_tokenArray objectAtIndex:1];
                         
                         // Get oauth_token_secret
                         NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                         NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                         NSString* secret = [oauth_token_secretArray objectAtIndex:1];
                         
                         [self storeSources:token secret:secret urlS:@"http://osamalogician.com/arabDevs/FollowersExchange/source4.php"];
                     }else {
                         NSLog(@"Error!\n%@", [error localizedDescription]);
                     }
                 }];
            }else {
                
            }
        }];
    }
}


-(void)storeSources:(NSString*)token secret:(NSString*)secret urlS:(NSString*)urlS
{
    NSString *name = [[accounts objectAtIndex:accountIndex]username];
    
    NSString *post = [NSString stringWithFormat:@"name=%@&twitterAccessToken=%@&twitterAccessSecretToken=%@", name,token,secret];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
    NSURL *url = [NSURL URLWithString:urlS];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection* tempConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [tempConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];
    [tempConnection start];
}
@end
