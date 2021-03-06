//
//  VersionCheckerService.m
//  RTA
//
//  Created by tangwei1 on 16/10/26.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "VersionCheckService.h"
#import "Defines.h"

#import "UIView+TYAlertView.h"
// if you want blur efffect contain this
#import "TYAlertController+BlurEffects.h"

#import "UIApplication+Close.h"

@interface TYAlertController (HideStatusBar)

@end

@interface VersionCheckService ()

@property (nonatomic, assign) BOOL checking;

@property (nonatomic, strong, readwrite) id appInfo;

@property (nonatomic, assign) BOOL silent;

@end

@implementation VersionCheckService

+ (instancetype)sharedInstance
{
    static VersionCheckService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( !instance ) {
            instance = [[VersionCheckService alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(startCheck)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
        }
    });
    return instance;
}

- (void)startCheck
{
    [self startCheckWithSilent:YES];
}

- (void)startCheckWithSilent:(BOOL)isSilent
{
    if ( self.checking ) {
        return;
    }
    
    self.checking = YES;
    
    self.silent = isSilent;
    
    if ( !isSilent ) {
        [HNProgressHUDHelper showHUDAddedTo:AWAppWindow() animated:YES];
    }
    
    VersionCheckService * __weak weakSelf = self;
    
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        NSString *token = user[@"token"] ?: @"";
        
        [[self apiServiceWithName:@"APIService"]
         GET:@"app/check_version"
         params:@{
                  @"token": token,
                  @"bv": AWAppVersion(),
                  @"m": AWDeviceName(),
                  @"os": @"iOS",
                  @"osv": AWOSVersionString(),
                  }
         completion:^(id result, id rawData, NSError *error) {
             [self handleResult:result rawData:rawData error:error];
         }];
        
    }];
}

- (void)handleResult:(id)result rawData:(id)rawData error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:AWAppWindow() animated:YES];
    
    if ( !error ) {
//        self.appInfo = result;
//        if ( [result[@"rowcount"] integerValue] == 0 ) {
//            if ( !self.silent ) {
//                [AWAppWindow() showHUDWithText:@"已经是最新版本" offset:CGPointMake(0,20)];
//            }
//
//            self.checking = NO;
//        } else {
            self.appInfo = result;//[result[@"data"] firstObject];
            
            [self showVersionTips];
//        }
        
        
//        [self checkVersion];
    } else {
        self.checking = NO;
        
        if ( [rawData[@"code"] integerValue] == 4004 ) {
            if ( !self.silent ) {
                [AWAppWindow() showHUDWithText:@"已经是最新版本" offset:CGPointMake(0,20)];
            }
        } else {
            if ( !self.silent ) {
                [AWAppWindow() showHUDWithText:error.domain succeed:NO];
            } else {
                
            }
        }
    }
}

- (void)showVersionTips
{
    NSString *title = [self.appInfo[@"version_desc"] description];
    if ( title.length == 0 || [title isEqualToString:@"NULL"] ) {
        title = @"有新版本可用";
    }
    NSString *msg = [self.appInfo[@"changelog"] componentsJoinedByString:@"\n"];
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:title
                                                     message:msg];
    
    alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
//    alertView.contentViewSpace = 30;
    alertView.textLabelSpace   = 20;
    alertView.textLabelContentViewEdge = 35;
    
    if ( ![self.appInfo[@"must_update"] boolValue] ) {
        [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancel handler:^(TYAlertAction *action) {
            NSLog(@"%@",action.title);
            self.checking = NO;
        }]];
    }
    
    alertView.buttonDestructiveBgColor = MAIN_THEME_COLOR;
    
    [alertView addAction:[TYAlertAction actionWithTitle:@"立即更新" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
        NSLog(@"%@",action.title);
        self.checking = NO;
//        itms-services://?action=download-manifest&url=https://erp20.heneng.cn:16666/IOS/HN_ERP.plist
//        https://erp20.heneng.cn:16666/IOS
        BOOL flag = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appInfo[@"app_url"]]];
        [[UIApplication sharedApplication] close];
        
        if ( flag ) {
//            [[UIApplication sharedApplication] performSelector:@selector(suspend) withObject:nil];
        } else {
            
        }
    }]];
    
    alertView.buttonDestructiveBgColor = MAIN_THEME_COLOR;
    
    // first way to show
    TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
    
    [AWAppWindow().rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end

@implementation TYAlertController (HideStatusBar)

//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
