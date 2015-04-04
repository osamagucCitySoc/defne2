//
//  IAPHelper.h
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/19/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "UIDevice+IdentifierAddition.h"
#import "NSData+Base64.h"
#import "iAPVerification.h"
#import "ChooseAccountViewController.h"

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductRestoreNotification;
UIKIT_EXTERN NSString *const IAPHelperProductFailedNotification;
UIKIT_EXTERN NSString *const shallIBuy;
BOOL isRealBuy;
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject<iAPVerificationDelegate>


@property(strong, nonatomic) NSURLConnection* pointsConnection;
@property(strong, nonatomic) NSURLConnection* validateConnection;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
@end
