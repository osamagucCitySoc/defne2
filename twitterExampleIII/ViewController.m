//
//  ViewController.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/12/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


@synthesize oauthToken,oauthTokenSecret,accounts,accountStore,apiManager,accountIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self reverseOauth];
    
}

#pragma Here we do the reverse oauth to get secret and access tokens for the selected twitter account
-(void)reverseOauth
{
    accountStore = [[ACAccountStore alloc] init];
    apiManager = [[TWAPIManager alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            accounts = [accountStore accountsWithAccountType:accountType];
            
            [apiManager
             performReverseAuthForAccount:[accounts objectAtIndex:accountIndex]
             withHandler:^(NSData *responseData, NSError *error) {
                 if (responseData) {
                     NSString *responseStr = [[NSString alloc]
                                              initWithData:responseData
                                              encoding:NSUTF8StringEncoding];
                     
                     NSArray *parts = [responseStr
                                       componentsSeparatedByString:@"&"];
                     
                     // Get oauth_token
                     NSString *oauth_tokenKV = [parts objectAtIndex:0];
                     NSArray *oauth_tokenArray = [oauth_tokenKV componentsSeparatedByString:@"="];
                     oauthToken = [oauth_tokenArray objectAtIndex:1];
                     
                     // Get oauth_token_secret
                     NSString *oauth_token_secretKV = [parts objectAtIndex:1];
                     NSArray *oauth_token_secretArray = [oauth_token_secretKV componentsSeparatedByString:@"="];
                     oauthTokenSecret = [oauth_token_secretArray objectAtIndex:1];
                     [self doThePost];
                 }else {
                     NSLog(@"Error!\n%@", [error localizedDescription]);
                 }
             }];
        }else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"No Accounts"
                                  message:@"Please configure a Twitter "
                                  "account in Settings.app"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

#pragma Here we submit the information of the user to the server
-(void)doThePost
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
    NSDictionary *params = @{@"screen_name" : [[accounts objectAtIndex:accountIndex]username]};

    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    
    [request setAccount:[accounts objectAtIndex:accountIndex]];
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
                

                NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
            
                NSString *name = [[accounts objectAtIndex:accountIndex]username];
                NSString *deviceToken = [standardUserDefaults stringForKey:@"deviceToken"];
                NSString* image = [json objectForKey:@"profile_image_url"];
                
                NSString *post = [NSString stringWithFormat:@"name=%@&image=%@&deviceToken=%@&twitterAccessToken=%@&twitterAccessSecretToken=%@", name,image,deviceToken,oauthToken,oauthTokenSecret];
                
                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                NSString *postLength = [NSString stringWithFormat:@"%d", [post length]];
                
                NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/FollowersExchange/storeInformation.php"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                [request setHTTPMethod:@"POST"];
                NSLog(@"%@", post);
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                [NSURLConnection connectionWithRequest:request delegate:nil];
            }
        }
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
