//
//  AppDelegate.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "AppDelegate.h"
#import "UICKeyChainStore.h"
#import <Parse/Parse.h>

@implementation AppDelegate

#pragma mark -
#pragma mark Application lifecycle
#import "UICKeyChainStore.h"

@synthesize accounts,accountStore;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if([currSysVer hasPrefix:@"8"])
    {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    
    
    
    [Parse setApplicationId:@"ojqQ50svocjMWSOz1b6aKr5PNzWDEwgobJlyXQ5e"
                  clientKey:@"cZ20D9JdmdTd5IrnlrMtqhZdaK9VUEVLcvtGf7Tq"];
    
    [self buyFollow];
    [self getAds];
    
    
   UICKeyChainStore* store = [UICKeyChainStore keyChainStore];

    @try
    {
        if(![store stringForKey:@"la7zyPoints"])
        {
            [store setString:@"100" forKey:@"la7zyPoints"];
            [store synchronize];
        }
    } @catch (NSException *exception) {
        [store setString:@"100" forKey:@"la7zyPoints"];
        [store synchronize];
    }
    
    return YES;
}

-(void)buyFollow
{
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
    
}

-(void)getAds
{
    NSString *post = @"";
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/getAds.php"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    self.adsConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [self.adsConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                  forMode:NSDefaultRunLoopMode];
    [self.adsConnection start];
    
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //NSLog(@"My token is: %@", deviceToken);
    NSMutableString *string = [[NSMutableString alloc]init];
    int length = (int)[deviceToken length];
    char const *bytes = [deviceToken bytes];
    for (int i=0; i< length; i++) {
        [string appendString:[NSString stringWithFormat:@"%02.2hhx",bytes[i]]];
    }
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:string forKey:@"deviceToken"];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    [PFPush handlePush:userInfo];
}
#endif

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    //NSLog(@"فشل في الحصول على رمز، الخطأ: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection == self.buyFollowerConnection)
    {
        NSString* response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [[NSUserDefaults standardUserDefaults]setObject:response forKey:@"buyFollow"];
        [FollowersExchangePurchase sharedInstance];
    }else if(connection == self.adsConnection)
    {
        NSString* response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [[NSUserDefaults standardUserDefaults]setObject:response forKey:@"ads"];
    }    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
