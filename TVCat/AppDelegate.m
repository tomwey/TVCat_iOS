//
//  AppDelegate.m
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "AppDelegate.h"
#import "Defines.h"
//#import "GuideVC.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface AppDelegate () <UITabBarControllerDelegate>

@property (nonatomic, strong) UITabBarController *appTabBarController;

@end

@implementation AppDelegate

@synthesize appRootController = _appRootController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [APIServiceConfig defaultConfig].apiServer = API_HOST;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:MAIN_THEME_COLOR];
//    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: MAIN_THEME_COLOR } forState:UIControlStateSelected];
    
    BOOL canShow = NO;//[GuideVC canShowGuide];
    
    [self showGuide:canShow];
    
    [self.window makeKeyAndVisible];
    
    if ( !canShow ) {
//        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loadUnreadMessage2)
//                                                 name:@"kNeedLoadUnreadCountNotification"
//                                               object:nil];
//
//    [self loadUnreadMessage:YES];
    
//    NSLog(@"%@, %@", [self AESEncryptStringByString:@"loginname=huyue&pwd=123321"], [@"666AA4DF3533497D973D852004B975BC" md5Hash]);
    
//    [[CatService sharedInstance] fetchAppConfig:^(id result, NSError *error) {
//
//    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[CatService sharedInstance] sessionBeginForType:1 completion:^(id result, NSError *error) {
            [[VersionCheckService sharedInstance] startCheckWithSilent:YES];
        }];
    });
    
    return YES;
}

- (NSString *)AESEncryptStringByString:(NSString *)string
{
    NSString *defaultKey = @"666AA4DF3533497D973D852004B975BC";
    size_t bytesEncrypted = 0;
    //#define BUFFSIZE 8192
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    char* buffer = malloc(bufferSize);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(defaultKey.UTF8String, (CC_LONG)strlen(defaultKey.UTF8String), digest);
    
    CCCryptorStatus ret = CCCrypt(kCCEncrypt,
                                  kCCAlgorithmAES128,
                                  kCCOptionPKCS7Padding | kCCOptionECBMode,
                                  digest,
                                  kCCKeySizeAES128,
                                  NULL,
                                  data.bytes,
                                  data.length,
                                  buffer, bufferSize,
                                  &bytesEncrypted);
    if (ret != kCCSuccess) {
        free(buffer);
        return nil;
    }
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:bytesEncrypted];
    for(int i=0;i<bytesEncrypted;i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%02x",buffer[i]&0xff];///16进制数
        [result appendString:newHexStr];
    }
    
    free(buffer); buffer = NULL;
    NSLog(@"REsult : [%@]", result);
    return result;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [self loadUnreadMessage:YES];
//    [[CatService sharedInstance] fetchAppConfig:^(id result, NSError *error) {
//
//    }];
    
    [[CatService sharedInstance] sessionBeginForType:2 completion:^(id result, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[CatService sharedInstance] sessionEnd:^(BOOL succeed, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)loadUnreadMessage2
{
    [self loadUnreadMessage:NO];
}

- (void)loadUnreadMessage:(BOOL)loadMessage
{
    id userInfo = [[UserService sharedInstance] currentUser];
    
    if (!userInfo) {
        return;
    }
    
//    __weak typeof(self) me = self;
//    [[self apiServiceWithName:@"APIService"]
//     POST:nil
//     params:@{
//              @"dotype": @"GetData",
//              @"funname": @"供应商获取未读消息数APP",
//              @"param1": [userInfo[@"supid"] ?: @"0" description],
//              @"param2": userInfo[@"loginname"] ?: @"",
//              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
//              } completion:^(id result, NSError *error) {
//                  [me handleResult:result error:error loadMessage:loadMessage];
//              }];
}

- (void)handleResult:(id)result error:(NSError *)error loadMessage:(BOOL)yesOrNo
{
    if ( !error && [result[@"rowcount"] integerValue] > 0 ) {
        id item = [result[@"data"] firstObject];
        
        NSInteger count = [item[@"unreadmsgnum"] integerValue];
        
        if (count > 0) {
            if (yesOrNo) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kHasNewMessageNotification"
                                                                    object:nil
                                                                  userInfo:nil];
            }
            
            if (self.appTabBarController.viewControllers.count > 1) {
                UIViewController *vc = self.appTabBarController.viewControllers[1];
                
                vc.tabBarItem.badgeValue = [@(count) description];
            }
        }
    }
}

- (void)showGuide:(BOOL)yesOrNo
{
    if ( yesOrNo ) {
//        GuideVC *guideVC = [[GuideVC alloc] init];
//        self.window.rootViewController = guideVC;
    } else {
        UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:self.appRootController];
        nav.navigationBarHidden = YES;
        
        self.window.rootViewController = nav;
    }
}

- (UIViewController *)rootVC
{
    UIViewController *rootVC = nil;
    
    id currentUser = [[UserService sharedInstance] currentUser];
    if (currentUser) {
        BOOL hasChangedPwd = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasChangedPWD"];
        if (hasChangedPwd || [[NSUserDefaults standardUserDefaults] boolForKey:@"validLogin"]) {
            rootVC = self.appRootController;
        } else {
            rootVC = [[NSClassFromString(@"ResetPasswordVC") alloc] init];
        }
    } else {
        rootVC = [[NSClassFromString(@"LoginVC") alloc] init];
    }
    return rootVC;
}

- (UIViewController *)appRootController
{
    if ( !self.appTabBarController ) {
        self.appTabBarController = [[UITabBarController alloc] init];
        self.appTabBarController.delegate = self;
        
        UIViewController *workVC = [UIViewController createControllerWithName:@"HomeVC"];
//        UIViewController *oaVC = [UIViewController createControllerWithName:@"OAListVC"];
        UIViewController *messageVC = [UIViewController createControllerWithName:@"ExploreVC"];
//        UIViewController *contactsVC = [UIViewController createControllerWithName:@"ContactVC"];
        UIViewController *settingVC = [UIViewController createControllerWithName:@"SettingVC"];
        
        self.appTabBarController.viewControllers = @[workVC, messageVC, settingVC];
        
        self.appTabBarController.selectedIndex = 0;
    }
    
    return self.appTabBarController;
}

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//    [HNNewFlowCountService sharedInstance].canFetch = self.appTabBarController.selectedIndex != 1;
//}

- (void)resetRootController
{
    self.appTabBarController = nil;
}

@end

@implementation UIWindow (NavBar)

- (UINavigationController *)navController
{
    return (UINavigationController *)self.rootViewController;
}

@end
