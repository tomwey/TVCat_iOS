//
//  ContractDetailVC.m
//  HN_Vendor
//
//  Created by tomwey on 22/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContractDetailVC.h"
#import "Defines.h"

@interface ContractDetailVC () <AWPagerTabStripDataSource, SwipeViewDelegate, SwipeViewDataSource>

@property (nonatomic, assign) CGFloat currentTop;

@property (nonatomic, strong) AWPagerTabStrip *tabStrip;

@property (nonatomic, strong) NSArray *tabTitles;

@property (nonatomic, strong) SwipeView *swipeView;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) NSMutableDictionary *swipeViews;

@end

@implementation ContractDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"详情";
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.currentTop = 0;
    
    [self addBaseInfo];
    
    [self tabPagers];
    
    [self addSwipeContents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startLoadingData)
                                                 name:@"kReloadDeclareDataNotification"
                                               object:nil];
}

- (void)addBaseInfo
{
    UILabel *label = AWCreateLabel(CGRectMake(15, 10, self.contentView.width - 30,
                                              50),
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(71, 71, 71));
    [self.contentView addSubview:label];
    
    label.numberOfLines = 2;
    label.adjustsFontSizeToFitWidth = YES;
    
    label.text = self.params[@"contractname"];
    
    [label sizeToFit];
    
    label.height = 50;
    
    UILabel *state = AWCreateLabel(CGRectMake(0, 0, 40, 22),
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(10, NO),
                                   nil);
    [self.contentView addSubview:state];
    state.position = CGPointMake(self.contentView.width - 15 - state.width, label.bottom + 10);
    
    NSString *stateName;
    UIColor *color;
    if ( [self.params[@"appstatus"] integerValue] == 40 ) {
        stateName = @"执行中";
        color = MAIN_THEME_COLOR;
    } else if ([self.params[@"appstatus"] integerValue] == 50) {
        stateName = @"已结算";
        color = AWColorFromRGB(116, 182, 102);
    } else if ([self.params[@"appstatus"] integerValue] == 70) {
        stateName = @"已解除";
        color = AWColorFromRGB(201, 92, 84);
    }
    state.text = self.params[@"appstatusdesc"];
    state.textColor = color;
    state.layer.borderColor = color.CGColor;
    state.layer.borderWidth = 0.6;
    state.cornerRadius = 2;
    
    UILabel *projLabel = AWCreateLabel(label.frame,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(12, NO),
                                       AWColorFromRGB(153, 153, 153));
    [self.contentView addSubview:projLabel];
    
    projLabel.top = label.bottom;
    projLabel.height = 22;
    projLabel.text = [NSString stringWithFormat:@"项目名称: %@", self.params[@"project_name"]];
    
    UILabel *noLabel = AWCreateLabel(label.frame,
                                       nil,
                                       NSTextAlignmentLeft,
                                       AWSystemFontWithSize(12, NO),
                                       AWColorFromRGB(153, 153, 153));
    [self.contentView addSubview:noLabel];
    
    noLabel.top = projLabel.bottom;
    noLabel.height = 22;
    noLabel.text = [NSString stringWithFormat:@"合同编号: %@", self.params[@"contractphyno"]];
    
    self.currentTop = noLabel.bottom;
}

- (void)tabPagers
{
    AWHairlineView *line1 = [AWHairlineView horizontalLineWithWidth:self.contentView.width - 30
                                                              color:AWColorFromHex(@"#e6e6e6")
                                                             inView:self.contentView];
    line1.position = CGPointMake(15, self.currentTop + 20);
    
    AWHairlineView *line2 = [AWHairlineView horizontalLineWithWidth:self.contentView.width - 30
                                                              color:AWColorFromHex(@"#e6e6e6")
                                                             inView:self.view];
    
    line2.position = CGPointMake(15, [self.contentView convertPoint:line1.position
                                                             toView:self.view].y + 51);
    
    self.currentTop = line1.bottom + 51;
    
    self.tabTitles = @[@{
                           @"name": @"总体信息",
                           @"type": @"0",
                           @"page": @"ContractDetailBaseView",
                           },
//                       @{
//                           @"name": @"付款",
//                           @"type": @"1",
//                           @"page": @"ContractDetailPayView",
//                           },
                       @{
                           @"name": @"变更指令",
                           @"type": @"2",
                           @"page": @"ContractDetailDeclareView",
                           },
                       @{
                           @"name": @"签证",
                           @"type": @"3",
                           @"page": @"ContractDetailSignView",
                           },
                       ];
    
    self.tabStrip = [[AWPagerTabStrip alloc] init];
    [self.contentView addSubview:self.tabStrip];
    self.tabStrip.backgroundColor = [UIColor whiteColor];//MAIN_THEME_COLOR;

    self.tabStrip.width = self.contentView.width - 30;
    self.tabStrip.position = CGPointMake(15, line1.bottom + 5);

    self.tabStrip.tabWidth = (self.contentView.width - 30) / self.tabTitles.count;

//    self.tabStrip.allowShowingIndicator = NO;

    self.tabStrip.titleAttributes = @{ NSForegroundColorAttributeName: AWColorFromRGB(168, 168, 168),
                                       NSFontAttributeName: AWSystemFontWithSize(14, NO) };;
    self.tabStrip.selectedTitleAttributes = @{ NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                                               NSFontAttributeName: AWSystemFontWithSize(14, NO) };

    //    self.tabStrip.delegate   = self;
    self.tabStrip.dataSource = self;

    __weak typeof(self) weakSelf = self;
    self.tabStrip.didSelectBlock = ^(AWPagerTabStrip* stripper, NSUInteger index) {
        //        weakSelf.swipeView.currentPage = index;
        __strong ContractDetailVC *strongSelf = weakSelf;
        if ( strongSelf ) {
            // 如果duration设置为大于0.0的值，动画滚动，tab stripper动画会有bug
            [strongSelf.swipeView scrollToPage:index duration:0.0f]; // 0.35f
            [strongSelf swipeViewDidEndDecelerating:strongSelf.swipeView];
        }
    };
}

- (void)addSwipeContents
{
    if ( !self.swipeView ) {
        self.swipeView = [[SwipeView alloc] init];
        [self.contentView addSubview:self.swipeView];
        self.swipeView.frame = CGRectMake(0,
                                          self.currentTop,
                                          self.contentView.width,
                                          self.contentView.height - self.currentTop);
        
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
    return [self swipeViewForIndex:index];
}

- (UIView *)swipeViewForIndex:(NSInteger)index
{
    if ( !self.swipeViews ) {
        self.swipeViews = [@{} mutableCopy];
    }
    NSString *pageName = self.tabTitles[index][@"page"];
    
    UIView *view = self.swipeViews[pageName];
    if ( !view ) {
        view = [[NSClassFromString(pageName) alloc] init];
        view.frame = CGRectMake(0, 0, self.swipeView.width, self.swipeView.height);
        if (view) {
            self.swipeViews[pageName] = view;
        }
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
    UIView *view = [self swipeViewForIndex:self.swipeView.currentPage];
    __weak typeof(self) weakSelf = self;
    
    id block = ^(NSInteger type) {
//        [weakSelf.tabStrip setSelectedIndex:type animated:YES];
        [weakSelf.swipeView scrollToPage:type duration:0.0f]; // 0.35f
        [weakSelf swipeViewDidEndDecelerating:weakSelf.swipeView];
    };
    view.userData = @{ @"contractid": self.params[@"contractid"], @"owner": weakSelf, @"forwardMoreBlock": block };
    
    if ( [view respondsToSelector:@selector(startLoadingData)] ) {
        [view performSelector:@selector(startLoadingData) withObject:nil];
    }
}

@end
