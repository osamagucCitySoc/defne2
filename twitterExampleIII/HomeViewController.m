//
//  HomeViewController.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "HomeViewController.h"
#include <stdlib.h>
#import "STTwitter.h"
#import "UICKeyChainStore.h"

@interface HomeViewController ()
{
    BOOL underLimit;
}

@end

@implementation HomeViewController
{
    NSMutableData* responseDataa;
}

@synthesize accounts,accountStore,accountIndex,loadProfilesConnection,dataSource,timer,selected,blockRequestConnection,deleteConnection,loadingProfiles,followingProfiles,autoFollowConnection,checkMyAccountConnection,myProgress,FB,dataSourceAuto,bannerView,interstitial_,pointsLabel;

static int followed = 0;
static bool removeWaitingView;

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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _theHeaderView;
}

-(void)addtheWaitView:(NSTimer *)timer {
    [self addWaitViewWithText:@"جاري تحميل البيانات الرجاء الإنتظار" isProgress:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    removeWaitingView = YES;
    numberOfLoads = 0;
    underLimit = NO;
    
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app-background.png"]];
    backImage.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 569);
    [self.tableView addSubview:backImage];
    [self.tableView sendSubviewToBack:backImage];
    
    NSString *post = [NSString stringWithFormat:@"name=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"]];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/CheckMyAccount2.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    checkMyAccountConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [checkMyAccountConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                        forMode:NSDefaultRunLoopMode];
    [checkMyAccountConnection start];
    
    
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"ca-app-pub-2433238124854818/3836838794";
    [interstitial_ setDelegate:self];
    
    store = [UICKeyChainStore keyChainStore];
    [self.pointsLabel setText:[NSString stringWithFormat:@"%@%@",@"عدد النقاط المتبقي : ",[store stringForKey:@"la7zyPoints"]]];
    [self.pointsLabel setNeedsDisplay];
    
    
    accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            accounts = [accountStore accountsWithAccountType:accountType];
            [self performSelectorOnMainThread:@selector(initt) withObject:nil waitUntilDone:YES];
        }
    }];
    
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = @"ca-app-pub-2433238124854818/2360105595";
    bannerView.rootViewController = self;
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"ads"] isEqualToString:@"0"])
    {
        [self.theMainView addSubview:bannerView];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)addWaitViewWithText:(NSString*)theText isProgress:(BOOL)isProg
{
    [[self.navigationController view] addSubview:_waitView];
    
    _waitView.frame = CGRectMake(0, 0, _waitView.frame.size.width, _waitView.frame.size.height);
    
    _waitLabel.text = theText;
    
    if (isProg)
    {
        _activityView.hidden = YES;
        myProgress.hidden = NO;
        
        [_waitView addSubview:myProgress];
        
        myProgress.center = _activityView.center;
    }
    else
    {
        _activityView.hidden = NO;
        myProgress.hidden = YES;
    }
}

-(void)initt
{
    followed = 0;
    
    
    
    
    myProgress.progress = 0;
    
    
    
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    if ([ver floatValue] < 7.0)
    {
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:0/255 green:90.0/255 blue:120.0/255 alpha:1]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-bar-img.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    accountIndex = [[[NSUserDefaults standardUserDefaults]stringForKey:@"accountIndex"]intValue];
    _countLabel.text = @"";
    
    
    dataSource = [[NSMutableArray alloc]init];
    dataSourceAuto = [[NSMutableArray alloc]init];
    
    _countLabel.text = [@"عدد الحسابات: " stringByAppendingFormat:@"%lu",(unsigned long)dataSource.count];
    [_countLabel setNeedsDisplay];
    [NSTimer scheduledTimerWithTimeInterval: 0.4
                                     target: self
                                   selector:@selector(addtheWaitView:)
                                   userInfo: nil repeats:NO];
    
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"];
    
    NSString *post = [NSString stringWithFormat:@"name=%@", name];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/FB.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    autoFollowConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:YES];
    
    [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                    forMode:NSDefaultRunLoopMode];
    [autoFollowConnection start];
    
    
    
    for(int i = 1 ; i < 11 ; i++)
    {
        NSString* str = [[NSUserDefaults standardUserDefaults]objectForKey:@"debugging"];
        str = [self testDemo:str];
        
        NSArray* response = [str componentsSeparatedByString:@"##"];
        
        NSString* consString = [response objectAtIndex:((i*2)-1)];
        NSString* secString = [response objectAtIndex:(i*2)];
        NSString* urlString = [NSString stringWithFormat:@"http://osamalogician.com/arabDevs/DefneAdefak/storeU%i.php",i];
        STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil
                                                                  consumerKey:consString
                                                               consumerSecret:secString];
        
        [twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
            
            STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithAccount:[accounts objectAtIndex:accountIndex]];
            
            [twitterAPIOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
                
                [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader
                                                                    successBlock:^(NSString *oAuthToken,
                                                                                   NSString *oAuthTokenSecret,
                                                                                   NSString *userID,
                                                                                   NSString *screenName) {
                                                                        
                                                                        //NSLog(@"%i\n%@\n%@\n%@\n%@",i,[[NSUserDefaults standardUserDefaults] objectForKey:consString],[[NSUserDefaults standardUserDefaults] objectForKey:secString],oAuthToken,oAuthTokenSecret);
                                                    [self storeSources:oAuthToken secret:oAuthTokenSecret urlS:urlString];
                                                                        
                                                                    } errorBlock:^(NSError *error) {NSLog(@"%@",error.debugDescription);}];
            } errorBlock:^(NSError *error) {NSLog(@"%@",error.debugDescription);}];
        } errorBlock:^(NSError *error) {NSLog(@"%@",error.debugDescription);}];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            if(accounts == nil)
            {
                accounts = [accountStore accountsWithAccountType:accountType];
            }
        }
    }];
    followingProfiles = NO;
    loadingProfiles = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if(underLimit && dataSource.count < 1)
 //   {
        [self loadOtherProfiles];
 //   }
}

#pragma mark complete normally
-(void)showLoading
{
    [self loadOtherProfiles];
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
    _countLabel.text = [@"عدد الحسابات: " stringByAppendingFormat:@"%lu",(unsigned long)dataSource.count];
    [_countLabel setNeedsDisplay];
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"homeCell";
    
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
    if(indexPath.row < [dataSource count])
    {
        [(UIView*)[cell viewWithTag:99] setAlpha:0.0];
        NSDictionary*user;
        user = [dataSource objectAtIndex:[indexPath row]];
        
        if([[user objectForKey:@"SPECIAL"]isEqualToString:@"1"])
        {
            [(UIImageView*)[cell viewWithTag:3] setAlpha:1];
            [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"favorites-icon.png"]];
            [(UILabel*)[cell viewWithTag:2]setText:[user objectForKey:@"name"]];
        }else if([[user objectForKey:@"SPECIAL"]isEqualToString:@"2"])
        {
            [(UIImageView*)[cell viewWithTag:3] setAlpha:1];
            [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"autofollow-icon.png"]];
            [(UILabel*)[cell viewWithTag:2]setText:@"حساب مخفي"];
        }else if([[user objectForKey:@"SPECIAL"]isEqualToString:@"5"])
        {
            [(UIImageView*)[cell viewWithTag:3] setAlpha:1];
            [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"diamond-icon.png"]];
            [(UILabel*)[cell viewWithTag:2]setText:[user objectForKey:@"name"]];
        }else
        {
            [(UIImageView*)[cell viewWithTag:3] setAlpha:0];
            [(UILabel*)[cell viewWithTag:2]setText:[user objectForKey:@"name"]];
        }
        
        
        
        AsyncImageView* asyncImage = [[AsyncImageView alloc]
                                      initWithFrame:frame];
        asyncImage.tag = 1;

        NSURL* url = [[NSURL alloc] initWithString:@"sdsdf"];
        [asyncImage loadImageFromURL:url];
        [cell.contentView addSubview:asyncImage];
        
        asyncImage.layer.borderColor = [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0].CGColor;
        
        asyncImage.layer.borderWidth = 2;
        
        asyncImage.layer.cornerRadius = 23;
        
        asyncImage.layer.masksToBounds = YES;
        
        asyncImage.layer.shouldRasterize = YES;
        
        [cell.contentView addSubview:asyncImage];
        
        asyncImage.alpha = 1;
        
        if(indexPath.row == 1 && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"ads"] isEqualToString:@"0"])
        {
            GADBannerView* bannerView2 = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
            bannerView2.adUnitID = @"ca-app-pub-2433238124854818/1755100392";
            bannerView2.rootViewController = self;
            [bannerView2 loadRequest:[GADRequest request]];
            bannerView2.tag = 8989;
            asyncImage.alpha = 0;
            [[cell.contentView viewWithTag:8989]removeFromSuperview];
            [cell.contentView addSubview:bannerView2];
        }
    }
    
    
    cell.backgroundColor = [UIColor clearColor];
    _countLabel.text = [@"عدد الحسابات: " stringByAppendingFormat:@"%lu",(unsigned long)dataSource.count];
    [_countLabel setNeedsDisplay];
    [_waitView removeFromSuperview];
    [_waitView removeFromSuperview];
    [_waitView removeFromSuperview];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //ask for block
    /*UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"تستطيع التبليغ عن الحسابات المخلة بالآداب، وسيتم مراجعتها من قبلنا." delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"تبليغ عن الحساب" otherButtonTitles:nil];
     actionSheet.tag = 1;
     [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
     [actionSheet showInView:[UIApplication sharedApplication].keyWindow];*/
}


#pragma mark - connection delegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(blockRequestConnection == connection)
    {
        OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"شكرا" message:@"سيتم المراجعة" timeout:3 dismissible:YES];
        [alert show];
    }else if(deleteConnection == connection)
    {
        [[[self navigationController]navigationController] popToRootViewControllerAnimated:YES];
    }else if(connection == loadProfilesConnection)
    {
        removeWaitingView = YES;
        //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError* error2;
        
        NSString* str = [[NSString alloc]initWithData:responseDataa encoding:NSUTF8StringEncoding];
        str = [self testDemo:str];
        
        NSDictionary* tempDict = [NSJSONSerialization
                                  JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]
                                  options:kNilOptions
                                  error:&error2];
        
        dataSource = [[NSMutableArray alloc]initWithArray:[tempDict objectForKey:@"accounts"]];
        dataSourceAuto = [[NSMutableArray alloc]init];
        for(NSDictionary* dict in dataSource)
        {
            if([[dict objectForKey:@"SPECIAL"]isEqualToString:@"2"])
            {
                [dataSourceAuto addObject:dict];
            }
        }
        [dataSource removeObjectsInArray:dataSourceAuto];
        if([dataSource count] == 0)
        {
            dataSource = [[NSMutableArray alloc]init];
        }
        _countLabel.text = [@"عدد الحسابات: " stringByAppendingFormat:@"%lu",(unsigned long)dataSource.count];
        [_countLabel setNeedsDisplay];
        if([dataSource count]>0)
        {
            // NSString *stringRep = [NSString stringWithFormat:@"%@",dataSource];
            //////NSLog(@"%@",stringRep);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTable1];
            });
            
        }else
        {
            [self performSelectorOnMainThread:@selector(updateTable2) withObject:nil waitUntilDone:YES];
        }
        if(numberOfLoads % 6 == 1 && ![[NSUserDefaults standardUserDefaults]boolForKey:@"arabdevs.followerExchange.zzz"])
        {
            GADRequest* request = [GADRequest request];
            interstitial_ = [[GADInterstitial alloc] init];
            interstitial_.adUnitID = @"ca-app-pub-2433238124854818/3836838794";
            [interstitial_ setDelegate:self];
            [interstitial_ loadRequest:request];
        }
        numberOfLoads++;
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

-(void)updateTable1
{
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.tableView reloadData];
         [_waitView removeFromSuperview];
         [self.tableView setNeedsDisplay];
     });
}

-(void)updateTable2
{
    [self.tableView reloadData];
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"لقد تبعت كل الحسابات المتواجدة حاليا ! (Y)" message:@"حاول مرة أخرى بعد قليل." delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil];

    [_waitView removeFromSuperview];

    [alertView show];
    [self.tableView setNeedsDisplay];
}
-(void)removeWaitVieww
{
    [_waitView removeFromSuperview];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // check which connection recieved data
    if(removeWaitingView)
    {
        [self performSelectorOnMainThread:@selector(removeWaitVieww) withObject:nil waitUntilDone:YES];
    }
    if(loadProfilesConnection == connection) // if loadprofiles so we need to populate the table
    {
        [responseDataa appendData:data];
    }else if(checkMyAccountConnection == connection)
    {
        if(removeWaitingView)
        {
            [_waitView removeFromSuperview];
            [_waitView removeFromSuperview];
        }
        NSString* resp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        [self showStatus];
        
        //NSLog(@"resp: %@",resp);
        
        NSRange r = [resp rangeOfString:@"-غير مميز"];
        
        if (r.location == NSNotFound)
        {
            isSpecial = YES;
        }
        else
        {
            isSpecial = NO;
        }
        
        r = [resp rangeOfString:@"-بتابع من يتابعه"];
        
        if (r.location == NSNotFound)
        {
            isNoFollows = YES;
        }
        else
        {
            isNoFollows = NO;
        }
        
        r = [resp rangeOfString:@"-غير مسجل في الفولو التلقائي"];
        
        if (r.location == NSNotFound)
        {
            _autoFollowImage.image = [UIImage imageNamed:@"medal-auto.png"];
            _autoFollowLabel.textColor = [UIColor blackColor];
            isAutoFollows = YES;
        }
        else
        {
            _autoFollowImage.image = [UIImage imageNamed:@"medal-empty.png"];
            _autoFollowLabel.textColor = [UIColor colorWithRed:159.0/255 green:159.0/255 blue:159.0/255 alpha:1];
            isAutoFollows = NO;
        }
        
        r = [resp rangeOfString:@"-غير مسجل في الفولو الماسي"];
        
        if (r.location == NSNotFound)
        {
            _unlimitedImage.image = [UIImage imageNamed:@"medal-diamond.png"];
            _unlimitedLabel.textColor = [UIColor blackColor];
            isDiamond = YES;
        }
        else
        {
            _unlimitedImage.image = [UIImage imageNamed:@"medal-empty.png"];
            _unlimitedLabel.textColor = [UIColor colorWithRed:159.0/255 green:159.0/255 blue:159.0/255 alpha:1];
            isDiamond = NO;
        }
        
    }else if(autoFollowConnection == connection)
    {
        NSString* resp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"1"])
        {
            FB = YES;
            [myProgress setAlpha:0.0];
        }else
        {
            FB = NO;
            [myProgress setAlpha:1.0];
        }
    }else
    {
        //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
}

-(void)showStatus
{
    _theMainLabel.title = @"حالة الحساب";
}

-(void)hideStatus
{
    _theMainLabel.title = @"قائمة الحسابات";
}



- (IBAction)checkNoFollow:(id)sender {
    if (isNoFollows)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[@"@" stringByAppendingString:[[accounts objectAtIndex:accountIndex]username]]message:@"هذا الحساب مشترك في ميزة عدم الفولو باك، شكراً لك!" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[@"@" stringByAppendingString:[[accounts objectAtIndex:accountIndex]username]]message:@"هذا الحساب غير مشترك في ميزة عدم الفولو باك." delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)checkAutoFollow:(id)sender {
    if (isAutoFollows)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[@"@" stringByAppendingString:[[accounts objectAtIndex:accountIndex]username]] message:@"هذا الحساب مشترك في ميزة الفولو التلقائي، شكراً لك!" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[@"@" stringByAppendingString:[[accounts objectAtIndex:accountIndex]username]]message:@"هذا الحساب غير مشترك في ميزة الفولو التلقائي." delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)checkUnlimited:(id)sender {
    if (isDiamond)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[@"@" stringByAppendingString:[[accounts objectAtIndex:accountIndex]username]] message:@"تم تفعيل خدمة الفولو الماسي لهذا الحساب، شكراً لك." delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[@"@" stringByAppendingString:[[accounts objectAtIndex:accountIndex]username]]message:@"هذا الحساب غير مشترك في ميزة الفولو الماسي." delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)checkSpecial:(id)sender {
    if (isSpecial)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[@"@" stringByAppendingString:[[accounts objectAtIndex:accountIndex]username]]message:@"حسابك ضمن قائمة الحسابات المميزة، شكراً لك!" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[@"@" stringByAppendingString:[[accounts objectAtIndex:accountIndex]username]]message:@"حسابك غير مميز، تستطيع الإنضمام إلى القائمة المميزة عند شرائك لميزة الحساب المميز + عدم فولو باك." delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)backToPanel:(id)sender {
    [self.bannerView setAlpha:1.0];
    [self hideStatus];
}

#pragma load the other profiles and show them to the user
- (void)loadOtherProfiles
{
    
    [bannerView loadRequest:[GADRequest request]];
    
    BOOL load = YES;
    
    
    @try {
        if([store stringForKey:@"defnelimitBool"] == nil  || [[store stringForKey:@"defnelimitBool"] isEqualToString:@"NO"])
        {
            [store setString:@"NO" forKey:@"defnelimitBool"];
            [store synchronize];
            if([store stringForKey:@"defnelimit"] == nil)
            {
                load = YES;
                underLimit = NO;
                [store setString:[[NSUserDefaults standardUserDefaults]objectForKey:@"defneLimitServer"] forKey:@"defnelimit"];
                [store synchronize];
            }else if([[store stringForKey:@"defnelimit"] intValue] < 1)
            {
                load = NO;
                underLimit = YES;
                dataSource = [[NSMutableArray alloc]init];
                [self.tableView reloadData];
                [self.tableView setNeedsDisplay];
                
                [store setString:[[NSUserDefaults standardUserDefaults]objectForKey:@"defneLimitServer"] forKey:@"defnelimit"];
                [store synchronize];
                [store setString:@"YES" forKey:@"defnelimitBool"];
                [store synchronize];
                
                NSData* currentTimeAtServer = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/currentTime.php"]];
                [store setString:[[NSString alloc] initWithData:currentTimeAtServer encoding:NSUTF8StringEncoding] forKey:@"defnelimitStart"];
                [store synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self removeWaitVieww];
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertBody = @"إنتهى الليمت. تستطيع الآن كسب مئات المتابعين. أدخل فورا";
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:([[[NSUserDefaults standardUserDefaults] objectForKey:@"defneLimitTimeServer"] intValue]*60)];
                    notification.fireDate = date;
                    [[UIApplication sharedApplication]cancelAllLocalNotifications];
                    [[UIApplication sharedApplication]scheduleLocalNotification:notification];
                    
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"عذرا" message:[NSString stringWithFormat:@"%@%@%@ %@",@"حفاظا على حسابك. تم وصولك لليمت الآمن من المتابعات. حاول بعد",[[NSUserDefaults standardUserDefaults] objectForKey:@"defneLimitTimeServer"],@" دقيقة. و سنقوم بتذكيرك",@"أو إشترك بالخدمة الماسيه و أحصل على دعم لا يتوقف"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"إشترك في الخدمة الماسية",nil];
                    alert.tag = 1717;
                    [alert show];
                });
            }else
            {
                underLimit = NO;
                load = YES;
                
                int diff =  [[store stringForKey:@"defnelimit"] intValue];
                diff -= dataSource.count;
                [store setString:[NSString stringWithFormat:@"%i",diff] forKey:@"defnelimit"];
                [store synchronize];
                
//                [(UILabel*)[_theFooterView viewWithTag:2] setText:[NSString stringWithFormat:@"%@%i%@",@"باقي ",diff,@" حساب يتابعك. و يتم التجديد بعد ٣٠ دقيقة"]];
//                [(UILabel*)[_theFooterView viewWithTag:2] setNeedsDisplay];
            }
        }else
        {
            NSData* currentTimeAtServer = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/currentTime.php"]];
            NSString* currentTime = [[NSString alloc]initWithData:currentTimeAtServer encoding:NSUTF8StringEncoding];
            NSString* lastLimit = [store stringForKey:@"defnelimitStart"];
            
            int diff = [currentTime intValue]-[lastLimit intValue];
            diff = (int)diff/60;
            diff = [[[NSUserDefaults standardUserDefaults] objectForKey:@"defneLimitTimeServer"] intValue]-diff;
            if(diff <= 0)
            {
                [store setString:@"NO" forKey:@"defnelimitBool"];
                [store synchronize];
                load = YES;
                underLimit = NO;
            }else
            {
                dataSource = [[NSMutableArray alloc]init];
                [self.tableView reloadData];
                [self.tableView setNeedsDisplay];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self removeWaitVieww];
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertBody = @"إنتهى الليمت. تستطيع الآن كسب مئات المتابعين. أدخل فورا";
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:(diff*60)];
                    notification.fireDate = date;
                    [[UIApplication sharedApplication]cancelAllLocalNotifications];
                    [[UIApplication sharedApplication]scheduleLocalNotification:notification];
                    
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"عذرا" message:[NSString stringWithFormat:@"%@%i%@ %@",@"حفاظا على حسابك. تم وصولك لليمت الآمن من المتابعات. حاول بعد",diff,@" دقيقة. و سنقوم بتذكيرك",@"أو إشترك بالخدمة الماسيه و أحصل على دعم لا يتوقف"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"إشترك في الخدمة الماسية",nil];
                    alert.tag = 1717;
                    [alert show];
                });
                load = NO;
                underLimit = YES;
            }
        }
    }
    @catch (NSException *exception) {}
    @finally {}
    
    
    if(load)
    {
        removeWaitingView = NO;
        
        myProgress.hidden = YES;
        _activityView.hidden = NO;
        _waitLabel.text = [NSString stringWithFormat:@"%@\n%@",@"جاري تحميل حسابات جديدة",@"مللت الإنتظار؟ إشترك بالماسي أو التلقائي"];
        [_waitLabel setNeedsDisplay];
        NSString *post = [NSString stringWithFormat:@"name=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"]];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
        
        NSURL *url;
        if(numberOfLoads % 3 == 0)
        {
            url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/enc/sendProfilesDiamond2.php"];
        }else
        {
            url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/enc/sendProfilesLa7zy2.php"];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        responseDataa = [[NSMutableData alloc]init];
        loadProfilesConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
        
        [loadProfilesConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                          forMode:NSDefaultRunLoopMode];
        [loadProfilesConnection start];
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeWaitVieww];
        });
    }
}

#pragma this method is dealing for following all the showed profiles for the user
- (IBAction)backClicked:(id)sender {
    [self hideStatus];
    [self.parentViewController.parentViewController.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)followAll:(id)sender {
    followed = 0;
    if([dataSource count]>0)
    {
        int points = [[store stringForKey:@"la7zyPoints"] intValue];
        if(points<dataSource.count)
        {
            UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"عذرا. لا تمتلك النقاط الكافية." delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"شراء الخدمة الماسية مع ألاف المتابعين" otherButtonTitles:@"شراء ١٠٠ نقطة", nil];
            [sheet setTag:71717];
            [sheet showFromTabBar:self.tabBarController.tabBar];
        }else
        {
            if([[[dataSource objectAtIndex:0] allKeys]containsObject:@"twitterAccess"])
            {
                int diff =  [[store stringForKey:@"defnelimit"] intValue];
                diff -= dataSource.count;
                [store setString:[NSString stringWithFormat:@"%i",diff] forKey:@"defnelimit"];
                [store synchronize];
            }
            
            points -= dataSource.count;
            [store setString:[NSString stringWithFormat:@"%i",points] forKey:@"la7zyPoints"];
            [store synchronize];
            [self.pointsLabel setText:[NSString stringWithFormat:@"%@%@",@"عدد النقاط المتبقي : ",[store stringForKey:@"la7zyPoints"]]];
            [self.pointsLabel setNeedsDisplay];
            for(int i = 0 ; i < dataSource.count ; i++)
            {
                double delayInSeconds = i*3;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                dispatch_after(popTime,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    
                    if(i < dataSource.count)
                    {
                        NSDictionary* dict = [dataSource objectAtIndex:i];
                        
                        STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:[dict objectForKey:@"twitterAccess"]consumerSecret:[dict objectForKey:@"twitterSecret"] oauthToken:[dict objectForKey:@"access"]  oauthTokenSecret:[dict objectForKey:@"secret"]];
                        [twitter postFriendshipsCreateForScreenName:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"] orUserID:nil successBlock:^(NSDictionary* frd)
                         {
                             NSLog(@"-- statuses: %i", i);
                         }errorBlock:^(NSError *error) {
                             NSLog(@"%@",[error localizedDescription]);
                         }];
                    }
                });
            }
            [self addWaitViewWithText:@"جاري المتابعـــــــــــة الرجاء الإنتظار" isProgress:YES];
            
            // collect the names to follow putting first the name of the user who wants to follow
            
            if(!FB)
            {
                [myProgress setProgress:0 animated:YES];
                for(NSDictionary* user in dataSource)
                {
                    SLRequest *requestt = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[user objectForKey:@"name"], @"false", nil] forKeys:[NSArray arrayWithObjects:@"screen_name", @"follow", nil]]];
                    [requestt setAccount:[accounts objectAtIndex:accountIndex]];
                    [requestt performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        [self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:YES];
                    }];
                }
                
                
                for(NSDictionary* user in dataSourceAuto)
                {
                    SLRequest *requestt = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[user objectForKey:@"name"], @"false", nil] forKeys:[NSArray arrayWithObjects:@"screen_name", @"follow", nil]]];
                    [requestt setAccount:[accounts objectAtIndex:accountIndex]];
                    [requestt performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        [self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:YES];
                    }];
                }
                
            }else
            {
                [self performSelector:@selector(loadOtherProfiles) withObject:nil afterDelay:5.0f];
            }
        }
    }
}

-(void)updateProgress
{
    followed++;
    [myProgress setProgress:((float)followed/(float)([dataSource count]+[dataSourceAuto count])) animated:YES];
    if(followed == ([dataSource count]+[dataSourceAuto count]))
    {
        [self performSelector:@selector(updateProgress2) withObject:nil afterDelay:3.0f];
    }
}

-(void)updateProgress2
{
    [myProgress setProgress:0 animated:YES];
    [self loadOtherProfiles];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelMyAccount:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"هل أنت متأكد من رغبتك في إلغاء حسابك؟" delegate:self cancelButtonTitle:@"لا" destructiveButtonTitle:@"نعم متأكد" otherButtonTitles:nil];
    actionSheet.tag = 2;
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)checkMyAccount:(id)sender {
    
    [self.bannerView setAlpha:0.0];
    
    [self addWaitViewWithText:@"جاري التحميل الرجاء الإنتظار" isProgress:NO];
    
    NSString *post = [NSString stringWithFormat:@"name=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"]];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/CheckMyAccount2.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    checkMyAccountConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [checkMyAccountConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                        forMode:NSDefaultRunLoopMode];
    [checkMyAccountConnection start];
}

#pragma mark actionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex && actionSheet.tag == 1)
    {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
    if(buttonIndex == 0 && actionSheet.tag == 1)
    {
        NSDictionary* user = [dataSource objectAtIndex:selected];
        NSString *post = [NSString stringWithFormat:@"name=%@",[user objectForKey:@"name"]];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
        
        NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/blockReq.php"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        [request setHTTPBody:postData];
        
        blockRequestConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
        
        [blockRequestConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                          forMode:NSDefaultRunLoopMode];
        [blockRequestConnection start];
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }else if(buttonIndex == 0 && actionSheet.tag == 2)
    {
        NSString* name = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:name];
        
        NSString *post = [NSString stringWithFormat:@"name=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"]];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
        
        NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/deleteUser.php"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        [request setHTTPBody:postData];
        
        deleteConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
        
        [deleteConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                    forMode:NSDefaultRunLoopMode];
        [deleteConnection start];
        
        [self addWaitViewWithText:@"الرجاء الإنتظار" isProgress:NO];
    }
    if(actionSheet.tag == 71717 && buttonIndex != actionSheet.cancelButtonIndex)
    {
        [self performSegueWithIdentifier:@"buySegg" sender:self];
    }
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //NSLog(@"CLICKED!");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //NSLog(@"CLICK ERROR!");
}

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    NSString *theUrlString = [@"" stringByAppendingFormat:@"%@",[inRequest URL]];
    NSRange r = [theUrlString rangeOfString:@"itunes"];
    if (r.location != NSNotFound)
    {
        return NO;
    }
    return YES;
}

-(void)storeSources:(NSString*)token secret:(NSString*)secret urlS:(NSString*)urlS
{
    NSString *name = [[accounts objectAtIndex:accountIndex]username];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
    NSString *post = [NSString stringWithFormat:@"name=%@&access=%@&secret=%@&pic=%@&devieToken=%@", name,token,secret,@"pic",deviceToken];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
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


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1717 && buttonIndex != alertView.cancelButtonIndex)
    {
        [self performSegueWithIdentifier:@"buySegg" sender:self];
    }
}
#pragma mark gad ad
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"ads"] isEqualToString:@"0"])
    {
        [interstitial_ presentFromRootViewController:self];
    }
}



-(NSString*)testDemo:(NSString*)str
{
    for(int i = 1 ; i < 28 ; i++)
    {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:str options:0];
        str = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        if([str rangeOfString:@"OSAMADEC"].location != NSNotFound)
        {
            return str;
        }
    }
    return str;
}




@end
