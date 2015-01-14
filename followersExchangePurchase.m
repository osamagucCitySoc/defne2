//
//  FollowersExchangePurchase.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/19/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "FollowersExchangePurchase.h"

@implementation FollowersExchangePurchase


+ (FollowersExchangePurchase *)sharedInstance {
    static dispatch_once_t once;
    static FollowersExchangePurchase * sharedInstance;

    dispatch_once(&once, ^{
        NSMutableSet * productIdentifiers;
        /*if([[NSUserDefaults standardUserDefaults]boolForKey:@"arabdevs.followerExchange.unlimitedPoint"]) {
            productIdentifiers = [NSMutableSet setWithObjects:
                                  @"arabdevs.followerExchange.00",
                                      @"arabdevs.followerExchange.zz5",
                                  @"arabdevs.followerExchange.zzz",
                                  @"arabdevs.followerExchange.autoFollow",
                                  @"arabdevs.followerExchange.zzNoFollowBack",
                                  @"arabdevs.followerExchange.autoFollowZ",
                                  nil];
        }else
        {
            productIdentifiers = [NSMutableSet setWithObjects:
                                  @"arabdevs.followerExchange.00",
                                          @"arabdevs.followerExchange.hundredPoint",
                                          @"arabdevs.followerExchange.hundredZFiftyPoint",
                                          @"arabdevs.followerExchange.hundredZZFiftyPoint",
                                          @"arabdevs.followerExchange.zz5",
                                  @"arabdevs.followerExchange.zzz",
                                  @"arabdevs.followerExchange.autoFollow",
                                  @"arabdevs.followerExchange.zzNoFollowBack",
                                  @"arabdevs.followerExchange.autoFollowZ",
                                  nil];
        }*/
        
        productIdentifiers = [NSMutableSet setWithObjects:
                              @"arabdevs.followerExchange.00",
                              @"arabdevs.followerExchange.zzNoFollowBack",
                              @"arabdevs.followerExchange.autoFollowZ",
                              @"arabdevs.followerExchange.hundredPoint",
                              @"arabdevs.followerExchange.r1",
                              @"arabdevs.followerExchange.r2",
                              @"arabdevs.followerExchange.r3",
                              @"arabdevs.followerExchange.r4",
                              nil];
        
        /*if([[NSUserDefaults standardUserDefaults]boolForKey:@"arabdevs.followerExchange.zzz"])
        {
            [productIdentifiers removeObject:@"arabdevs.followerExchange.zzz"];
        }*/
        
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"buyFollow"]isEqualToString:@"1"])
        {
            [productIdentifiers addObject:@"arabdevs.followerExchange.0"];
            [productIdentifiers addObject:@"arabdevs.followerExchange.1"];
            [productIdentifiers addObject:@"arabdevs.followerExchange.2"];
            [productIdentifiers addObject:@"arabdevs.followerExchange.3"];
        }
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}



@end
