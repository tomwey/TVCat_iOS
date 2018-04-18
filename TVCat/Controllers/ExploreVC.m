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

@interface ExploreVC () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

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
    
    [self addLeftItemWithView:nil];
}

- (NSString *)pageTitle
{
    return @"发现";
}

- (NSString *)pageSlug
{
    return @"explore_url";
}

@end
