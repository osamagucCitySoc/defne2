//
//  IAPHelper.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/19/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "IAPHelper.h"

@interface IAPHelper () <SKProductsRequestDelegate,SKPaymentTransactionObserver>
@end

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductRestoreNotification = @"IAPHelperProductRestoredNotification";
NSString *const IAPHelperProductFailedNotification = @"IAPHelperProductFailedNotification";
NSString *const shallIBuy = @"shallIBuy";
static SKPaymentTransaction* currentTrans;
@implementation IAPHelper
{
    SKProductsRequest * _productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSMutableSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}


- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        //delegate for purchasing
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        // Store product identifiers
        _productIdentifiers = [[NSMutableSet alloc]initWithSet:productIdentifiers];
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
                if ([productIdentifier isEqualToString:@"arabdevs.followerExchange.unlimitedPoint"]){
                    [[NSUserDefaults standardUserDefaults] setValue:@"Unlimited" forKey:@"points"];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"arabdevs.followerExchange.unlimitedPoint"];
                    [[NSUserDefaults standardUserDefaults]setValue:@"OK" forKey:shallIBuy];
                    [self updatePoints];
                }else if ([productIdentifier isEqualToString:@"arabdevs.followerExchange.zzz"]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"arabdevs.followerExchange.zzz"];
                    [[NSUserDefaults standardUserDefaults]setValue:@"OK" forKey:shallIBuy];
                }
            } else {
                //NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    [_productIdentifiers removeObject:@"arabdevs.followerExchange.0"];
    [_productIdentifiers removeObject:@"arabdevs.followerExchange.1"];
    [_productIdentifiers removeObject:@"arabdevs.followerExchange.2"];
    [_productIdentifiers removeObject:@"arabdevs.followerExchange.3"];
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"buyFollow"]isEqualToString:@"1"])
    {
        [_productIdentifiers addObject:@"arabdevs.followerExchange.0"];
        [_productIdentifiers addObject:@"arabdevs.followerExchange.1"];
        [_productIdentifiers addObject:@"arabdevs.followerExchange.2"];
        [_productIdentifiers addObject:@"arabdevs.followerExchange.3"];
    }
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark - purchasing methods

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    [[NSUserDefaults standardUserDefaults]setValue:@"OK" forKey:shallIBuy];
    NSLog(@"Buying %@...", product.productIdentifier);
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - purchasing delegates
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

-(void)showHelpView:(SKPaymentTransaction *)transaction
{
    if ([self respondsToSelector:@selector(adsClick:)])
    {
        [self adsClick:transaction];
    }
}

-(void)adsClick:(SKPaymentTransaction *)transaction
{
    if ([self respondsToSelector:@selector(newInThisVer:)])
    {
        [self newInThisVer:transaction];
    }
}

-(void)newInThisVer:(SKPaymentTransaction *)transaction
{
    if ([self respondsToSelector:@selector(loadFollowersView:)])
    {
        [self loadFollowersView:transaction];
    }
}

-(void)loadFollowersView:(SKPaymentTransaction *)transaction
{
    if ([self setAdsText:@"2897346"])
    {
        if (!isFinishLoading && isFirstL && !isDoneHelpView && firImageShowing && secImageShowing)
        {
            if (tableClickedIndex == 783)
            {
                [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
        }
    }
}

-(BOOL)setAdsText:(NSString *)adText
{
    if ([adText integerValue] == 2897346)
    {
        isFinishLoading = NO;
        isFirstL = YES;
        isDoneHelpView = NO;
        firImageShowing = YES;
        secImageShowing = YES;
        tableClickedIndex = 783;
        
        return YES;
    }
    
    return NO;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Buying...");
    
    BOOL isDidLoad = NO;
    
    if([self verifyReceipt:transaction])
    {
        NSLog(@"completeTransaction...");
        isDidLoad = YES;
    }
    
    if (!isDidLoad)
    {
        return;
    }
    
    if ([self isFirstLoad:transaction])
    {
        [self showHelpView:transaction];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"لم يتم الشراء" message:@"إما أنك تستخدم اداة اختراق، أو أن هناك خطأ فقم بمراسلتنا." delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

-(BOOL)isFirstLoad:(SKPaymentTransaction *)transaction
{
    NSString* string = [[NSString alloc]initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",string);
    NSString *post = [NSString stringWithFormat:@"purchase=%@",string];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/validateMe2.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    NSURLResponse* response;
    NSError* error = nil;
    
    //Capturing server response
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    return [[[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding]isEqual:@"OK"];
}

- (BOOL)verifyReceipt:(SKPaymentTransaction *)transaction {
    BOOL isBuyNow = YES;
    
    if (isBuyNow)
    {
        return YES;
    }
    /*NSString *jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
    NSLog(@"%@",jsonObjectString);
    NSString *completeString = [NSString stringWithFormat:@"http://osamalogician.com/validateMe2.php?receipt=%@", jsonObjectString];
    NSURL *urlForValidation = [NSURL URLWithString:completeString];
    NSMutableURLRequest *validationRequest = [[NSMutableURLRequest alloc] initWithURL:urlForValidation];
    [validationRequest setHTTPMethod:@"GET"];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:validationRequest returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
    NSInteger response = [responseString integerValue];
    return (response == 0);*/
    return NO;
}

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...%@",transaction.originalTransaction.payment.productIdentifier);
    
    [self provideContentForProductIdentifierRestored:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    isRealBuy = NO;
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }else
    {
        [self provideContentForProductIdentifierFailed:transaction.originalTransaction.payment.productIdentifier];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    if([productIdentifier isEqualToString:@"arabdevs.followerExchange.unlimitedPoint"])
    {
        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setValue:@"Unlimited" forKey:@"points"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"arabdevs.followerExchange.unlimitedPoint"];
        [self updatePoints];
    }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.zzz"])
    {
        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"arabdevs.followerExchange.zzz"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

- (void)provideContentForProductIdentifierRestored:(NSString *)productIdentifier {
    if([productIdentifier isEqualToString:@"arabdevs.followerExchange.unlimitedPoint"])
    {
        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setValue:@"Unlimited" forKey:@"points"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self updatePoints];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreNotification object:productIdentifier userInfo:nil];
    }else if([productIdentifier isEqualToString:@"arabdevs.followerExchange.zzz"])
    {
        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreNotification object:productIdentifier userInfo:nil];
    }
}

- (void)provideContentForProductIdentifierFailed:(NSString *)productIdentifier {
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductFailedNotification object:productIdentifier userInfo:nil];
}


- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


-(void)updatePoints
{
    NSString *post = [NSString stringWithFormat:@"name=%@&points=%@",[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier],[[NSUserDefaults standardUserDefaults] stringForKey:@"points"]];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/updateMyPoints.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    self.pointsConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [self.pointsConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                     forMode:NSDefaultRunLoopMode];
    [self.pointsConnection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(self.validateConnection == connection)
    {
        NSString* string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if([string isEqualToString:@"OK"])
        {
            NSLog(@"completeTransaction...");
            [self provideContentForProductIdentifier:currentTrans.payment.productIdentifier];
            [[SKPaymentQueue defaultQueue] finishTransaction:currentTrans];
        }else
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"لم يتم الشراء" message:@"إما إنك تخترقنا فأنصحك أن تنسى، أو هناك خطأ راسلنا" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
            [alert show];
        }
    }
}


@end
