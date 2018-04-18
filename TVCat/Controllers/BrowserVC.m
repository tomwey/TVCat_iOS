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

@end

@implementation BrowserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = [self pageTitle];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.webView];
    self.webView.navigationDelegate = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self pageURL]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    [self.webView loadRequest:request];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
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
    
    NSLog(@"type: %d", navigationAction.navigationType);
    
    if ( [[request.URL absoluteString] isEqualToString:[[self pageURL] absoluteString]] ) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        NSMutableDictionary *dict = [self.params mutableCopy];
        [dict setObject:[request.URL absoluteString] forKey:@"url"];
        
        UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MediaPlayerVC" params:dict];
        [self.navigationController pushViewController:vc animated:YES];
        
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"redirect: %@", navigation);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
//        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
//    [self updateReadStatus];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //    [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
}


@end
