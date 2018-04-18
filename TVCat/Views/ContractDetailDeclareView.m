//
//  ContractDetailDeclareView.m
//  HN_Vendor
//
//  Created by tomwey on 25/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContractDetailDeclareView.h"
#import "Defines.h"

@interface ContractDetailDeclareView () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation ContractDetailDeclareView

- (void)startLoadingData
{
    [HNProgressHUDHelper showHUDAddedTo:self.superview animated:YES];
    
    __weak typeof(self) me = self;
    id userInfo = [[UserService sharedInstance] currentUser];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商查询变更指令列表APP",
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": [userInfo[@"loginname"] ?: @"" description],
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              @"param4": @"0",
              @"param5": [self.userData[@"contractid"] ?: @"0" description],
              @"param6": @"",
              @"param7": @"-1",
              @"param8": @"",
              @"param9": @"",
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
        
        _tableView.rowHeight = 80;
        
        _tableView.separatorColor = AWColorFromHex(@"#e6e6e6");
    }
    return _tableView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"DeclareFormVC" params:self.dataSource.dataSource[indexPath.row]];
    
    UIViewController *owner = self.userData[@"owner"];
    [owner presentViewController:vc animated:YES completion:nil];
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"ContractDeclareCell", @"cell.id");
    }
    return _dataSource;
}

@end
