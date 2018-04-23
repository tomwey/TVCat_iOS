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

@interface MediaPlayerVC () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation MediaPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"";
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [[CatService sharedInstance] fetchPlayerForURL:self.params[@"url"]
                                              mpid:self.params[@"mp_id"]
                                        completion:^(id result, NSError *error) {
//                                            [HNProgressHUDHelper hideHUDForView:self.contentView
//                                                                       animated:YES];
                                            
                                            if ( error ) {
                                                [HNProgressHUDHelper hideHUDForView:self.contentView
                                                                           animated:YES];
                                                [self.contentView showHUDWithText:error.domain succeed:NO];
                                            } else {
                                                NSURLRequest *request = [NSURLRequest requestWithURL:
                                                                         [NSURL URLWithString:result[@"url"]]];
                                                [self.webView loadRequest:request];
                                            }
                                            
//                                            [[CatService sharedInstance] saveHistory:
//                                             @{
//                                               @"title": result[@"title"] ?: @"",
//                                               @"mp_id": self.params[@"mp_id"],
//                                               @"source_url": self.params[@"url"] ?: @"",
//                                               @"progress": @""
//                                               }
//                                                                          completion:^(id result, NSError *error) {
//
//                                                                          }];
                                            
                                        }];
    
}

- (WKWebView *)webView
{
    if ( !_webView ) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *controller = [[WKUserContentController alloc] init];

        NSString *js = @"var $el = $('a[id^=__a_z_]'); $el.hide();$el.nextSibling && $el.nextSibling.hide();";

        WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:false];
        [controller addUserScript:script];

        configuration.userContentController = controller;
        
        _webView = [[WKWebView alloc] initWithFrame:self.contentView.bounds configuration:configuration];
        [self.contentView addSubview:_webView];
        
        _webView.navigationDelegate = self;
//        _webView.UIDelegate = self;
    }
    return _webView;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
    NSLog(@"request: %@", request);
    
//    NSString *url = [request.URL absoluteString];
    
//    if ( [[CatService sharedInstance] appConfig] ) {
//        NSArray *blackList = [[[CatService sharedInstance] appConfig] objectForKey:@"ad_blacklist"];
//        NSLog(@"blacklist: %@", blackList);
//
//        for (NSString *prefix in blackList) {
//            if ( [url hasPrefix:prefix] ) {
//                decisionHandler(WKNavigationActionPolicyCancel);
//                return;
//            }
//        }
//    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    //        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    //    [self updateReadStatus];
//    [self.webView evaluateJavaScript:@"alert(123);" completionHandler:^(id _Nullable res, NSError * _Nullable error) {
//        NSLog(@"res: %@, error: %@", res, error);
//    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //    [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
}

@end
