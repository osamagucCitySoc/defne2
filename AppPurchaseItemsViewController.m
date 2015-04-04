//
//  AppPurchaseItemsViewController.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/19/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "AppPurchaseItemsViewController.h"
#import "IAPHelper.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>

@interface AppPurchaseItemsViewController ()

@end

NSNumberFormatter * _priceFormatter;

@implementation AppPurchaseItemsViewController

@synthesize products,accounts,accountsPicker,accountStore,actionSheet,selectedTwitterAccount,dontFollowConnection,autoFollowConnection,pointsConnection,which;

int add = 0;
int indexx = 0;
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
    
    store = [UICKeyChainStore keyChainStore];
    
    OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"للشرح" message:@"لشرح المشتريات برجاء الضغط على ما تريد شرحه" timeout:4 dismissible:YES];
    [alert setBackgroundColor:[UIColor blackColor]];
    [alert show];
    
    _waitView.frame = CGRectMake(0, 0, _waitView.frame.size.width, _waitView.frame.size.height);
    
    _waitLabel.text = @"جاري تفعيل الحساب الرجاء الإنتظار";
    
    accounts = [[NSMutableArray alloc]init];
    accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [self.accountStore
                                         accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    [self.accountStore
     requestAccessToAccountsWithType:twitterAccountType
     options:NULL
     completion:^(BOOL granted, NSError *error) {
         if (granted) {
             accounts = (NSMutableArray*)[self.accountStore accountsWithAccountType:twitterAccountType];
         }
     }];
    
    for(int i = 0 ; i < [products count] ; i++)
    {
        SKProduct *productt = products[i];
        NSLog(@"%@",productt.productIdentifier);
        if([productt.productIdentifier isEqualToString:@"arabdevs.followerExchange.zspecial"])
        {
            indexx = i;
            break;
        }
    }
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    UIBarButtonItem *restoreButton = [[UIBarButtonItem alloc] initWithTitle:@"استرجاع المشتريات" style:UIBarButtonItemStylePlain target:self action:@selector(restoreThePurchases)];
    self.navigationItem.rightBarButtonItem = restoreButton;
    
    //[[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
}

- (void)restoreThePurchases
{
    FollowersExchangePurchase *inAppPurchaseHelper = [FollowersExchangePurchase sharedInstance];
    [inAppPurchaseHelper restoreCompletedTransactions];
    if ([inAppPurchaseHelper productPurchased:@"arabdevs.followerExchange.unlimitedPoint"]){
//        [[NSUserDefaults standardUserDefaults] setValue:@"Unlimited" forKey:@"points"];
        [store setString:@"Unlimited" forKey:@"points"];
        [store synchronize];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"arabdevs.followerExchange.unlimitedPoint"];
    }else if ([inAppPurchaseHelper productPurchased:@"arabdevs.followerExchange.zzz"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"arabdevs.followerExchange.zzz"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productRestored:) name:IAPHelperProductRestoreNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productCanceled:) name:IAPHelperProductFailedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    return [products count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct * product = (SKProduct *) products[indexPath.row];
    add = 0;
    static NSString *CellIdentifier = @"productsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14]];
    
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
    if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.zspecial"])
    {
        [[cell imageView] setImage:[UIImage imageNamed:@"normal-buy.png"]];
        cell.textLabel.text = @"شراء عضوية مميزة";
        cell.detailTextLabel.text = @"يرجى الدخول بالحساب و الذهاب لقسم المميزين";
    }else
    {
       
        product = (SKProduct *) products[indexPath.row+add];
        cell.textLabel.text = product.localizedTitle;
        
        [_priceFormatter setLocale:product.priceLocale];
        cell.detailTextLabel.text = [_priceFormatter stringFromNumber:product.price];
        
        if ([[FollowersExchangePurchase sharedInstance] productPurchased:product.productIdentifier]
            && ![product.productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredPoint"] && ![product.productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredZFiftyPoint"] && !![product.productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredZZFiftyPoint"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.accessoryView = nil;
        } else {
            if ([product.localizedTitle isEqualToString:@"Unlimited Points"] || [product.localizedTitle isEqualToString:@"يتم متابعتك من دون فولو باك منك"] || [product.localizedTitle isEqualToString:@"٣ أيام فولو تلقائي لك مع عدم فولو باك"]|| [product.localizedTitle isEqualToString:@"٧ أيام فولو تلقائي لك مع عدم فولو باك"] || [product.localizedTitle isEqualToString:@"أحصل على حتى ٥٠٠٠ متابع"]
                ||[product.localizedTitle isEqualToString:@"مميز + عدم فولو باك"] || [product.localizedTitle isEqualToString:@"فولو تلقائي + عدم فولو باك"]
                || [product.localizedTitle isEqualToString:@"أحصل على حتى ٣٠٠٠ متابع"] || [product.productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredZZFiftyPoint"])
            {
                [[cell imageView] setImage:[UIImage imageNamed:@"gold-buy.png"]];
            }
            else
            {
                if ([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.00"])
                {
                    [[cell imageView] setImage:[UIImage imageNamed:@"diamond-buy.png"]];
                }
                else
                {
                    [[cell imageView] setImage:[UIImage imageNamed:@"normal-buy.png"]];
                }
            }
            UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [buyButton setBackgroundImage:[UIImage imageNamed:@"buy-button.png"] forState:UIControlStateNormal];
            [buyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            buyButton.frame = CGRectMake(0, 0, 72, 37);
            [buyButton setTitle:@"شراء" forState:UIControlStateNormal];
            buyButton.tag = indexPath.row+add;
            [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = buyButton;
        }
    }
    return cell;
}

-(void)closePopUp:(id)sender
{
    UIView *popUpView = [[UIView alloc]init];
    
    popUpView = [[self.navigationController view] viewWithTag:191];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:0
                     animations:^{
                         [popUpView setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 20)];
                     }
                     completion:^(BOOL finished) {
                         [popUpView removeFromSuperview];
                     }];
    [UIView commitAnimations];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isPhoto = NO;
    int theTime = 7;
    NSString* title = @"";
    NSString* desc = @"";
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIView *popUpView = [[UIView alloc]initWithFrame:CGRectMake(0, 548, [[UIScreen mainScreen] bounds].size.width, 548)];
    
    popUpView.tag = 191;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setTitle:@"رجوع" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [backButton setBackgroundImage:[UIImage imageNamed:@"help-button.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"help-button-highlighted.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(closePopUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [backButton setFrame:CGRectMake(10, 18, 51, 27)];
    [popUpView addSubview:backButton];
    
    UIButton *buyNowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [buyNowButton setBackgroundImage:[UIImage imageNamed:@"buy-now-button.png"] forState:UIControlStateNormal];
    [buyNowButton setBackgroundImage:[UIImage imageNamed:@"buy-now-button-highlighted.png"] forState:UIControlStateHighlighted];
    buyNowButton.tag = indexPath.row+add;
    [buyNowButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height > 480)
    {
        [buyNowButton setFrame:CGRectMake(60, 448, 200, 48)];
    }
    else
    {
        [buyNowButton setFrame:CGRectMake(60, 405, 200, 48)];
    }
    [popUpView addSubview:buyNowButton];
    
    
    SKProduct *product = (SKProduct *) products[indexPath.row];
    
    if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredPoint"])
    {
        title = @"١٠٠ نقطة";
        desc = @"١٠٠ عمليه فولو و فولو باك";
    }else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredZFiftyPoint"])
    {
        title = @"٢٥٠ نقطة";
        desc = @"٢٥٠ عمليه فولو و فولو باك";
    }else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredZZFiftyPoint"])
    {
        title = @"٤٠٠ نقطة";
        desc = @"٤٠٠ عمليه فولو و فولو باك";
    }else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.zz5"])
    {
        isPhoto = NO;
        //[popUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"special-back.png"]]];
        
        title = @"الباقة الذهبية";
        desc = @"عند شراءك للباقة الذهبية، سيتم جعل حسابك ضمن القائمة المميزة باللإضافة لميزة عدم الفولو باك.";
        theTime = 10;
    }else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.autoFollow"])
    {
        title = @"فولو تلقائي لك";
        desc = @"عند شراءك لهذه الميزة سيقوم التطبيق بمتابعة جميع الحسابات القديمة والجديدة تلقائياً (دون عناء الضغط على زر تابع) وكل هذا يتم والتطبيق مغلق، وبالتالي سوف تكسب عدد متابعين هائل جداً، ودون أي تدخل منك.";
        theTime = 20;
    }
    else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.0"])
    {
        title = @"إحصل على 500 متابع";
        desc = @"احصل على 500 متابع عربي حقيقي ١٠٠٪ من الخليج العربي، والتسليم يتم خلال ٤٨ ساعة فقط!";
        theTime = 20;
    }
    else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.1"])
    {
        title = @"إحصل على 1000 متابع";
        desc = @"احصل على 1000 متابع عربي حقيقي ١٠٠٪ من الخليج العربي، والتسليم يتم خلال ٤٨ ساعة فقط!";
        theTime = 20;
    }
    else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.2"])
    {
        title = @"إحصل على 2000 متابع";
        desc = @"احصل على 2000 متابع عربي حقيقي ١٠٠٪ من الخليج العربي، والتسليم يتم خلال ٤٨ ساعة فقط!";
        theTime = 20;
    }
    else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.3"])
    {
        title = @"إحصل على 3000 متابع";
        desc = @"احصل على 3000 متابع عربي حقيقي ١٠٠٪ من الخليج العربي، والتسليم يتم خلال ٤٨ ساعة فقط!";
        theTime = 20;
    }
    else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.00"])
    {
        title = @"الفولو الماسي";
        desc = @"الفولو الماسي هو أقوى مزايا التطبيق وأكثرها كسباً للمتابعين، فهو يجمع بين الفولو التلقائي والفولو اللحظي كما أن المشترك بهذه الميزة سيظهر حسابه دائماً في مقدمة الحسابات بحيث تكون له الأولوية المطلقة في المتابعة، الاشتراك مدته ١٤ يوماً ويلزم تجديد الإشتراك بعد ذلك، وأقل عدد متابعين ممكن كسبه هو ٥٠٠٠ متابع كحد أدنى وممكن أن تصل لأكثر من ١٠ الاف متابع حقيقي خلال مدة الإشتراك (١٤ يوماً).";
        theTime = 20;
    }
    else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.autoFollowZ"])
    {
        title = @"فولو تلقائي + عدم فولو باك";
        desc = @"عند شراء هذه الباقة، سيتم تسجيلك في الفولو التلقائي بالإضافة لميزة عدم الفولو باك وبالتالي تستفيد من الخصم.";
        theTime = 20;
    }
    else if([product.productIdentifier isEqualToString:@"arabdevs.followerExchange.zzNoFollowBack"])
    {
        title = @"فولو لك مع عدم فولو باك";
        desc = @"عند شراء هذه الميزة، سيتابعك الأخرون دون أن تتابعهم.";
        theTime = 20;
    }
    else
    {
        NSLog(@"%@",product.productIdentifier);
    }
    
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    if (isPhoto && [ver floatValue] < 7.0)
    {
        [[self.navigationController view] addSubview:popUpView];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.4];
        [popUpView setFrame:CGRectMake(0, 20, 548, 548)];
        [UIView commitAnimations];
        
    }
    else
    {
        OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:title message:desc timeout:theTime dismissible:YES];
        [alert setBackgroundColor:[UIColor blackColor]];
        [alert show];
    }
}


#pragma mark - buy clicked
- (void)buyButtonTapped:(id)sender {
    
    isRealBuy = NO;
    UIButton *buyButton = (UIButton *)sender;
    buyInt = buyButton.tag;
        SKProduct* prod = [products objectAtIndex:buyInt];
        if([[prod productIdentifier]isEqualToString:@"arabdevs.followerExchange.zz5"] || [[prod productIdentifier]isEqualToString:@"arabdevs.followerExchange.autoFollow"] || [[prod productIdentifier]isEqualToString:@"arabdevs.followerExchange.autoFollowZ"]
           || [[prod productIdentifier]isEqualToString:@"arabdevs.followerExchange.00"]
           || [[prod productIdentifier]isEqualToString:@"arabdevs.followerExchange.0"]
           || [[prod productIdentifier]isEqualToString:@"arabdevs.followerExchange.1"] || [[prod productIdentifier]isEqualToString:@"arabdevs.followerExchange.2"] || [[prod productIdentifier]isEqualToString:@"arabdevs.followerExchange.3"])
        {
            BOOL show = TRUE;
            [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self     cancelButtonTitle:@"الغاء" destructiveButtonTitle:nil otherButtonTitles:nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            
            accountsPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,40, 320, 216)];
            accountsPicker.showsSelectionIndicator=YES;
            accountsPicker.dataSource = self;
            accountsPicker.delegate = self;
            accountsPicker.tag=3;
            
            if([accounts count] == 0)
            {
                show = FALSE;
            }
            [actionSheet addSubview:accountsPicker];
            
            
            if(show)
            {
               UIToolbar *tools=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,320,40)];
                    tools.barStyle=UIBarStyleBlackOpaque;
                    [actionSheet addSubview:tools];
                    
                    
                    
                    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc] initWithTitle:@"موافق" style:UIBarButtonItemStyleBordered target:self action:@selector(purchaseAgain)];
                    
                    doneButton.imageInsets=UIEdgeInsetsMake(200, 6, 50, 25);
                    UIBarButtonItem *CancelButton=[[UIBarButtonItem alloc]initWithTitle:@"الغاء" style:UIBarButtonItemStyleBordered target:self action:@selector(btnActinCancelClicked)];
                    
                    UIBarButtonItem *flexSpace= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                    
                    NSArray *array = [[NSArray alloc]initWithObjects:CancelButton,flexSpace,flexSpace,doneButton,nil];
                    
                    [tools setItems:array];
                    
                    
                    //picker title
                    UILabel *lblPickerTitle=[[UILabel alloc]initWithFrame:CGRectMake(60,8, 200, 25)];
                    lblPickerTitle.text=@"أختر الحساب";
                    lblPickerTitle.backgroundColor=[UIColor clearColor];
                    lblPickerTitle.textColor=[UIColor whiteColor];
                    lblPickerTitle.textAlignment=NSTextAlignmentCenter;
                    lblPickerTitle.font=[UIFont boldSystemFontOfSize:15];
                    [tools addSubview:lblPickerTitle];
                    
                    
                    [actionSheet showFromRect:CGRectMake(0,480, 320,215) inView:self.view animated:YES];
                    [actionSheet setBounds:CGRectMake(0,0, 320, 411)];
            }else
            {
                OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"تنبيه" message:@"كل حساباتك مسجلة" timeout:3 dismissible:YES];
                [alert show];
            }
        }else
        {
            SKProduct *product = products[buyInt];
            [[FollowersExchangePurchase sharedInstance] buyProduct:product];
        }
}



-(void)updateTable
{
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}
#pragma mark- loading the products
- (void)reload {
    products = nil;
    add = 0;
    [self.tableView reloadData];
    [[FollowersExchangePurchase sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *productss) {
        if (success) {
            products = productss;
            add = 0;
            [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
            [self.tableView setNeedsDisplay];
        }
        [self.refreshControl endRefreshing];
    }];
}


#pragma mark - i got the event result of purchasing
- (void)productPurchased:(NSNotification *)notification {
    NSString * productIdentifier = notification.object;
    [products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم الشراء" message:@"تم الشراء شكرا لك." delegate:nil cancelButtonTitle:@"موافق" otherButtonTitles:nil];
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            //if(idx > indexx)
              //  idx--;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            if([productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredPoint"])
            {
                int currentPoints = [[store stringForKey:@"points"] intValue];
                currentPoints+=100;
                [store setString:[NSString stringWithFormat:@"%i",currentPoints] forKey:@"points"];
                [store synchronize];
                [alert show];
                *stop = YES;
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredZFiftyPoint"])
            {
                int currentPoints = [[store stringForKey:@"points"] intValue];
                currentPoints+=250;
                [store setString:[NSString stringWithFormat:@"%i",currentPoints] forKey:@"points"];
                [store synchronize];
                [alert show];
                *stop = YES;
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredZZFiftyPoint"])
            {
                int currentPoints = [[store stringForKey:@"points"] intValue];
                currentPoints+=400;
                [store setString:[NSString stringWithFormat:@"%i",currentPoints] forKey:@"points"];
                [store synchronize];
                [alert show];
                *stop = YES;
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.zz5"])
            {
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                
                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
                NSDictionary *params = @{@"screen_name" : name};
                
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                
                [request setAccount:[accounts objectAtIndex:selectedTwitterAccount]];
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
                            
                            NSString* image = [json objectForKey:@"profile_image_url"];
                            [self performSelectorOnMainThread:@selector(saveSpecialAndNoFb:) withObject:image waitUntilDone:YES];
                        }
                    }
                }];
            
                *stop = YES;
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.0"])
            {
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                NSString *post = [NSString stringWithFormat:@"name=%@", name];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/makeBuyFollower0.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                self.autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [self.autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                     forMode:NSDefaultRunLoopMode];
                [self.autoFollowConnection start];
                [[self.navigationController view] addSubview:_waitView];
                *stop = YES;
                OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"شكرا" message:@"ستتم الإضافة خلال يومين" timeout:5 dismissible:YES];
                [alert show];
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.1"])
            {
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                NSString *post = [NSString stringWithFormat:@"name=%@", name];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/makeBuyFollowers.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                self.autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [self.autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                     forMode:NSDefaultRunLoopMode];
                [self.autoFollowConnection start];
                [[self.navigationController view] addSubview:_waitView];
                *stop = YES;
                OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"شكرا" message:@"ستتم الإضافة خلال يومين" timeout:5 dismissible:YES];
                [alert show];
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.2"])
            {
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                NSString *post = [NSString stringWithFormat:@"name=%@", name];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/makeBuyFollowers2.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                self.autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [self.autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                     forMode:NSDefaultRunLoopMode];
                [self.autoFollowConnection start];
                [[self.navigationController view] addSubview:_waitView];
                *stop = YES;
                OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"شكرا" message:@"ستتم الإضافة خلال يومين" timeout:5 dismissible:YES];
                [alert show];
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.3"])
            {
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                NSString *post = [NSString stringWithFormat:@"name=%@", name];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/makeBuyFollowers3.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                self.autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [self.autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                     forMode:NSDefaultRunLoopMode];
                [self.autoFollowConnection start];
                [[self.navigationController view] addSubview:_waitView];
                *stop = YES;
                OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"شكرا" message:@"ستتم الإضافة خلال يومين" timeout:5 dismissible:YES];
                [alert show];
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.autoFollow"])
            {
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                NSString *post = [NSString stringWithFormat:@"name=%@", name];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/makeAutoFollow.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
               self.autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [self.autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [self.autoFollowConnection start];
                [[self.navigationController view] addSubview:_waitView];
                *stop = YES;
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.00"])
            {
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                NSString *post = [NSString stringWithFormat:@"name=%@&apn=%@", name,[[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"]];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/makeMeAlwaysOnline.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                self.alwaysOnlineConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [self.alwaysOnlineConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                     forMode:NSDefaultRunLoopMode];
                [self.alwaysOnlineConnection start];
                [[self.navigationController view] addSubview:_waitView];
                *stop = YES;
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.autoFollowZ"])
            {
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                NSString *post = [NSString stringWithFormat:@"name=%@", name];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/makeAutoFollowZ.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                self.autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [self.autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                     forMode:NSDefaultRunLoopMode];
                [self.autoFollowConnection start];
                [[self.navigationController view] addSubview:_waitView];
                *stop = YES;
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.zzNoFollowBack"])
            {
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                NSString *post = [NSString stringWithFormat:@"name=%@", name];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/makeNoFB.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                self.noFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
                
                [self.noFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                     forMode:NSDefaultRunLoopMode];
                [self.noFollowConnection start];
                [[self.navigationController view] addSubview:_waitView];
                *stop = YES;
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.zzz"])
            {   
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"arabdevs.followerExchange.zzz"];
                [alert show];
            }
            
            *stop = YES;
        }
    }];
    
}

#pragma mark - i got the event result of purchasing
- (void)productRestored:(NSNotification *)notification {
    NSString * productIdentifier = notification.object;
    if([productIdentifier isEqualToString:@"arabdevs.followerExchange.unlimitedPoint"])
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم" message:@"تم إسترجاع الغير محدود" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

        [store setString:@"Unlimited" forKey:@"points"];
        [store synchronize];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"arabdevs.followerExchange.unlimitedPoint"];

        [alert show];
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
        [self reload];
        [self.refreshControl beginRefreshing];
    }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.zzz"])
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم" message:@"تم إسترجاع إلغاء الإعلانات" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"arabdevs.followerExchange.zzz"];
        [alert show];
    }
}

- (void)productCanceled:(NSNotification *)notification {
    isRealBuy = NO;
    [[NSUserDefaults standardUserDefaults]setValue:@"NOTOK" forKey:shallIBuy];
}

#pragma mark picker view delegates
-(int) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return  [accounts count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[accounts objectAtIndex:row] username];
}

-(void)btnActinCancelClicked
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)purchaseAgain
{
   selectedTwitterAccount = [accountsPicker selectedRowInComponent:0];    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
   
    SKProduct *product = products[buyInt];
    [[FollowersExchangePurchase sharedInstance] buyProduct:product];
}

#pragma mark - connection delegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
        [_waitView removeFromSuperview];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // check which connection recieved data
   
}

#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 777)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        UIToolbar *tools=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,320,40)];
        tools.barStyle=UIBarStyleBlackOpaque;
        [actionSheet addSubview:tools];
        
        
        
        UIBarButtonItem *doneButton=[[UIBarButtonItem alloc] initWithTitle:@"موافق" style:UIBarButtonItemStyleBordered target:self action:@selector(purchaseAgain)];
        
        doneButton.imageInsets=UIEdgeInsetsMake(200, 6, 50, 25);
        UIBarButtonItem *CancelButton=[[UIBarButtonItem alloc]initWithTitle:@"الغاء" style:UIBarButtonItemStyleBordered target:self action:@selector(btnActinCancelClicked)];
        
        UIBarButtonItem *flexSpace= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *array = [[NSArray alloc]initWithObjects:CancelButton,flexSpace,flexSpace,doneButton,nil];
        
        [tools setItems:array];
        
        
        //picker title
        UILabel *lblPickerTitle=[[UILabel alloc]initWithFrame:CGRectMake(60,8, 200, 25)];
        lblPickerTitle.text=@"أختر الحساب";
        lblPickerTitle.backgroundColor=[UIColor clearColor];
        lblPickerTitle.textColor=[UIColor whiteColor];
        lblPickerTitle.textAlignment=NSTextAlignmentCenter;
        lblPickerTitle.font=[UIFont boldSystemFontOfSize:15];
        [tools addSubview:lblPickerTitle];
        
        
        [actionSheet showFromRect:CGRectMake(0,480, 320,215) inView:self.view animated:YES];
        [actionSheet setBounds:CGRectMake(0,0, 320, 411)];
    }
}


-(void)saveSpecialAndNoFb:(NSString*)pic
{
    [[self.navigationController view] addSubview:_waitView];
    
    NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
    
    NSString *post = [NSString stringWithFormat:@"name=%@&pic=%@", name,pic];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/makeSpecial.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    dontFollowConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [dontFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                    forMode:NSDefaultRunLoopMode];
    [dontFollowConnection start];
}

@end
