//
//  ExploreVC.m
//  TVCat
//
//  Created by tomwey on 18/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "ExploreVC.h"
#import "Defines.h"

#import <WebKit/WebKit.h>

@interface ExploreVC ()

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *reloadBtn;

@end

@implementation ExploreVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现"
                                                        image:[UIImage imageNamed:@"tab_explore.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_explore.png"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backBtn = AWCreateTextButton(CGRectMake(0, 0, 50, 40),
                                      @"返回",
                                      [UIColor whiteColor],
                                      self,
                                      @selector(back));
    [self addLeftItemWithView:self.backBtn leftMargin:10];
    
    self.backBtn.hidden = YES;
    
    self.reloadBtn = HNReloadButton(34, self, @selector(reload));
//    self.reloadBtn.enabled = NO;
    
    [self addRightItemWithView:self.reloadBtn
                   rightMargin:5];
    
}

- (void)reload
{
//    self.reloadBtn.enabled = NO;
    
    [self.webView reload];
}

- (void)back
{
    if ( self.webView.canGoBack ) {
        [self.webView goBack];
    }
}

- (NSString *)pageTitle
{
    return @"发现";
}

- (NSString *)pageSlug
{
    return @"explore_url";
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    //    self.navBar.title = @"正在加载...";
    self.backBtn.hidden = !self.webView.canGoBack;
}

@end
