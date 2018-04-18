//
//  HomeVC.m
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "HomeVC.h"
#import "Defines.h"
#import "BannerView.h"
#import "MediaProviderView.h"

@interface HomeVC () <BannerViewDataSource, UITableViewDataSource>

@property (nonatomic, strong) BannerView *bannerView;
@property (nonatomic, strong) NSArray    *bannerDataSource;

@property (nonatomic, assign) BOOL needResumeBanner;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSError *dataError;

@property (nonatomic, assign) NSInteger counter;

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
    
    self.needResumeBanner = NO;
    
//    // 创建Banner
//    [self initBanners];
//
//    // 创建导航区域
//    [self initNavSections];
    
    [self loadData];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     GET:@"banners"
     params:nil
     completion:^(id result, id rawData, NSError *error) {
         [me handleResult:result error:error];
     }];
    
    [[self apiServiceWithName:@"APIService"]
     GET:@"media/providers"
     params:nil
     completion:^(id result, id rawData, NSError *error) {
         [me handleResult2:result error:error];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.needResumeBanner ) {
        self.needResumeBanner = NO;
        [self.bannerView resume];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.needResumeBanner = YES;
    
    [self.bannerView pause];
}

- (void)handleResult:(id)result error:(NSError *)error;
{
    self.bannerDataSource = result;
    
    [self loadDone];
}

- (void)handleResult2:(id)result error:(NSError *)error;
{
    self.dataSource = result;
    self.dataError = error;
    
    [self loadDone];
}

- (void)loadDone
{
    self.counter ++;
    
    if ( self.counter == 2 ) {
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        
        self.counter = 0;
        
        self.tableView.tableHeaderView = self.bannerView;
        [self.bannerView reloadData];
        
        if ( self.dataError ) {
            [self.tableView showErrorOrEmptyMessage:self.dataError.domain reloadDelegate:nil];
        } else {
            [self.tableView removeErrorOrEmptyTips];
        }
        
        [self.tableView reloadData];
        
        [self.tableView.pullToRefreshView stopAnimating];
    }
}

- (NSInteger)numberOfCols
{
    if ( AWFullScreenWidth() > 320 ) {
        return 4;
    } else {
        return 3;
    }
}

- (CGFloat)mediaItemWidth
{
    return (self.contentView.width - 30) / [self numberOfCols];
}

- (NSInteger)numberOfRows
{
    return (self.dataSource.count + [self numberOfCols] - 1) / [self numberOfCols];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self addContents:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)addContents:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cols = [self numberOfCols];
    if ( indexPath.row == [self numberOfRows] - 1 ) {
        cols = self.dataSource.count - indexPath.row * [self numberOfCols];
    }
    
    for (int i = cols; i < [self numberOfCols]; i++) {
        [[cell.contentView viewWithTag:100 + i] removeFromSuperview];
    }
    
    for (int i = 0; i < cols; i++) {
        MediaProviderView *view = (MediaProviderView *)[cell.contentView viewWithTag:100 + i];
        if ( !view ) {
            view = [[MediaProviderView alloc] init];
            [cell.contentView addSubview:view];
            view.tag = 100 + i;
            
            view.frame = CGRectMake(15 + i * [self mediaItemWidth],
                                    0, [self mediaItemWidth], [self mediaItemWidth]);
        }
        
        NSInteger index = indexPath.row * [self numberOfCols] + i;
        
//        view.backgroundColor = [UIColor redColor];
        
        if ( index < self.dataSource.count ) {
            view.data = self.dataSource[index];
        }
    }
}

- (BannerView *)bannerView
{
    if ( !_bannerView ) {
        _bannerView = [[BannerView alloc] init];
        
        _bannerView.frame = CGRectMake(0, 0, self.contentView.width,
                                       self.contentView.width * 0.45);
        _bannerView.dataSource = self;
        
        __weak typeof(self) weakSelf = self;
        _bannerView.didSelectItemBlock = ^(BannerView *sender, NSInteger index) {
            [weakSelf openBanner:weakSelf.bannerDataSource[index]];
        };
        
        _bannerView.pageControl.currentPageIndicatorTintColor = MAIN_THEME_COLOR;
        _bannerView.pageControl.pageIndicatorTintColor = AWColorFromRGBA(254,254,254,0.9);
    }
    return _bannerView;
}

- (void)openBanner:(id)banner
{
    
}

- (NSInteger)numberOfItemsInBannerView:(BannerView *)bannerView
{
    return self.bannerDataSource.count;
}

- (UIView *)bannerView:(BannerView *)bannerView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = (UIImageView *)view;
    if ( !imageView ) {
        imageView = AWCreateImageView(nil);
        view = imageView;
        imageView.backgroundColor = AWColorFromRGB(221, 221, 221);
        imageView.frame = bannerView.bounds;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;
    }
    
    imageView.image = nil;
    
    NSString *imageUrl = self.bannerDataSource[index][@"image"];
    
    [imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    return imageView;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self;
        
        _tableView.rowHeight  = [self mediaItemWidth] + 10;
        
        _tableView.showsVerticalScrollIndicator = NO;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView removeBlankCells];
        
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        
        // 添加下拉刷新
        __weak HomeVC *weakSelf = self;
        [_tableView addPullToRefreshWithActionHandler:^{
            __strong HomeVC *strongSelf = weakSelf;
            if ( strongSelf ) {
                [strongSelf loadData];
            }
        }];
        
        // 配置下拉刷新功能
        HNRefreshView *stopView = [[HNRefreshView alloc] init];
        stopView.text = @"下拉刷新";
        
        HNRefreshView *loadingView = [[HNRefreshView alloc] init];
        loadingView.text = @"加载中...";
        loadingView.animated = YES;
        
        HNRefreshView *triggerView = [[HNRefreshView alloc] init];
        triggerView.text = @"松开刷新";
        triggerView.animated = YES;
        
        [_tableView.pullToRefreshView setCustomView:triggerView forState:SVPullToRefreshStateTriggered];
        [_tableView.pullToRefreshView setCustomView:loadingView forState:SVPullToRefreshStateLoading];
        [_tableView.pullToRefreshView setCustomView:stopView forState:SVPullToRefreshStateStopped];
        
    }
    return _tableView;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
