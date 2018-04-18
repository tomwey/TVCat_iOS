//
//  DeclareListVC.m
//  HN_Vendor
//
//  Created by tomwey on 13/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DeclareListVC.h"
#import "Defines.h"

@interface DeclareListVC () <AWPagerTabStripDataSource, SwipeViewDelegate, SwipeViewDataSource>

@property (nonatomic, strong) UIView *subHeader;
@property (nonatomic, strong) AWPagerTabStrip *tabStrip;

@property (nonatomic, strong) NSArray *tabTitles;

@property (nonatomic, strong) SwipeView *swipeView;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) NSMutableDictionary *searchConditions;

@end

@implementation DeclareListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"变更申报";
    
    self.searchConditions = [@{} mutableCopy];
    
    self.navBar.rightMarginOfRightItem = 5;
    self.navBar.marginOfFluidItem = 0;
    
    UIButton *searchBtn = HNSearchButton(22, self, @selector(search:));
    [self.navBar addFluidBarItem:searchBtn atPosition:FluidBarItemPositionTitleRight];
    
    UIButton *addBtn = HNAddButton(22, self, @selector(add:));
    [self.navBar addFluidBarItem:addBtn atPosition:FluidBarItemPositionTitleRight];
    
    [self addSegmentControls];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startLoadingData)
                                                 name:@"kReloadDeclareDataNotification"
                                               object:nil];
}

- (void)addSegmentControls
{
    self.tabTitles = @[@{
                           @"name": @"待申报",
                           @"type": @"0",
                           @"page": @"",
                           },
                       @{
                           @"name": @"已申报",
                           @"type": @"1",
                           @"page": @"",
                           },
                       ];
    
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    [self.contentView addSubview:self.tabStrip];
    self.tabStrip.backgroundColor = [UIColor whiteColor];//MAIN_THEME_COLOR;
    
    self.tabStrip.tabWidth = self.contentView.width / 2;
    
    self.tabStrip.titleAttributes = @{ NSForegroundColorAttributeName: AWColorFromRGB(168, 168, 168),
                                       NSFontAttributeName: AWSystemFontWithSize(14, NO) };;
    self.tabStrip.selectedTitleAttributes = @{ NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                                               NSFontAttributeName: AWSystemFontWithSize(14, NO) };
    
    //    self.tabStrip.delegate   = self;
    self.tabStrip.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    self.tabStrip.didSelectBlock = ^(AWPagerTabStrip* stripper, NSUInteger index) {
        //        weakSelf.swipeView.currentPage = index;
        __strong DeclareListVC *strongSelf = weakSelf;
        if ( strongSelf ) {
            // 如果duration设置为大于0.0的值，动画滚动，tab stripper动画会有bug
            [strongSelf.swipeView scrollToPage:index duration:0.0f]; // 0.35f
            [strongSelf swipeViewDidEndDecelerating:strongSelf.swipeView];
        }
    };
    
    if ( !self.swipeView ) {
        self.swipeView = [[SwipeView alloc] init];
        [self.contentView addSubview:self.swipeView];
        self.swipeView.frame = CGRectMake(0,
                                          self.tabStrip.bottom,
                                          self.tabStrip.width,
                                          self.contentView.height - self.tabStrip.bottom);
        
        self.swipeView.delegate = self;
        self.swipeView.dataSource = self;
        
        self.swipeView.backgroundColor = self.contentView.backgroundColor;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startLoadingData];
    });
}

- (NSInteger)numberOfTabs:(AWPagerTabStrip *)tabStrip
{
    return self.tabTitles.count;
}

- (NSString *)pagerTabStrip:(AWPagerTabStrip *)tabStrip titleForIndex:(NSInteger)index
{
    return self.tabTitles[index][@"name"];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.tabTitles.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if ( !view ) {
        DeclareListView *dView = [[DeclareListView alloc] init];
        dView.frame = CGRectMake(0, 0, self.contentView.width, self.swipeView.height);
        
        view = dView;
    }
    
    return view;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    //    NSLog(@"index: %d", swipeView.currentPage);
    
    // 更新标签状态
    [self.tabStrip setSelectedIndex:swipeView.currentPage animated:YES];
    
    //    [self pageStartLoadingData];
}

- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView
{
    self.currentPage = self.swipeView.currentPage;
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView
{
    NSLog(@"end decelerate");
    if ( self.currentPage != self.swipeView.currentPage ) {
        self.currentPage = self.swipeView.currentPage;
        
        [self startLoadingData];
    }
}

- (void)startLoadingData
{
    DeclareListView *listView = (DeclareListView *)self.swipeView.currentItemView;
    NSString *state = self.swipeView.currentPage == 0 ? @"0" : @"10";
    
    __weak typeof(self) me = self;
    listView.userData = @{ @"state": state, @"owner": me };
    
    [listView startLoading:^(BOOL succeed, NSError *error) {
        
    }];
}

- (void)search:(id)sender
{
    UIViewController *vc = [[AWMediator sharedInstance] openNavVCWithName:@"DeclareSearchVC"
                                                                   params:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)add:(id)sender
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"DeclareFormVC" params:@{ @"title": @"发起变更", @"type": @"1" }];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
