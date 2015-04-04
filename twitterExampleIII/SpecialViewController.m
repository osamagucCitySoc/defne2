//
//  HomeViewController.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "SpecialViewController.h"
#include <stdlib.h>

@interface SpecialViewController ()

@end

@implementation SpecialViewController

@synthesize accounts,accountStore,accountIndex,loadProfilesConnection,dataSource,modal,pointsLabel,newFollowers,followedConnection,followActionConnection,timer,selected,blockRequestConnection,deleteConnection,loadingProfiles,followingProfiles,autoFollowConnection,checkMyAccountConnection,followTimes,bannerView,myProgress,FB,followingView,dataSourceAuto,interstitial_;

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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _theHeaderView;
}

-(void)addtheWait:(NSTimer *)timer {
    [self addaWaitViewWithText:@"جاري تحميل البيانات الرجاء الإنتظار" isProgress:NO];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    numberOfLoads = 0;
    
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"ca-app-pub-2433238124854818/3836838794";
    [interstitial_ setDelegate:self];

    
    store = [UICKeyChainStore keyChainStore];
    
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
}

-(void)addaWaitViewWithText:(NSString*)theText isProgress:(BOOL)isProg
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)initt
{
    followed = 0;
    
    followTimes = 0;
    
    
    
    [followingView setAlpha:0];
    myProgress.alpha = 0;
    myProgress.progress = 0;
    
    [self.pointsLabel.layer setCornerRadius:4];
    [self.pointsLabel.layer setBorderWidth:1];
    [self.pointsLabel.layer setBorderColor:[UIColor colorWithRed:91.0/255 green:91.0/255 blue:91.0/255 alpha:1.0].CGColor];
    
    // to know which data source should we load
    newFollowers = YES;
    
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
    dataSourceAuto = [[NSMutableArray alloc]init];
    
    _countLabel.text = [@"عدد الحسابات: " stringByAppendingFormat:@"%d",dataSource.count];
    [_countLabel setNeedsDisplay];
    /*[NSTimer scheduledTimerWithTimeInterval: 0.4
                                     target: self
                                   selector:@selector(addtheWait:)
                                   userInfo: nil repeats:NO];
    */
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"];
    
    NSString *post = [NSString stringWithFormat:@"name=%@", name];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/FB.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    autoFollowConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:YES];
    
    [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                    forMode:NSDefaultRunLoopMode];
    [autoFollowConnection start];
    
        
    [self showLoading];
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
    [pointsLabel setText:[store stringForKey:@"points"]];
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
    _countLabel.text = [@"عدد الحسابات: " stringByAppendingFormat:@"%d",dataSource.count];
    [_countLabel setNeedsDisplay];
    return [dataSource count];
}
-(void)removeWaitVieww
{
    [_waitView removeFromSuperview];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"homeCell2";
    
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
    }else
    {
        [(UIImageView*)[cell viewWithTag:3] setAlpha:0];
        [(UILabel*)[cell viewWithTag:2]setText:[user objectForKey:@"name"]];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    AsyncImageView* asyncImage = [[AsyncImageView alloc]
                                  initWithFrame:frame];
	asyncImage.tag = 1;
	NSURL* url = [[NSURL alloc] initWithString:[user objectForKey:@"pic"]];
	[asyncImage loadImageFromURL:url];
	[cell.contentView addSubview:asyncImage];
    
    asyncImage.layer.borderColor = [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0].CGColor;
    
    asyncImage.layer.borderWidth = 2;
    
    asyncImage.layer.cornerRadius = 23;
    
    asyncImage.layer.masksToBounds = YES;
    
    asyncImage.layer.shouldRasterize = YES;
    
    [cell.contentView addSubview:asyncImage];
    
    _countLabel.text = [@"عدد الحسابات: " stringByAppendingFormat:@"%d",dataSource.count];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"تستطيع التبليغ عن الحسابات المخلة بالآداب، وسيتم مراجعتها من قبلنا." delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"تبليغ عن الحساب" otherButtonTitles:nil];
    actionSheet.tag = 1;
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
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
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

-(void)updateTable1
{
    [self.tableView reloadData];
    [modal hideWithDuration:0.2f delay:0 options:kNilOptions completion:NULL];
    [_waitView removeFromSuperview];
    
    [self.tableView setNeedsDisplay];
    if(followTimes%5 == 0 && ![[NSUserDefaults standardUserDefaults]boolForKey:@"arabdevs.followerExchange.zzz"])
    {
        
    }
    followTimes++;
}

-(void)updateTable2
{
    [modal hide];
    [self.tableView reloadData];
    [_waitView removeFromSuperview];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"لقد تبعت كل الحسابات المتواجدة حاليا ! (Y)" andMessage:@"حاول مرة أخرى بعد قليل."];
    
    [alertView addButtonWithTitle:@"تم"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {}];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleGradient;
    [alertView show];
    [self.tableView setNeedsDisplay];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // check which connection recieved data
    [self performSelectorOnMainThread:@selector(removeWaitVieww) withObject:nil waitUntilDone:YES];
    if(loadProfilesConnection == connection) // if loadprofiles so we need to populate the table
    {
        // NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError* error2;
        
        dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization
                                                           JSONObjectWithData:data
                                                           options:kNilOptions
                                                           error:&error2]];
        
        dataSourceAuto = [[NSMutableArray alloc]init];
        for(NSDictionary* dict in dataSource)
        {
            if([[dict objectForKey:@"SPECIAL"]isEqualToString:@"2"])
            {
                [dataSourceAuto addObject:dict];
            }
        }
        
        [dataSource removeObjectsInArray:dataSourceAuto];
        
        if (!isDoneMsg)
        {
            isDoneMsg = YES;
            OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"جديد" message:@"عند متابعتك للمميزين ستحصل على نقاط مجانية." timeout:10 dismissible:YES];
            [alert show];
        }
        
        if([dataSource count] == 1)
        {
            dataSource = [[NSMutableArray alloc]init];
        }
        _countLabel.text = [@"عدد الحسابات: " stringByAppendingFormat:@"%d",dataSource.count];
        [_countLabel setNeedsDisplay];
        if([dataSource count]>0)
        {
            // NSString *stringRep = [NSString stringWithFormat:@"%@",dataSource];
            ////NSLog(@"%@",stringRep);
            [self performSelectorOnMainThread:@selector(updateTable1) withObject:nil waitUntilDone:YES];
            
        }else
        {
            [self performSelectorOnMainThread:@selector(updateTable2) withObject:nil waitUntilDone:YES];
        }
        
        if(numberOfLoads % 5 == 0 && ![[NSUserDefaults standardUserDefaults]boolForKey:@"arabdevs.followerExchange.zzz"])
        {
            GADRequest* request = [GADRequest request];
            [interstitial_ loadRequest:request];
        }
        numberOfLoads++;
        
    }else if(checkMyAccountConnection == connection)
    {
        [_waitView removeFromSuperview];
        [_waitView removeFromSuperview];
        NSString* resp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[[accounts objectAtIndex:accountIndex]username]message:resp delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alert show];
        [self showStatus];
        
        NSRange r = [resp rangeOfString:@"-غير مميز"];
        
        if (r.location == NSNotFound)
        {
            _specialImage.image = [UIImage imageNamed:@"medal-special.png"];
            _specialLabel.textColor = [UIColor blackColor];
            isSpecial = YES;
        }
        else
        {
            _specialImage.image = [UIImage imageNamed:@"medal-empty.png"];
            _specialLabel.textColor = [UIColor colorWithRed:159.0/255 green:159.0/255 blue:159.0/255 alpha:1];
            isSpecial = NO;
        }
        
        r = [resp rangeOfString:@"-بتابع من يتابعه"];
        
        if (r.location == NSNotFound)
        {
            _noFollowImage.image = [UIImage imageNamed:@"medal-no-follow.png"];
            _noFollowLabel.textColor = [UIColor blackColor];
            isNoFollows = YES;
        }
        else
        {
            _noFollowImage.image = [UIImage imageNamed:@"medal-empty.png"];
            _noFollowLabel.textColor = [UIColor colorWithRed:159.0/255 green:159.0/255 blue:159.0/255 alpha:1];
            isNoFollows = NO;
        }
        
        r = [resp rangeOfString:@"-غير مسجل في الفولو التلقائي"];
        
        if (r.location == NSNotFound)
        {
            _autoFollowImage.image = [UIImage imageNamed:@"medal-auto.png"];
            _autoFollowLabel.textColor = [UIColor blackColor];
            isAutoFollows = YES;
            
            _unlimitedImage.image = [UIImage imageNamed:@"medal-unlimited.png"];
            _unlimitedLabel.textColor = [UIColor blackColor];
        }
        else
        {
            _autoFollowImage.image = [UIImage imageNamed:@"medal-empty.png"];
            _autoFollowLabel.textColor = [UIColor colorWithRed:159.0/255 green:159.0/255 blue:159.0/255 alpha:1];
            isAutoFollows = NO;
            
            _unlimitedImage.image = [UIImage imageNamed:@"medal-empty.png"];
            _unlimitedLabel.textColor = [UIColor colorWithRed:159.0/255 green:159.0/255 blue:159.0/255 alpha:1];
        }
        
    }else if(autoFollowConnection == connection)
    {
        NSString* resp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"1"])
        {
            FB = YES;
            [myProgress setAlpha:0.0];
            [myProgress setNeedsDisplay];
        }else
        {
            FB = NO;
            [myProgress setAlpha:1.0];
            [myProgress setNeedsDisplay];
        }
    }else
    {
        //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
}

-(void)showStatus
{
    _theMainLabel.title = @"حالة الحساب";
    [_statusView setHidden:NO];
    [_statusView setAlpha:0.0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [_statusView setAlpha:1.0];
    [UIView commitAnimations];
}

-(void)hideStatus
{
    _theMainLabel.title = @"قائمة الحسابات";
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [_statusView setAlpha:0.0];
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval: 0.3
                                     target: self
                                   selector:@selector(hideStatus:)
                                   userInfo: nil repeats:NO];
}

-(void)hideStatus:(NSTimer *)timer
{
    [_statusView setHidden:YES];
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
    if (isAutoFollows)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"إخفاء الحساب" message:@"تم تفعيل هذه الميزة لأنك مشترك في خدمة الفولو التلقائي، شكراً لك." delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"إخفاء الحساب" message:@"هذه الميزة تتفعل تلقائياً عند إشتراكك في ميزة الفولو التلقائي، لضمان خصوصية حسابك، بحيث لايظهر لأحد أنك تستخدم التطبيق." delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
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
   
    BOOL load = YES;
    
    [bannerView loadRequest:[GADRequest request]];
    
    load = YES;
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"follows"];
    
    if(load)
    {
        _waitLabel.text = @"جاري تحميل حسابات جديدة";
        [_waitLabel setNeedsDisplay];
        
        _activityView.hidden = NO;
        myProgress.hidden = YES;
        
        NSString *post = [NSString stringWithFormat:@"name=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"]];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
        
        NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/sendProfilesSpecial.php"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        
        loadProfilesConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
        
        [loadProfilesConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                          forMode:NSDefaultRunLoopMode];
        [loadProfilesConnection start];
        //NSLog(@"%@",currentTable);
    }
}

#pragma this method is dealing for following all the showed profiles for the user
- (IBAction)backClicked:(id)sender {
    [self hideStatus];
    [self.parentViewController.parentViewController.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)followAll:(id)sender {
    followed = 0;
    int follows = [[[NSUserDefaults standardUserDefaults]objectForKey:@"follows"] intValue];
    follows = follows + [dataSource count];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%i",follows] forKey:@"follows"];
    
    [self addaWaitViewWithText:@"جاري المتابعـــــــــــة الرجاء الإنتظار" isProgress:YES];
    
    if(newFollowers)
    {
        if([dataSource count]>1)
        {
            [followingView setAlpha:1];
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
        }
    }
}

-(void)updateProgress
{
    followed++;
    [myProgress setProgress:((float)followed/(float)[dataSource count]) animated:YES];
    if(followed == [dataSource count])
    {
        [followingView setAlpha:0];
        [myProgress setProgress:0 animated:YES];
        if(![[store stringForKey:@"points"]isEqualToString:@"Unlimited"])
        {
        int current = [[store stringForKey:@"points"] intValue];
        current += 1;//[dataSource count]+[dataSourceAuto count];
        [store setString:[NSString stringWithFormat:@"%i",current] forKey:@"points"];
        [store synchronize];
        [pointsLabel setText:[NSString stringWithFormat:@"عدد النقاط : %i",current]];
        [pointsLabel setNeedsDisplay];
        }
        [self loadOtherProfiles];
    }
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
    [self addaWaitViewWithText:@"جاري التحميل الرجاء الإنتظار" isProgress:NO];
    
    NSString *post = [NSString stringWithFormat:@"name=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"]];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
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


#pragma mark - ui alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        if(buttonIndex == 0)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [tweetSheet setInitialText:@"#ضيفني_واضيفك، التطبيق العربي الفريد من نوعه. يعطيك إمكانية زيادة عدد متابعيك على تويتر بطريقة سهلة للغاية http://goo.gl/nMDZm"];
                [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result){
                    
                    switch (result) {
                        case SLComposeViewControllerResultCancelled:
                            break;
                        case SLComposeViewControllerResultDone:
                            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"tweetedBefore"];
                            int current = [[store stringForKey:@"points"]intValue];
                            current += 50;
                            [store setString:[NSString stringWithFormat:@"%i",current] forKey:@"points"];
                            [store synchronize];
                            [pointsLabel setText:[NSString stringWithFormat:@"%i",current]];
                            [pointsLabel setNeedsDisplay];
                        default:
                            break;
                    }
                }];
                [self presentViewController:tweetSheet animated:YES completion:nil];
            }
            
        }
    }
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
        NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
        
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
        NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];

        NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/deleteUser.php"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        [request setHTTPBody:postData];
        
        deleteConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
        
        [deleteConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                    forMode:NSDefaultRunLoopMode];
        [deleteConnection start];
        
        [self addaWaitViewWithText:@"الرجاء الإنتظار" isProgress:NO];
    }
}


#pragma - mark TEMP SOURCES
-(void)getPic
{
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            if(accounts == nil)
            {
                accounts = [accountStore accountsWithAccountType:accountType];
            }
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
                        NSString* image = [json objectForKey:@"profile_image_url"];
                        [[NSUserDefaults standardUserDefaults]setObject:name forKey:@"username"];
                        [[NSUserDefaults standardUserDefaults]setObject:image forKey:@"pic"];
                        [standardUserDefaults synchronize];
                        [self performSelectorOnMainThread:@selector(saveSources) withObject:nil waitUntilDone:YES];
                    }
                }
            }];
        }
    }];
    
}
-(void)saveSources
{
    
    NSString *name = [[accounts objectAtIndex:accountIndex]username];
    NSString *post = [NSString stringWithFormat:@"name=%@", name];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/FB.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    autoFollowConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:YES];
    
    [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                    forMode:NSDefaultRunLoopMode];
    [autoFollowConnection start];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"]];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"CLICKED!");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"CLICK ERROR!");
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


#pragma mark gad ad
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"ads"] isEqualToString:@"0"])
    {
        [interstitial_ presentFromRootViewController:self];
    }
}

@end
