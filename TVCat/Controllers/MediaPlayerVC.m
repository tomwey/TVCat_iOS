//
//  MediaPlayerVC.m
//  TVCat
//
//  Created by tomwey on 18/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "MediaPlayerVC.h"
#import "Defines.h"
#import <WebKit/WebKit.h>
//#import <IJKMediaFramework/IJKMediaFramework.h>
#import "ZFPlayer.h"
#import "ZFPlayerControlView.h"
#import "ZFAVPlayerManager.h"
#import "TYAlertView.h"
#import "TYAlertController.h"

@interface MediaPlayerVC () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;

@property (nonatomic, strong) id result;

@property (nonatomic, copy) NSString *titleString;

@end

@implementation MediaPlayerVC

- (void)dealloc
{
    [self.player stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"";
    
//    [self addRightItemWithTitle:@"全屏" size:CGSizeMake(60,40) callback:^{
//        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
//
//        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//    }];
    
    NSString *url = self.params[@"url"];
    if ( [url rangeOfString:@"title="].location != NSNotFound ) {
        self.titleString = [url queryDictionaryUsingEncoding:NSUTF8StringEncoding][@"title"];
        self.navBar.title = self.titleString;
    }
    
    [self loadPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadPlayer)
                                                 name:@"kVIPActiveSuccessNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadPlayer)
                                                 name:@"kNeedReloadForVIPNotification"
                                               object:nil];
}

- (void)loadPlayer
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [[CatService sharedInstance] fetchPlayerForURL:self.params[@"url"]
                                              mpid:self.params[@"mp_id"]
                                        completion:^(id result, NSError *error)
     {
         if ( error ) {
             [HNProgressHUDHelper hideHUDForView:self.contentView
                                        animated:YES];
             if ( error.code == 6008 ) {
                 // vip已过期
                 [self showChargeAlert];
             } else {
                 [self.contentView showHUDWithText:error.domain succeed:NO];
             }
         } else {
             
//             NSString *url = [result[@"url"] description];
//
//             //                 SString *encoded = @"fields=ID%2CdeviceToken";
//             NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)url, CFSTR(""), kCFStringEncodingUTF8);
             /*
             if (  [[result[@"type"] description] isEqualToString:@"h5mp4"] ||
                [[result[@"type"] description] isEqualToString:@"m3u8"]) {
                 [HNProgressHUDHelper hideHUDForView:self.contentView
                                            animated:YES];
                 // 使用原生的方式播放
                 self.navBar.title = result[@"title"];

                 [self playVideo:result];
             } else {
                 self.navBar.title = result[@"title"];
                 
             NSString *url = [result[@"url"] description];
                 
//                 SString *encoded = @"fields=ID%2CdeviceToken";
                 NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)url, CFSTR(""), kCFStringEncodingUTF8);
                 
                 NSURLRequest *request = [NSURLRequest requestWithURL:
                                          [NSURL URLWithString:decoded]];
                 [self.webView loadRequest:request];
             }*/
             
             self.result = result;
             
             self.navBar.title = self.result[@"title"];
             
             NSString *url = [result[@"url"] description];
             
             NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)url, CFSTR(""), kCFStringEncodingUTF8);

             NSURLRequest *request = [NSURLRequest requestWithURL:
                                      [NSURL URLWithString:decoded]];
             [self.webView loadRequest:request];
//             [self playVideo:@{ @"url": @"https://youku.com-youku.com/20180330/W8XENbyc/index.m3u8" }];
         }
     }];
}

- (void)showChargeAlert
{
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"VIP充值提示"
                                                     message:@"您还不是VIP会员或会员已过期，请充值"];
    
    alertView.messageLabel.textAlignment = NSTextAlignmentCenter;
    //    alertView.contentViewSpace = 30;
    alertView.textLabelSpace   = 20;
    alertView.textLabelContentViewEdge = 35;
    
    [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancel handler:^(TYAlertAction *action) {
        NSLog(@"%@",action.title);
//        self.checking = NO;
    }]];
    
    alertView.buttonDestructiveBgColor = MAIN_THEME_COLOR;
    
    __weak typeof(self) me = self;
    [alertView addAction:[TYAlertAction actionWithTitle:@"去充值" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"NewVIPChargeVC" params:nil];
        [me presentViewController:vc animated:YES completion:nil];
    }]];
    
    alertView.buttonDestructiveBgColor = MAIN_THEME_COLOR;
    
    // first way to show
    TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ( self.player && self.player.currentTime > 0 ) {
        [[CatService sharedInstance] uploadPlayProgress: self.player.currentTime
                                                  title: self.titleString ?: @"     "
                                                 forUrl: self.params[@"url"]
         ];
    }
    
}

- (void)playVideo:(id)result
{
//    self.result = result;
    
    [self.controlView resetControlView];
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    /// 播放器相关
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:self.contentView];
    self.player.controlView = self.controlView;
    
    NSTimeInterval progress = [result[@"progress"] doubleValue];
    if ( progress > 0 && ([result[@"type"] isEqualToString:@"h5mp4"] || [result[@"type"] isEqualToString:@"m3u8"]) ) {
        playerManager.seekTime = progress;
    }
    
//    @weakify(self)
//    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
//        @strongify(self)
//        [self.view endEditing:YES];
//        [self setNeedsStatusBarAppearanceUpdate];
//    };
//    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
//        @strongify(self)
//        [self.player enterFullScreen:NO animated:YES];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.player.orientationObserver.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.playser stop];
//        });
//    };
    
//    [self.player enterFullScreen:YES animated:YES];
    
//    [self.controlView showTitle:result[@"title"] ?: self.titleString
//                 coverURLString:nil
//                 fullScreenMode:ZFFullScreenModePortrait];
//    NSString *URLString = [@"http://tb-video.bdstatic.com/videocp/12045395_f9f87b84aaf4ff1fee62742f2d39687f.mp4" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    NSString *proxyURLString = [KTVHTTPCache proxyURLStringWithOriginalURLString:URLString];
    
    NSString *url = [result[@"url"] description];

 //                 SString *encoded = @"fields=ID%2CdeviceToken";
    NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)url, CFSTR(""), kCFStringEncodingUTF8);
    
    playerManager.assetURL = [NSURL URLWithString:decoded];
}

- (BOOL)supportsSwipeToBack
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
//    if (self.player.isFullScreen) {
        return UIStatusBarStyleLightContent;
//    }
//    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.player.isStatusBarHidden;
}

//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
//    return UIStatusBarAnimationSlide;
//}

//- (BOOL)shouldAutorotate {
//    return NO;
//}

- (BOOL)shouldAutorotate {
    return self.player.shouldAutorotate;
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
//}

#pragma mark - about keyboard orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
//        _controlView.backgroundColor = [UIColor blackColor];
        [_controlView showTitle:@"视频标题"
                 coverURLString:nil
                 fullScreenMode:ZFFullScreenModePortrait];
    }
    return _controlView;
}

- (WKWebView *)webView
{
    if ( !_webView ) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *controller = [[WKUserContentController alloc] init];

//        id config = [CatService sharedInstance].appConfig;
//
//        NSString *js = [config[@"ad_script"] description];//@"var $el = $('a[id^=__a_z_]'); $el.hide();";
//
//        WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
//                                                   forMainFrameOnly:false];
//        [controller addUserScript:script];

        configuration.userContentController = controller;
        
        _webView = [[WKWebView alloc] initWithFrame:self.contentView.bounds configuration:configuration];
        [self.contentView addSubview:_webView];
        
//        _webView.translatesAutoresizingMaskIntoConstraints = YES;
        
//        _webView.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36";
        
        _webView.navigationDelegate = self;
//        _webView.UIDelegate = self;
    }
    return _webView;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
    NSLog(@"request: %@", request);
    
    NSString *url = [request.URL absoluteString];
    
    if ( [url rangeOfString:@".m3u8"].location != NSNotFound ||
        [url rangeOfString:@".mp4"].location != NSNotFound
        ) {
        NSDictionary *dict = [url queryDictionaryUsingEncoding:NSUTF8StringEncoding];
        NSString *playingURL;
        for (NSString *key in dict) {
            NSString *value = dict[key];
            if ([value rangeOfString:@".m3u8"].location != NSNotFound ||
                [value rangeOfString:@".mp4"].location != NSNotFound
                ) {
                playingURL = value;
                break;
            }
        }
        
        if (playingURL) {
            NSMutableDictionary *result = [self.result mutableCopy];
            result[@"url"] = playingURL ?: @"";
            
            [self playVideo:result];
            
            self.webView.hidden = YES;
            
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    //        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [self.webView evaluateJavaScript:@"document.title"
                   completionHandler:^(id result, NSError * _Nullable error) {
//                       NSLog(@"%@",result);
                       [me updateTitle:result];
                   }];
}

- (void)updateTitle:(id)result
{
    self.titleString = result;
    self.navBar.title = result;
    [self.controlView showTitle:result coverURLString:nil fullScreenMode:ZFFullScreenModeLandscape];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //    [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
}

@end
