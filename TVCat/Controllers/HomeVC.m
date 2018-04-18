//
//  HomeVC.m
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "HomeVC.h"
#import "Defines.h"

@interface HomeVC () //<UITableViewDelegate>


@end

@implementation HomeVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                        image:[UIImage imageNamed:@"tab_work.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_work.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = APP_NAME;
    
    [self addLeftItemWithView:nil];
    
    // 创建Banner
    [self initBanners];
    
    // 创建导航区域
    [self initNavSections];
}

- (void)initBanners
{
    [[self apiServiceWithName:@"APIService"]
     GET:@"banners"
     params:nil
     completion:^(id result, id rawData, NSError *error) {
         NSLog(@"result: %@", result);
     }];
}

- (void)initNavSections
{
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
