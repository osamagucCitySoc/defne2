//
//  TweetChoserViewController.m
//  retweetlyy
//
//  Created by OsamaMac on 1/5/14.
//  Copyright (c) 2014 OsamaMac. All rights reserved.
//

#import "TweetChoserViewController.h"

@interface TweetChoserViewController ()

@end

@implementation TweetChoserViewController

@synthesize bannerView,products,productToBuy,twitterAPI,twitterIndex;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productCanceled:) name:IAPHelperProductFailedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getPrice];
    
    screenWidth =  [[UIScreen mainScreen] bounds].size.width;
    
    
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    if ([ver floatValue] >= 7.0)
    {
        //self.navigationController.navigationBar.tintColor = [UIColor grayColor];
        screenHeight =  [[UIScreen mainScreen] bounds].size.height;
    }
    else
    {
        screenHeight =  [[UIScreen mainScreen] bounds].size.height - 20;
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-bar-back.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [self showWaitViewWithText:nil];

    dataSource = [[NSMutableArray alloc]init];
    accounts = [[NSArray alloc]init];
    accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [accountStore
                                         accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    [accountStore
     requestAccessToAccountsWithType:twitterAccountType
     options:NULL
     completion:^(BOOL granted, NSError *error) {
         if (granted) {
             //  Step 2:  Create a request
             accounts = [accountStore accountsWithAccountType:twitterAccountType];
             int accountIndex = accountIndex = twitterIndex;
             
             NSURL *url = [NSURL URLWithString:self.twitterAPI];
             NSDictionary *params = @{@"screen_name" : [[accounts objectAtIndex:accountIndex] username],
                                      @"trim_user" : @"1",
                                      @"include_rts":@"1",
                                      @"count" : @"50"};
             
             SLRequest *request =
             [SLRequest requestForServiceType:SLServiceTypeTwitter
                                requestMethod:SLRequestMethodGET
                                          URL:url
                                   parameters:params];
             
             //  Attach an account to the request
             [request setAccount:[accounts objectAtIndex:accountIndex]];
             [request performRequestWithHandler:
              ^(NSData *responseData,
                NSHTTPURLResponse *urlResponse,
                NSError *error) {
                  
                  if (responseData) {
                      if (urlResponse.statusCode >= 200 &&
                          urlResponse.statusCode < 300) {
                          
                          NSError *jsonError;
                          dataSource =
                          [NSJSONSerialization
                           JSONObjectWithData:responseData
                           options:NSJSONReadingAllowFragments error:&jsonError];
                          if (dataSource) {
                              //NSLog(@"Timeline Response: %@\n", [dataSource objectAtIndex:0]);
                              [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
                          }
                          else {
                              // Our JSON deserialization went awry
                              NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                          }
                      }
                      else {
                          // The server did not respond ... were we rate-limited?
                          NSLog(@"The response status code is %d",
                                urlResponse.statusCode);
                      }
                  }else {
                      // Access was not granted, or an error occurred
                      NSLog(@"%@", [error localizedDescription]);
                  }
              }];
         }
     }];
    
    
    
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    bannerView.adUnitID = @"a1520e416043516";
    bannerView.rootViewController = self;
    [self.tableView setTableHeaderView:bannerView];
    [bannerView loadRequest:[GADRequest request]];
}

-(void)getPrice
{
    products = nil;
    [[FollowersExchangePurchase sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *productss) {
        if (success) {
            products = productss;
        }
    }];
}

-(void)updateTable
{
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
    [self hideWaitView];
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
    static NSString *CellIdentifier = @"TweetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* tweet = [dataSource objectAtIndex:[indexPath row]];
    
    [[cell textLabel]setText:[tweet objectForKey:@"text"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* tweet = [dataSource objectAtIndex:[indexPath row]];
    [[NSUserDefaults standardUserDefaults] setObject:[tweet objectForKey:@"id_str"] forKey:@"tweetID"];
    [[NSUserDefaults standardUserDefaults] setObject:[tweet objectForKey:@"text"] forKey:@"tweetTEXT"];
    int accountIndex = accountIndex = twitterIndex;
    [[NSUserDefaults standardUserDefaults] setObject:[[accounts objectAtIndex:accountIndex] username] forKey:@"tweetUSER"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[FollowersExchangePurchase sharedInstance]buyProduct:productToBuy];
}

#pragma mark - wait view
-(void)showWaitViewWithText:(NSString *)str
{
    [_waitView removeFromSuperview];
    if (str)
    {
        _waitLabel.text = str;
    }
    else
    {
        _waitLabel.text = @"الرجاء الإنتظار";
    }
    
    [_waitView setAlpha:0.0];
    [[[self navigationController]view]addSubview:_waitView];
    [_waitView setFrame:CGRectMake(0, 20, screenWidth, screenHeight)];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [_waitView setAlpha:1.0];
    [UIView commitAnimations];
}


-(void)hideWaitView
{
    [_waitView removeFromSuperview];
}


@end
