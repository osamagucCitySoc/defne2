//
//  AboutViewController.m
//  twitterExampleIII
//
//  Created by Housein Jouhar on 6/15/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "AboutViewController.h"
#import "ChooseAccountViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)goToSite:(id)sender {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.arabdevs.com/"]];
}

- (IBAction)closeAbout:(id)sender {
    isCloseAbout = YES;
}

- (IBAction)goToApps:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.arabdevs.com/apps.html"]];
}

- (IBAction)followUs:(id)sender {
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
    {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                NSArray* accounts = [accountStore accountsWithAccountType:accountType];
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"ArabDevs", @"true", nil] forKeys:[NSArray arrayWithObjects:@"screen_name", @"follow", nil]]];
                if([accounts count]>0)
                {
                    [request setAccount:[accounts objectAtIndex:0]];
                    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        if(responseData) {
                            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
                            if(responseDictionary) {
                                // Probably everything gone fine
                                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"شكرا" message:@"تمت المتابعة بنجاح" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
                                [alert show];
                            }
                        } else {
                            // responseDictionary is nil
                        }
                    }];
                }
            }
        }];
    }else if([[[UIDevice currentDevice] systemVersion] floatValue]>=6 && [[[UIDevice currentDevice] systemVersion] floatValue]<7)
    {
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                NSArray* accounts = [accountStore accountsWithAccountType:accountType];
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"ArabDevs", @"true", nil] forKeys:[NSArray arrayWithObjects:@"screen_name", @"follow", nil]]];
                if([accounts count]>0)
                {
                    [request setAccount:[accounts objectAtIndex:0]];
                    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        if(responseData) {
                            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
                            if(responseDictionary) {
                                // Probably everything gone fine
                                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"شكرا" message:@"تمت المتابعة بنجاح" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
                                [alert show];
                            }
                        } else {
                            // responseDictionary is nil
                        }
                    }];
                }
            }
        }];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    screenBound = [[UIScreen mainScreen] bounds];
    screenSize = screenBound.size;
    screenHeight = screenSize.height;
    
    float appVer = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    
    _verLabel.text = [@"الإصدار:" stringByAppendingFormat:@" %.1f",appVer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"YYYY"];
    
    _rightsLabel.text = [@"  جميع الحقوق محفوظة للمطورين العرب " stringByAppendingFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
    // Do any additional setup after loading the view from its nib.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
