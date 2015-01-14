//
//  ChooseAccountViewController.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "ChooseAccountViewController.h"
#import "FollowersExchangePurchase.h"
#import "AppDelegate.h"

@interface ChooseAccountViewController ()
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@end

@implementation ChooseAccountViewController
{
    NSMutableData* responseDataa;
}

@synthesize accounts,accountStore,aboutController,bannerView;
static int selected;
bool showw = YES;

#pragma mark : segue delegate
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"mainSeg"])
    {
        //HomeViewController* dest = (HomeViewController*)[segue destinationViewController];
        //[dest setAccountIndex:selected];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    tableClickedIndex = 0;
    
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = @"ca-app-pub-2433238124854818/2360105595";
    bannerView.rootViewController = self;
    [self.adView addSubview:bannerView];
    
    
    NSString *post = @"";
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    responseDataa = [[NSMutableData alloc]init];
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/enc/myPoints.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    self.pointsConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [self.pointsConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                forMode:NSDefaultRunLoopMode];
    [self.pointsConnection start];
    
    
    store = [UICKeyChainStore keyChainStore];
    
    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"alTar5es"])
    {
        showw = NO;
        [self performSegueWithIdentifier:@"licenceSeg" sender:self];
    }
    
    accounts = [[NSArray alloc]init];
    accountStore = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [self.accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted && !error) {
                 //  Step 2:  Create a request
                 accounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                 if(accounts.count == 0)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"عفوا" message:@"لا يوجد حساب تويتر مسجل. برجاء تسجيل حساب تويتر عن طريق الإعدادات الخاصة بالأيفون" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                         [_mainWaitView removeFromSuperview];
                         [_mainWaitView removeFromSuperview];
                     });
                 }else
                 {
                     [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
                     [self.tableView setNeedsDisplay];
                 }
                 
                 // Housein:
                 //[_mainWaitView removeFromSuperview];
                 // Housein:
             }else if(error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"عفوا" message:@"لا يوجد حساب تويتر مسجل. برجاء تسجيل حساب تويتر عن طريق الإعدادات الخاصة بالأيفون" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                     [_mainWaitView removeFromSuperview];
                     [_mainWaitView removeFromSuperview];
                 });
             }
         }];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:0/255 green:90.0/255 blue:120.0/255 alpha:1]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-bar-img.png"] forBarMetrics:UIBarMetricsDefault];
        [_topBuyButton setTintColor:[UIColor colorWithRed:0/255 green:90.0/255 blue:120.0/255 alpha:1]];
        [_topAboutButton setTintColor:[UIColor colorWithRed:0/255 green:90.0/255 blue:120.0/255 alpha:1]];
    }
    else
    {
        [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    }
    
    [[self.navigationController view] addSubview:_mainWaitView];
    _mainWaitView.frame = CGRectMake(0, 0, _mainWaitView.frame.size.width, _mainWaitView.frame.size.height);
    
    // Housein:
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"isDoneHelp"])
    {
        [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector:@selector(showHelp:) userInfo: nil repeats:NO];
    }
    else
    {
        [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector:@selector(startAds:) userInfo: nil repeats:NO];
    }
}

- (void)refreshTable {
    //TODO: refresh your data
    [self.refreshControl endRefreshing];
    accounts = [[NSArray alloc]init];
    accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [self.accountStore
                                         accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    [self.accountStore
     requestAccessToAccountsWithType:twitterAccountType
     options:NULL
     completion:^(BOOL granted, NSError *error) {
         if (granted && !error) {
             //  Step 2:  Create a request
             accounts = [self.accountStore accountsWithAccountType:twitterAccountType];
             if(accounts.count == 0)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"عفوا" message:@"لا يوجد حساب تويتر مسجل. برجاء تسجيل حساب تويتر عن طريق الإعدادات الخاصة بالأيفون" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                     [_mainWaitView removeFromSuperview];
                     [_mainWaitView removeFromSuperview];
                 });
             }else
             {
                 [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
                 [self.tableView setNeedsDisplay];
             }
             
             // Housein:
             //[_mainWaitView removeFromSuperview];
             // Housein:
         }else if(error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"عفوا" message:@"لا يوجد حساب تويتر مسجل. برجاء تسجيل حساب تويتر عن طريق الإعدادات الخاصة بالأيفون" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
                 [_mainWaitView removeFromSuperview];
                 [_mainWaitView removeFromSuperview];
             });
         }
     }];
}

-(void)showHelp:(NSTimer *)timer
{
    [self.navigationController.view addSubview:_helpImage];
    [self.navigationController.view addSubview:_helpButton];
    
    _helpButton.frame = self.navigationController.view.frame;
    _helpButton.center = self.navigationController.view.center;
    
    _helpImage.frame = self.navigationController.view.frame;
    _helpImage.center = self.navigationController.view.center;
    
    //[NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector:@selector(startAds:) userInfo: nil repeats:NO];
}

- (IBAction)closeHelp:(id)sender {
    [_helpImage removeFromSuperview];
    [_helpButton removeFromSuperview];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDoneHelp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)startAds:(NSTimer *)timer
{
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        NSError *theError;
        NSDictionary *json;
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/sendComm.php"]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:10];
        
        [request setHTTPMethod: @"GET"];
        
        NSError *requestError;
        NSURLResponse *urlResponse = nil;
        
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        
        
        if (responseData)
        {
            NSMutableArray* dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization
                                                                               JSONObjectWithData:responseData
                                                                               options:kNilOptions
                                                                               error:&theError]];
            
            if (theError || dataSource.count == 0)return;
            
            json = [dataSource objectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self openAdWithImage:[json objectForKey:@"pic"] link:[json objectForKey:@"link"] version:[json objectForKey:@"version"]];
                
            });
            
        }
    });
}

-(void)openAdWithImage:(NSString *)img link:(NSString*)theLink version:(NSString*)theVersion
{
    if ([theVersion integerValue] == 0)return;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"mesa3edAdsVersion"])
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"mesa3edAdsVersion"] integerValue] == [theVersion integerValue])return;
        [[NSUserDefaults standardUserDefaults]setObject:theVersion forKey:@"mesa3edAdsVersion"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]setObject:theVersion forKey:@"mesa3edAdsVersion"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    UIView *mainAdView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    [mainAdView setTag:784];
    
    [mainAdView setBackgroundColor:[UIColor colorWithRed:196.0/255 green:196.0/255 blue:196.0/255 alpha:1.0]];
    
    [[[self navigationController] view] addSubview:mainAdView];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]init];
    
    [activityView startAnimating];
    
    [mainAdView addSubview:activityView];
    
    [activityView setCenter:mainAdView.center];
    
    NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:img]];
    UIImage * image = [UIImage imageWithData:imageData];
    
    UIImageView *adImage = [[UIImageView alloc]initWithImage:image];
    
    [adImage setContentMode:UIViewContentModeScaleAspectFit];
    
    [adImage setFrame:mainAdView.frame];
    
    [mainAdView addSubview:adImage];
    
    [adImage setCenter:mainAdView.center];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(closeAds:)forControlEvents:UIControlEventTouchUpInside];
    [mainAdView addSubview:closeButton];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"close-back-b.png"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(10, 25, 23, 23);
    
    if ([self isValidUrl:theLink])
    {
        UIButton *adsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [adsButton addTarget:self action:@selector(openAds:)forControlEvents:UIControlEventTouchUpInside];
        [mainAdView addSubview:adsButton];
        [adsButton setFrame:CGRectMake(0, 80, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        
        [[NSUserDefaults standardUserDefaults]setObject:theLink forKey:@"mesa3edAdsLink"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        NSLog(@"ValidUrl");
    }
    
    [mainAdView setFrame:CGRectMake( 0, [[UIScreen mainScreen] bounds].size.height, 320, [[UIScreen mainScreen] bounds].size.height)];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [mainAdView setFrame:CGRectMake( 0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    [UIView commitAnimations];
}

- (IBAction)openAds:(id)sender
{
    [[[[self navigationController] view] viewWithTag:784]removeFromSuperview];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"mesa3edAdsLink"]]];
}

- (IBAction)closeAds:(id)sender
{
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         [[[[self navigationController] view] viewWithTag:784] setFrame:CGRectMake( 0, [[UIScreen mainScreen] bounds].size.height, 320, [[UIScreen mainScreen] bounds].size.height)];
                     }
                     completion:^(BOOL finished) {
                         [[[[self navigationController] view] viewWithTag:784]removeFromSuperview];
                         
                     }];
    [UIView commitAnimations];
}

- (BOOL)isValidUrl:(NSString *)urlString{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    return [NSURLConnection canHandleRequest:request];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)updateTable
{
    [[self tableView]reloadData];
    [self.tableView setNeedsDisplay];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (showw && ![[NSUserDefaults standardUserDefaults]boolForKey:@"newRules8"] && [[NSUserDefaults standardUserDefaults]boolForKey:@"alTar5es"])
    {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newRules8"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self performSegueWithIdentifier:@"newSeg" sender:self];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [bannerView loadRequest:[GADRequest request]];
        
    NSString *post = @"";
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/buyFollowersOrNo.php"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    self.buyFollowerConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [self.buyFollowerConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                          forMode:NSDefaultRunLoopMode];
    [self.buyFollowerConnection start];
    
    [super viewWillAppear:animated];[[self.navigationController navigationBar]setHidden:NO];
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
    return [accounts count];
}

- (IBAction)openAbout:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"عن التطبيق",@"الجديد في هذا الإصدار",nil];
    [actionSheet setTag:2];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  {
    switch (buttonIndex) {
        case 0:
        {
            if (actionSheet.tag == 2)
            {
                [self.navigationController presentViewController:aboutController animated:YES completion:nil];
                [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                 target: self
                                               selector:@selector(checkAbout:)
                                               userInfo: nil repeats:YES];
            }
        }
            break;
        case 1:
        {
            [self performSegueWithIdentifier:@"newSeg" sender:self];
        }
    }
}

-(void)checkAbout:(NSTimer *)timer {
    if (isCloseAbout)
    {
        isCloseAbout = NO;
        [timer invalidate];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
 
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    [[cell textLabel]setText:[[accounts objectAtIndex:[indexPath row]]username]];
    [[cell imageView] setImage:[UIImage imageNamed:@"twitter-logo.png"]];
    [_mainWaitView removeFromSuperview];
    [_mainWaitView removeFromSuperview];
    [_mainWaitView removeFromSuperview];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected = (int)[indexPath row];
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%i",selected] forKey:@"accountIndex"];
    [[NSUserDefaults standardUserDefaults]setValue:[[accounts objectAtIndex:selected] username] forKey:@"accountName"];
    [self performSegueWithIdentifier:@"mainSeg" sender:self];
}



-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(self.pointsConnection == connection) // if loadprofiles so we need to populate the table
    {
        [responseDataa appendData:data];
    }else
    {
        NSString* response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [[NSUserDefaults standardUserDefaults]setObject:response forKey:@"buyFollow"];
        [FollowersExchangePurchase sharedInstance];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(connection == self.pointsConnection)
    {
        NSString* str = [[NSString alloc]initWithData:responseDataa encoding:NSUTF8StringEncoding];
        
        [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"debugging"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        NSArray* response = [[self testDemo:str] componentsSeparatedByString:@"##"];
        
        NSString* timeLimit = [response objectAtIndex:21];
        
        NSString* followLimit = [response objectAtIndex:22];
        
        
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u1cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u1sec"];
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u2cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u2sec"];
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u3cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u3sec"];
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u4cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u4sec"];
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u5cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u5sec"];
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u6cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u6sec"];
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u7cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u7sec"];
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u8cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u8sec"];
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u9cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u9sec"];
         
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u10cons"];
         [[NSUserDefaults standardUserDefaults] setValue:@""  forKey:@"u10sec"];
        
        
        
        if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"defneLimitServer"] isEqualToString:followLimit])
        {
            [store setString:followLimit forKey:@"defnelimit"];
            [store setString:@"NO" forKey:@"defnelimitBool"];
            [store synchronize];
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:followLimit  forKey:@"defneLimitServer"];
        [[NSUserDefaults standardUserDefaults] setValue:timeLimit  forKey:@"defneLimitTimeServer"];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
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
