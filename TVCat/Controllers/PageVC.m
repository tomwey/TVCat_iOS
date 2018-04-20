//
//  PageVC.m
//  TVCat
//
//  Created by tomwey on 18/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "PageVC.h"
#import "Defines.h"

@interface PageVC () <WKNavigationDelegate>

@property (nonatomic, strong, readwrite) WKWebView *webView;

@end

@implementation PageVC

- (NSString *)pageTitle
{
    return self.params[@"title"];
}

- (NSString *)pageSlug
{
    return self.params[@"slug"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = [self pageTitle];
    
//    [self addLeftItemWithView:nil];
    
    [self loadData];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [[CatService sharedInstance] fetchAppConfig:^(id result, NSError *error) {
        if ( error ) {
            [self.contentView showHUDWithText:@"页面地址获取失败~" succeed:NO];
            [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        } else {
            
            self.webView = [[WKWebView alloc] initWithFrame:self.contentView.bounds];
            [self.contentView addSubview:self.webView];
            self.webView.navigationDelegate = self;
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:result[[self pageSlug]]]];
            request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
            [self.webView loadRequest:request];
            
            [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
            
            self.navBar.title = @"正在加载...";
        }
    }];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    //        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
//    self.navBar.title = @"正在加载...";
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    self.navBar.title = [self pageTitle];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
}

@end
