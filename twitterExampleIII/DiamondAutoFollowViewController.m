//
//  DiamondAutoFollowViewController.m
//  twitterExampleIII
//
//  Created by OsamaMac on 8/10/14.
//  Copyright (c) 2014 MacBook. All rights reserved.
//

#import "DiamondAutoFollowViewController.h"

@interface DiamondAutoFollowViewController ()
@property (weak, nonatomic) IBOutlet UITextView *fakeDescLabel;

@end

@implementation DiamondAutoFollowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"ads"] isEqualToString:@"0"])
    {
        [self.fakeDescLabel setText:@"الفولو الماسي هو أقوى مزايا التطبيق وأكثرها كسباً للمتابعين، فهو يجمع بين الفولو التلقائي والفولو اللحظي كما أن المشترك بهذه الميزة سيظهر حسابه دائماً في مقدمة الحسابات بحيث تكون له الأولوية المطلقة في المتابعة،أقل عدد متابعين ممكن كسبه هو ٤٠٠٠ متابع كحد أدنى وممكن أن تصل لأكثر بكثير من ١٠ الاف متابع ."];
    }else
    {
        [self.fakeDescLabel setText:@"الفولو الماسي هو أقوى مزايا التطبيق وأكثرها كسباً للمتابعين، فهو يجمع بين الفولو التلقائي والفولو اللحظي كما أن المشترك بهذه الميزة سيظهر حسابه دائماً في مقدمة الحسابات بحيث تكون له الأولوية المطلقة في المتابعة، الاشتراك مدته ١٤ يوماً ويلزم تجديد الإشتراك بعد ذلك، وأقل عدد متابعين ممكن كسبه هو ٥٠٠٠ متابع كحد أدنى وممكن أن تصل لأكثر بكثير من ١٠ الاف متابع حقيقي خلال مدة الإشتراك (١٤ يوماً)."];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
