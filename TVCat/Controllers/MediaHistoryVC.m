//
//  MediaHistoryVC.m
//  TVCat
//
//  Created by tomwey on 20/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "MediaHistoryVC.h"
#import "Defines.h"

@interface MediaHistoryVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) NSInteger pageSize;

@end

@implementation MediaHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"观看历史";
    
    self.pageNum = 1;
    self.pageSize = 20;
    
    [self loadDataForPage:self.pageNum];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"cell.id"];
    }
    
    id item = self.dataSource[indexPath.row];
    
//    cell.imageView.image = nil;
    [cell.imageView setImageWithURL:[NSURL URLWithString:item[@"provider"][@"icon"]] placeholderImage:[UIImage imageNamed:@"default_icon.png"]];

    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"观看时间: %@", item[@"time"]];
    
    cell.textLabel.font = AWSystemFontWithSize(14, NO);
    cell.textLabel.textColor = AWColorFromHex(@"#666666");
    
    cell.detailTextLabel.font = AWSystemFontWithSize(12, NO);
    cell.detailTextLabel.textColor = AWColorFromHex(@"#999999");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id item = self.dataSource[indexPath.row];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"MediaPlayerVC"
                                                                params:@{
                                                                         @"title": item[@"title"] ?: @"",
                                                                         @"url": item[@"source_url"] ?: @"",
                                                                         @"mp_id": item[@"provider"][@"id"] ?: @"",
                                                                         }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadDataForPage:(NSInteger)page
{
    [self.tableView removeErrorOrEmptyTips];
    
    if ( page == 1 ) {
        [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    }
    
    [[CatService sharedInstance] loadHistoriesForPage:page
                                             pageSize:self.pageSize
                                           completion:^(id result, NSError *error) {
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        
        [self.tableView.infiniteScrollingView stopAnimating];
        
        if ( error ) {
            if ( page == 1 ) {
                [self.tableView showErrorOrEmptyMessage:@"服务器出错了~" reloadDelegate:nil];
            } else {
                [self.contentView showHUDWithText:@"数据加载出错了~" succeed:NO];
            }
        } else {
            if ( page == 1 ) {
                self.dataSource = [result mutableCopy];
            } else {
                [self.dataSource addObjectsFromArray:result];
            }
            
            [self.tableView reloadData];
        }
                                               
        self.tableView.showsInfiniteScrolling = self.dataSource.count >= self.pageSize;
    }];
}

- (void)loadMoreData
{
    self.pageNum ++;
    [self loadDataForPage:self.pageNum];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        
        [_tableView removeBlankCells];
        
        _tableView.rowHeight = 60;
        
        // 添加加载更多
        __weak typeof(self) weakSelf = self;
        
        [_tableView addInfiniteScrollingWithActionHandler:^{
            __strong MediaHistoryVC *strongSelf = weakSelf;
            if ( strongSelf ) {
                [strongSelf loadMoreData];
            }
        }];
        
        // 配置加载更多
        DGActivityIndicatorView *view = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallPulse tintColor:MAIN_THEME_COLOR];
        [view startAnimating];
        [_tableView.infiniteScrollingView setCustomView:view forState:SVInfiniteScrollingStateAll];
        
        _tableView.showsInfiniteScrolling = NO;
        
    }
    return _tableView;
}

@end
