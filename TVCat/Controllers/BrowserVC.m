//
//  BrowserVC.m
//  TVCat
//
//  Created by tomwey on 18/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "BrowserVC.h"
#import "Defines.h"
#import <WebKit/WebKit.h>

@interface BrowserVC () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSArray *videoURLPrefixes;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation BrowserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = [self pageTitle];
    
    [self addLeftItemWithView:nil];
    
//    self.navBar.leftMarginOfLeftItem = 0;
//    self.navBar.marginOfFluidItem = -7;
    
    self.navBar.leftMarginOfLeftItem = 10;
    self.navBar.marginOfFluidItem = 0;
    
    [self.navBar addFluidBarItem:AWCreateTextButton(CGRectMake(0, 0, 50, 40),
                                                    @"返回",
                                                    [UIColor whiteColor],
                                                    self,
                                                    @selector(back))
                      atPosition:FluidBarItemPositionTitleLeft];
    
    self.closeBtn = AWCreateTextButton(CGRectMake(0, 0, 50, 40),
                                            @"关闭",
                                            [UIColor whiteColor],
                                            self,
                                            @selector(close));
    
    [self.navBar addFluidBarItem:self.closeBtn
                      atPosition:FluidBarItemPositionTitleLeft];
    
    [self addRightItemWithView:self.spinner rightMargin:15];
    
//    UIButton *backBtn = HNBackButton(24, self, @selector(back));
//    [self.navBar addFluidBarItem:backBtn
//                      atPosition:FluidBarItemPositionTitleLeft];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.webView];
    self.webView.navigationDelegate = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self pageURL]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    [self.webView loadRequest:request];
    
    [self.spinner startAnimating];
}

- (void)reloadPage
{
    [self.webView reload];
    
    [self addRightItemWithView:self.spinner rightMargin:15];
    
    [self.spinner startAnimating];
}

- (void)back
{
    if ( self.webView.canGoBack ) {
        [self.webView goBack];
    } else {
        [self close];
    }
}

- (void)close
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)pageTitle
{
    return self.params[@"title"];
}

- (NSURL *)pageURL
{
    return [NSURL URLWithString:self.params[@"url"]];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
    NSLog(@"request: %@", request);
    
    NSString *url = [request.URL absoluteString];
    
    if ( [url rangeOfString:@".m3u8"].location != NSNotFound ||
        [url rangeOfString:@".mp4"].location != NSNotFound) {
        [self forwardToPlayer:request];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    for (NSString *prefix in self.videoURLPrefixes) {
        if ( [url hasPrefix:prefix] ) {
            [self forwardToPlayer:request];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)forwardToPlayer:(NSURLRequest *)request
{
    NSMutableDictionary *dict = [self.params mutableCopy];
    [dict setObject:[request.URL absoluteString] forKey:@"url"];

    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MediaPlayerVC" params:dict];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"redirect: %@", navigation);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"start: %@", navigation);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
//        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
//    self.closeBtn.hidden = !self.webView.canGoBack;
//    [self updateReadStatus];
    
    [self.spinner stopAnimating];
    
    [self addRightItemWithView:HNReloadButton(34, self, @selector(reloadPage)) rightMargin:5];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //    [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
//    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    [self.spinner stopAnimating];
}

- (NSArray *)videoURLPrefixes
{
    if ( !_videoURLPrefixes ) {
        _videoURLPrefixes = [@[
                               @"http://m.iqiyi.com/v_",
                               @"https://m.iqiyi.com/v_",
                               @"https://m.youku.com/video/id_",
                               @"http://m.youku.com/video/id_",
                               @"http://m.le.com/vplay_",
                               @"https://m.le.com/vplay_",
                               @"https://m.mgtv.com/b/",
                               @"http://m.pptv.com/show/",
                               @"http://m.fun.tv/mplay/",
                               @"https://m.pptv.com/show/",
                               @"https://m.fun.tv/mplay/",
                               @"https://m.film.sohu.com/album/",
                               @"http://m.v.qq.com/x/cover/",
                               @"https://m.v.qq.com/x/cover/",
                               ] copy];
    }
    return _videoURLPrefixes;
}

- (UIActivityIndicatorView *)spinner
{
    if ( !_spinner ) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner.hidesWhenStopped = YES;
    }
    return _spinner;
}

@end
