//
//  AboutViewController.m
//  twitterExampleIII
//
//  Created by Housein Jouhar on 6/15/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "InAppController.h"
#import "ChooseAccountViewController.h"
#import "IAPHelper.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "ActionSheetPicker.h"
#import "UICKeyChainStore.h"

@interface InAppController ()<ActionSheetCustomPickerDelegate>
@property (strong, nonatomic) NSMutableArray* accounts;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (weak, nonatomic) IBOutlet UILabel *fakeDescLabel;

@end

@implementation InAppController
{
    int selectedTwitterAccount;
    SKProduct *productToBuy;
}

@synthesize accounts,accountStore,products;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"ads"] isEqualToString:@"0"])
    {
        [self.fakeDescLabel setText:@"الفولو الماسي هو أقوى مزايا التطبيق وأكثرها كسباً للمتابعين، فهو يجمع بين الفولو التلقائي والفولو اللحظي كما أن المشترك بهذه الميزة سيظهر حسابه دائماً في مقدمة الحسابات بحيث تكون له الأولوية المطلقة في المتابعة،أقل عدد متابعين ممكن كسبه هو ٤٠٠٠ متابع كحد أدنى وممكن أن تصل لأكثر بكثير من ١٠ الاف متابع ."];
    }else
    {
        [self.fakeDescLabel setText:@"الفولو الماسي هو أقوى مزايا التطبيق وأكثرها كسباً للمتابعين، فهو يجمع بين الفولو التلقائي والفولو اللحظي كما أن المشترك بهذه الميزة سيظهر حسابه دائماً في مقدمة الحسابات بحيث تكون له الأولوية المطلقة في المتابعة، الاشتراك مدته ١٤ يوماً ويلزم تجديد الإشتراك بعد ذلك، وأقل عدد متابعين ممكن كسبه هو ٥٠٠٠ متابع كحد أدنى وممكن أن تصل لأكثر بكثير من ١٠ الاف متابع حقيقي خلال مدة الإشتراك. مع ميزه عدم فولو باك التي تتيح أم تضغط تابع و الناس تتابعك من دون أن تتابعهم."];
    }
    [_allScrollView setContentSize:CGSizeMake(_allScrollView.frame.size.width, 2176)];
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
               // NSLog(@"Identifier: %@ and Price: %@",[product productIdentifier],[priceFormatter stringFromNumber:product.price]);
                
                if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.00"])
                {
                    [(UILabel*)[_allScrollView viewWithTag:7] setText:[priceFormatter stringFromNumber:product.price]];
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.autoFollowZ"])
                {
                    [(UILabel*)[_allScrollView viewWithTag:8] setText:[priceFormatter stringFromNumber:product.price]];
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.3"])
                {
                    [(UILabel*)[_allScrollView viewWithTag:9] setText:[priceFormatter stringFromNumber:product.price]];
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.2"])
                {
                    [(UILabel*)[_allScrollView viewWithTag:10] setText:[priceFormatter stringFromNumber:product.price]];
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.1"])
                {
                    [(UILabel*)[_allScrollView viewWithTag:11] setText:[priceFormatter stringFromNumber:product.price]];
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.0"])
                {
                    [(UILabel*)[_allScrollView viewWithTag:12] setText:[priceFormatter stringFromNumber:product.price]];
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.zzNoFollowBack"])
                {
                   // NSLog(@"%i",i);
                    [(UILabel*)[_allScrollView viewWithTag:13] setText:[priceFormatter stringFromNumber:product.price]];
                }
                else if ([[product productIdentifier] isEqualToString:@"arabdevs.followerExchange.hundredPoint"])
                {
                    [(UILabel*)[_allScrollView viewWithTag:16] setText:[priceFormatter stringFromNumber:product.price]];
                }
            }
            
            [self removeActivityView];
        }
    }];
}

- (IBAction)buyNow:(id)sender {
    if ([sender tag] == 1)
    {
        productToBuy = products[1];
    }
    else if ([sender tag] == 2)
    {
        productToBuy = products[5];
    }
    else if ([sender tag] == 3)
    {
        productToBuy = products[4];
    }
    else if ([sender tag] == 4)
    {
        productToBuy = products[3];
    }
    else if ([sender tag] == 5)
    {
        productToBuy = products[2];
    }
    else if ([sender tag] == 6)
    {
        productToBuy = products[0];
    }
    else if ([sender tag] == 14)
    {
        productToBuy = products[11];
    }
    else if ([sender tag] == 15)
    {
        productToBuy = products[6];
    }
    else
    {
        productToBuy = nil;
    }
    
    if(productToBuy)
    {
        if([sender tag] != 15)
        {
            [ActionSheetCustomPicker showPickerWithTitle:@"إختر الحساب" delegate:self showCancelButton:YES origin:sender
                                   initialSelections:0];
        }else
        {
            [[FollowersExchangePurchase sharedInstance] buyProduct:productToBuy];
        }
    }
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
    
    UIView *mainActionView;
    
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
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - i got the event result of purchasing
- (void)productPurchased:(NSNotification *)notification {
    NSString * productIdentifier = notification.object;
    [products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم الشراء" message:@"تم الشراء شكرا لك." delegate:nil cancelButtonTitle:@"موافق" otherButtonTitles:nil];
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            if([productIdentifier isEqualToString:@"arabdevs.followerExchange.0"])
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
                
                NSURLConnection* autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:nil    startImmediately:YES];
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                     forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];
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
                NSURLConnection* autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:nil    startImmediately:YES];
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];;
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
                NSURLConnection* autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:nil    startImmediately:YES];
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];
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
                NSURLConnection* autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:nil    startImmediately:YES];
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];
                *stop = YES;
                OLGhostAlertView* alert = [[OLGhostAlertView alloc]initWithTitle:@"شكرا" message:@"ستتم الإضافة خلال يومين" timeout:5 dismissible:YES];
                [alert show];
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
                
                NSURLConnection* autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:nil    startImmediately:YES];
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];
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
            
                NSURLConnection* autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:nil    startImmediately:YES];
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];
                
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
                
                NSURLConnection* autoFollowConnection  = [[NSURLConnection alloc]initWithRequest:request delegate:nil    startImmediately:YES];
                
                [autoFollowConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                forMode:NSDefaultRunLoopMode];
                [autoFollowConnection start];
                
                *stop = YES;
            }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.hundredPoint"])
            {
                UICKeyChainStore* storee = [UICKeyChainStore keyChainStore];
                int points = [[storee stringForKey:@"la7zyPoints"] intValue];
                points += 100;
                @try
                {
                    [storee setString:[NSString stringWithFormat:@"%i",points] forKey:@"la7zyPoints"];
                    [storee synchronize];
                    
                } @catch (NSException *exception) {
                    [storee setString:[NSString stringWithFormat:@"%i",points]  forKey:@"la7zyPoints"];
                    [storee synchronize];
                }

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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedTwitterAccount = row;
    
}

- (void)configurePickerView:(UIPickerView *)pickerView
{
    // Override default and hide selection indicator
    pickerView.showsSelectionIndicator = YES;
}
- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    [[FollowersExchangePurchase sharedInstance] buyProduct:productToBuy];
}
-(void)actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    productToBuy = nil;
}


@end
