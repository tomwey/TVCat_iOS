//
//  ContractDetailPayView.m
//  HN_Vendor
//
//  Created by tomwey on 25/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContractDetailPayView.h"
#import "Defines.h"

@interface ContractDetailPayView() <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation ContractDetailPayView

- (void)startLoadingData
{
    [HNProgressHUDHelper showHUDAddedTo:self.superview animated:YES];
    
    __weak typeof(self) me = self;
    id userInfo = [[UserService sharedInstance] currentUser];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商查询合同付款汇总APP",
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": [userInfo[@"loginname"] ?: @"" description],
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              @"param4": [self.userData[@"contractid"] ?: @"0" description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.superview animated:YES];
    
    if ( error ) {
        [self showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:@"无数据显示" reloadDelegate:nil];
            self.dataSource.dataSource = nil;
        } else {
            [self.tableView removeErrorOrEmptyTips];
            self.dataSource.dataSource = result[@"data"];
        }
        
        [self.tableView reloadData];
    }
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds
                                                  style:UITableViewStylePlain];
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        [_tableView removeBlankCells];
        
        [self addSubview:_tableView];
        
        _tableView.rowHeight = 98;
        
        _tableView.separatorColor = AWColorFromHex(@"#e6e6e6");
    }
    return _tableView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id item = self.dataSource.dataSource[indexPath.row];
    NSMutableDictionary *newItem = [item mutableCopy];
    [newItem setObject:self.userData[@"contractid"] ?: @"0" forKey:@"contractid"];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"PayListVC" params:newItem];
    
    UIViewController *owner = self.userData[@"owner"];
    [owner presentViewController:vc animated:YES completion:nil];
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"ContractPayCell", @"cell.id");
    }
    return _dataSource;
}

@end
