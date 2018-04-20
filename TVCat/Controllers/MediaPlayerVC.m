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
                                            
                                        }];
    
//    [self.webView addObserver:self
//                     forKeyPath:@"estimatedProgress"
//                        options:NSKeyValueObservingOptionNew
//                        context:nil];
//    [self.webView addObserver:self
//                     forKeyPath:@"title"
//                        options:NSKeyValueObservingOptionNew
//                        context:nil];
//    [self.webView addObserver:self
//                     forKeyPath:@"loading"
//                        options:NSKeyValueObservingOptionNew
//                        context:nil];
    
    
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
//    if ([keyPath isEqualToString:@"estimatedProgress"]) {
//        NSLog(@"progress: %f", self.webView.estimatedProgress);
//    }else if([keyPath isEqualToString:@"title"]){
//        NSLog(@"title: %@", change[@"new"]);
//    }else if([keyPath isEqualToString:@"loading"]){
//        //做一些加载的事
//    }else{
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//
//    if(!self.webView.loading){
//        NSLog(@"加载完成");
//    }
//}

- (WKWebView *)webView
{
    if ( !_webView ) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *controller = [[WKUserContentController alloc] init];
        
        NSString *js = @"$('div[id^=qgDiv]').hide();";
        
        WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:false];
        [controller addUserScript:script];
        
        configuration.userContentController = controller;
        
        _webView = [[WKWebView alloc] initWithFrame:self.contentView.bounds configuration:configuration];
        [self.contentView addSubview:_webView];
        
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    return _webView;
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
