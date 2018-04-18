//
//  ReportListVC.m
//  HN_Vendor
//
//  Created by tomwey on 03/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "ReportListVC.h"
#import "Defines.h"

@interface ReportListVC () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation ReportListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"投诉/建议列表";
    
    UIButton *addBtn = HNAddButton(22, self, @selector(add:));
    [self addRightItemWithView:addBtn rightMargin:5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"kNeedReloadReportsNotification"
                                               object:nil];
    
    [self loadData];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id userInfo = [[UserService sharedInstance] currentUser];
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商查询投诉建议列表APP",
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": [userInfo[@"loginname"] ?: @"" description],
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id item = self.dataSource.dataSource[indexPath.row];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"ReportVC" params:item];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.tableView showErrorOrEmptyMessage:error.localizedDescription reloadDelegate:nil];
    } else {
        [self.tableView removeErrorOrEmptyTips];
        
        if ( [result[@"rowcount"] integerValue] == 0 ) {
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
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        _tableView.rowHeight = 60;
        
        [_tableView removeBlankCells];
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"ReportCell", @"cell.id");
    }
    return _dataSource;
}

- (void)add:(id)sender
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"ReportVC" params:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
