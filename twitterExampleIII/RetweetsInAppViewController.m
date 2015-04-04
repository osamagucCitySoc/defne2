//
//  RetweetsInAppViewController.m
//  twitterExampleIII
//
//  Created by Osama Rabie on 1/3/15.
//  Copyright (c) 2015 MacBook. All rights reserved.
//

#import "RetweetsInAppViewController.h"
<<<<<<< HEAD
#import "TweetChoserViewController.h"

@interface RetweetsInAppViewController ()<ActionSheetCustomPickerDelegate,UIActionSheetDelegate>
=======

@interface RetweetsInAppViewController ()<ActionSheetCustomPickerDelegate>
>>>>>>> localmaster
@property (strong, nonatomic) NSMutableArray* accounts;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (weak, nonatomic) IBOutlet UILabel *label1;

@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@end


@implementation RetweetsInAppViewController
<<<<<<< HEAD
{
    int selectedTwitterAccount;
    int retweetsNumber;
    BOOL vip;
    SKProduct *productToBuy;
    NSString* twitterAPI;
    NSURLConnection* autoFollowConnection;
    UIView *mainActionView;
=======

{
    int selectedTwitterAccount;
    int retweetsNumber;
    SKProduct *productToBuy;
>>>>>>> localmaster
}

@synthesize accounts,accountStore,products;

<<<<<<< HEAD

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"tweetChooseSeg"])
    {
        TweetChoserViewController* dst = (TweetChoserViewController*)[segue destinationViewController];
        [dst setTwitterAPI:twitterAPI];
        [dst setTwitterIndex:selectedTwitterAccount];
        [dst setProductToBuy:productToBuy];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    vip = false;
=======
- (void)viewDidLoad {
    [super viewDidLoad];
>>>>>>> localmaster
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, 1313)];
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
    
    [self getPrice];
    
}

-(void)getProd
{
    NSString *post = @"";
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/getProd.php"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection* adsConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [adsConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                  forMode:NSDefaultRunLoopMode];
    [adsConnection start];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productCanceled:) name:IAPHelperProductFailedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)getPrice
{
    [self addActivityView];
    products = nil;
    [[FollowersExchangePurchase sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *productss) {
        if (success) {
            products = productss;
            
            SKProduct *product;
            
            NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
            [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            
            for (int i = 0; i < products.count; i++)
            {
                product = (SKProduct *) products[i];
                
                [priceFormatter setLocale:product.priceLocale];
                NSLog(@"Identifier: %@ and Price: %@",[product productIdentifier],[priceFormatter stringFromNumber:product.price]);
                
                if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.r1"])
                {
<<<<<<< HEAD
                    [(UILabel*)[_scrollView viewWithTag:1] setText:[priceFormatter stringFromNumber:product.price]];
=======
                    [(UILabel*)[_scrollView viewWithTag:4] setText:[priceFormatter stringFromNumber:product.price]];
>>>>>>> localmaster
                    NSLog(@"%@",[priceFormatter stringFromNumber:product.price]);
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.r2"])
                {
<<<<<<< HEAD
                    [(UILabel*)[_scrollView viewWithTag:2] setText:[priceFormatter stringFromNumber:product.price]];
=======
                    [(UILabel*)[_scrollView viewWithTag:3] setText:[priceFormatter stringFromNumber:product.price]];
>>>>>>> localmaster
                    NSLog(@"%@",[priceFormatter stringFromNumber:product.price]);
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.r3"])
                {
<<<<<<< HEAD
                    [(UILabel*)[_scrollView viewWithTag:3] setText:[priceFormatter stringFromNumber:product.price]];
=======
                    [(UILabel*)[_scrollView viewWithTag:2] setText:[priceFormatter stringFromNumber:product.price]];
>>>>>>> localmaster
                    NSLog(@"%@",[priceFormatter stringFromNumber:product.price]);
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.r4"])
                {
<<<<<<< HEAD
                    [(UILabel*)[_scrollView viewWithTag:4] setText:[priceFormatter stringFromNumber:product.price]];
=======
                    [(UILabel*)[_scrollView viewWithTag:1] setText:[priceFormatter stringFromNumber:product.price]];
>>>>>>> localmaster
                    NSLog(@"%@",[priceFormatter stringFromNumber:product.price]);
                }
            }
            [self removeActivityView];
        }
    }];
}

-(void)addActivityView
{
    for (UIView *view in [[self navigationController]view].subviews)
    {
        if (view.tag == 383)
        {
            [view removeFromSuperview];
            break;
        }
    }
    
<<<<<<< HEAD
    
=======
    UIView *mainActionView;
>>>>>>> localmaster
    
    if (([UIApplication sharedApplication].statusBarOrientation == 3 || [UIApplication sharedApplication].statusBarOrientation == 4) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        mainActionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
    }
    else
    {
        mainActionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    }
    
    mainActionView.tag = 383;
    
    [mainActionView setBackgroundColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:0.5]];
    
    [[[self navigationController] view]addSubview:mainActionView];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [activityView startAnimating];
    
    activityView.center = mainActionView.center;
    
    [mainActionView addSubview:activityView];
}

-(void)removeActivityView
{
    for (UIView *view in [[self navigationController]view].subviews)
    {
        if (view.tag == 383)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [view removeFromSuperview];
            });
            break;
        }
    }
<<<<<<< HEAD
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mainActionView removeFromSuperview];
    });
=======
>>>>>>> localmaster
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (IBAction)supscripe:(UIButton*)sender {

<<<<<<< HEAD
    vip = true;
=======
    
>>>>>>> localmaster
    productToBuy = nil;
    retweetsNumber = (int)sender.tag;
    
    if(sender.tag == 50)
    {
       productToBuy = products[7];
<<<<<<< HEAD
    }
    ActionSheetCustomPicker* picker = [[ActionSheetCustomPicker alloc]initWithTitle:@"إختر الحساب" delegate:self showCancelButton:YES origin:sender];
    [picker.pickerView setTag:1];
    
    [picker showActionSheetPicker];
    /*    [ActionSheetCustomPicker showPickerWithTitle:@"إختر الحساب" delegate:self showCancelButton:YES origin:sender
                               initialSelections:0];*/
}
- (IBAction)oneTweetBuy:(UIButton*)sender {
   
    vip = false;
    productToBuy = nil;
    retweetsNumber = (int)sender.tag;
    if(sender.tag == 100)
    {
        productToBuy = products[8];
    }else if(sender.tag == 50)
    {
        productToBuy = products[9];
    }else if(sender.tag == 10)
=======
    }else if(sender.tag == 200)
    {
        productToBuy = products[8];
    }else if(sender.tag == 500)
    {
        productToBuy = products[9];
    }else if(sender.tag == 1500)
>>>>>>> localmaster
    {
        productToBuy = products[10];
    }
    
<<<<<<< HEAD
    ActionSheetCustomPicker* picker = [[ActionSheetCustomPicker alloc]initWithTitle:@"إختر الحساب" delegate:self showCancelButton:YES origin:sender];
    
    [picker showActionSheetPicker];
}

#pragma mark picker view delegates
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
=======
    
    [ActionSheetCustomPicker showPickerWithTitle:@"إختر الحساب" delegate:self showCancelButton:YES origin:sender
                               initialSelections:0];
}

#pragma mark picker view delegates
-(long) numberOfComponentsInPickerView:(UIPickerView *)pickerView
>>>>>>> localmaster
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedTwitterAccount = (int)row;
<<<<<<< HEAD
=======
    
>>>>>>> localmaster
}

- (void)configurePickerView:(UIPickerView *)pickerView
{
    // Override default and hide selection indicator
    pickerView.showsSelectionIndicator = YES;
}
- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
<<<<<<< HEAD
    if(vip)
    {
        [[FollowersExchangePurchase sharedInstance] buyProduct:productToBuy];
    }else
    {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"مكان التغريدة؟" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"الخط الزمني",@"المفضلة", nil];
        [sheet setTag:111];
        [sheet showFromTabBar:self.tabBarController.tabBar];
    }
=======
    [[FollowersExchangePurchase sharedInstance] buyProduct:productToBuy];
>>>>>>> localmaster
}
-(void)actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    productToBuy = nil;
}


#pragma mark - i got the event result of purchasing
- (void)productPurchased:(NSNotification *)notification {
    NSString * productIdentifier = notification.object;
    [products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم الشراء" message:@"تم الشراء شكرا لك." delegate:nil cancelButtonTitle:@"موافق" otherButtonTitles:nil];
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
<<<<<<< HEAD
            if([productIdentifier isEqualToString:@"arabdevs.followerExchange.r1"])
=======
            if([productIdentifier isEqualToString:@"arabdevs.followerExchange.r1"] || [productIdentifier isEqualToString:@"arabdevs.followerExchange.r2"] || [productIdentifier isEqualToString:@"arabdevs.followerExchange.r3"] || [productIdentifier isEqualToString:@"arabdevs.followerExchange.r4"])
>>>>>>> localmaster
            {
                [self addActivityView];
                NSString* name = [[accounts objectAtIndex:selectedTwitterAccount] username];
                NSString *post = [NSString stringWithFormat:@"name=%@&retweets=%i", name,retweetsNumber];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/makeBuyRetweets.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
<<<<<<< HEAD
                autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
=======
                NSURLConnection* autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:nil    startImmediately:YES];
>>>>>>> localmaster
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];
                *stop = YES;
<<<<<<< HEAD
                OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"شكرا" message:@"سوف تتمتع كل تغريداتك بالعدد المطلوب للريتويت و التفضيل من الآن" timeout:5 dismissible:YES];
=======
                OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"شكرا" message:@"سوف تتمتع كل تغريداتك بالعدد المطلوب للريتويت و التفضيل لشهر من الآن" timeout:5 dismissible:YES];
>>>>>>> localmaster
                [alert show];
            }
            *stop = YES;
            [alert show];
        }
    }];
}

- (void)productCanceled:(NSNotification *)notification
{
    productToBuy = nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self removeActivityView];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString* string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
<<<<<<< HEAD
    if(connection != autoFollowConnection && [string intValue] == 1)
    {
        [self.label1 setText:[self.label1.text stringByAppendingString:@"  ولمدة شهر كامل قابل للتجديد"]];
    }else if(connection == autoFollowConnection)
    {
        NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 111)
    {
        if(buttonIndex != actionSheet.cancelButtonIndex)
        {
            if(buttonIndex == 0)
            {
                twitterAPI = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
            }else if(buttonIndex == 1)
            {
                twitterAPI = @"https://api.twitter.com/1.1/favorites/list.json";
            }
            [self performSegueWithIdentifier:@"tweetChooseSeg" sender:self];
        }
=======
    if([string intValue] == 0)
    {
        [self.label1 setText:[self.label1.text stringByReplacingOccurrencesOfString:@"لمدة شهر كامل قابل للتجديد" withString:@""]];
        [self.label2 setText:[self.label1.text stringByReplacingOccurrencesOfString:@"لمدة شهر كامل قابل للتجديد" withString:@""]];
        [self.label3 setText:[self.label1.text stringByReplacingOccurrencesOfString:@"لمدة شهر كامل قابل للتجديد" withString:@""]];
        [self.label4 setText:[self.label1.text stringByReplacingOccurrencesOfString:@"لمدة شهر كامل قابل للتجديد" withString:@""]];
>>>>>>> localmaster
    }
}


@end
