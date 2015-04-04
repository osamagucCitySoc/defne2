//
//  FollowersExchangePurchase.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/19/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "FollowersExchangePurchaseTwo.h"

@implementation FollowersExchangePurchaseTwo


+ (FollowersExchangePurchaseTwo *)sharedInstance {
    static dispatch_once_t once;
    static FollowersExchangePurchaseTwo * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"arabdevs.followerExchange.zspecial",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}



@end
