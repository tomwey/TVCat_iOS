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

@interface MediaPlayerVC () <WKNavigationDelegate>

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
}

- (WKWebView *)webView
{
    if ( !_webView ) {
        _webView = [[WKWebView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_webView];
        
        _webView.navigationDelegate = self;
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
