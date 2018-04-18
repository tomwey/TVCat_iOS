//
//  MessageVC.m
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MessageVC.h"
#import "Defines.h"

@interface MessageVC () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation MessageVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息"
                                                        image:[UIImage imageNamed:@"tab_message.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_message_click.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.title = @"消息";
    
    [self addLeftItemWithView:nil];
    
//    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(triggerPullToRefresh)
                                                 name:@"kHasNewMessageNotification"
                                               object:nil];
    
    [self.tableView triggerPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.tabBarItem.badgeValue = nil;
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [self.tableView removeErrorOrEmptyTips];
    
    id userInfo = [[UserService sharedInstance] currentUser];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商获取消息列表APP",
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": userInfo[@"loginname"] ?: @"",
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              @"param4": @"0",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    [self.tableView.pullToRefreshView stopAnimating];
    
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ([result[@"rowcount"] integerValue] == 0) {
            [self.tableView showErrorOrEmptyMessage:@"无数据显示" reloadDelegate:nil];
            
            self.dataSource.dataSource = nil;
        } else {
            self.dataSource.dataSource = result[@"data"];
        }
        
        [self.tableView reloadData];
    }
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        _tableView.rowHeight  = 80;
        
        _tableView.separatorInset = UIEdgeInsetsZero;
        
//        _tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        
        [_tableView removeBlankCells];
        
        _tableView.backgroundColor = [UIColor clearColor];
        
        // 添加下拉刷新
        __weak MessageVC *weakSelf = self;
        [_tableView addPullToRefreshWithActionHandler:^{
            __strong MessageVC *strongSelf = weakSelf;
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

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"MessageCell", @"msg.cell");
    }
    return _dataSource;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MessageDetailVC" params:self.dataSource.dataSource[indexPath.row]];
    [AWAppWindow().navController pushViewController:vc animated:YES];
}

@end
