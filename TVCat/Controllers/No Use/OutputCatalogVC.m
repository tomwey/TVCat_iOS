//
//  OutputCatalogVC.m
//  HN_ERP
//
//  Created by tomwey on 20/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputCatalogVC.h"
#import "Defines.h"
#import "CatalogLeftMenuView.h"
#import "CatalogContentView.h"
#import "OutputCatalog.h"

@interface OutputCatalogVC () <UISearchBarDelegate>

@property (nonatomic, strong) DMButton *areaButton;
@property (nonatomic, strong) DMButton *projButton;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIButton *unconfirmButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, weak) UIView *captionView;

@property (nonatomic, strong) UIView *catalogView;

@property (nonatomic, strong) NSMutableArray *outputAreas;
@property (nonatomic, strong) NSMutableDictionary *outputProjects;

@property (nonatomic, strong) OutputArea    *currentArea;
@property (nonatomic, strong) OutputProject *currentProject;

@property (nonatomic, strong) NSArray *catalogs;

@property (nonatomic, weak) CatalogLeftMenuView *leftMenuView;
@property (nonatomic, weak) CatalogContentView  *catalogMainView;

@property (nonatomic, strong) OutputQueryParams *queryParams;

@end

@implementation OutputCatalogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queryParams = [[OutputQueryParams alloc] init];
    
    self.navBar.title = @"合同分类搜索";
    
//    __weak OutputCatalogVC *weakSelf = self;
//    [self addRightItemWithImage:@"btn_search2.png" rightMargin:5 callback:^{
//        [weakSelf openSearchVC];
//    }];
    
    [self initHeaderCaption];
    
    [self initCatalogList];
    
    self.catalogView.hidden = YES;
    
    [self loadAreaProjects];
}

- (NSMutableArray *)outputAreas
{
    if ( !_outputAreas ) {
        _outputAreas = [[NSMutableArray alloc] init];
    }
    return _outputAreas;
}

- (void)openSearchVC
{
    UIViewController *vc = [[AWMediator sharedInstance] openNavVCWithName:@"OutputSearchVC"
                                                                   params:@{ @"queryParams": self.queryParams,
                                                                             @"areas": self.outputAreas,
                                                                             @"projects": self.outputProjects,
                                                                             @"currentArea": self.areaButton.userData ?: [NSNull null],
                                                                             @"currentProject": self.projButton.userData ?: [NSNull null],
                                                                             }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSMutableDictionary *)outputProjects
{
    if ( !_outputProjects ) {
        _outputProjects = [[NSMutableDictionary alloc] init];
    }
    return _outputProjects;
}

- (void)loadAreaProjects
{
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认获取区域项目APP",
              @"param1": manID,
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)openPickerForData:(NSArray *)data sender:(DMButton *)sender
{
    if ( data.count == 0 ) {
        return;
    }
    
    UIView *superView = self.contentView;
    
    SelectPicker *picker = [[SelectPicker alloc] init];
    picker.frame = superView.bounds;
    
    id currentOption = [sender.userData performSelector:@selector(shortItem) withObject:nil];
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (int i=0; i<data.count; i++) {
        id dict = data[i];
        [temp addObject:[dict performSelector:@selector(shortItem) withObject:nil]];
    }
    
    picker.options = [temp copy];
    
    picker.currentSelectedOption = currentOption;
    
    [picker showPickerInView:superView];
    
    __weak typeof(self) me = self;
    picker.didSelectOptionBlock = ^(SelectPicker *inSender, id selectedOption, NSInteger index) {
        
        if ( sender == me.areaButton ) {
            
            if ( ![selectedOption isEqualToDictionary:[me.areaButton.userData performSelector:@selector(shortItem) withObject:nil]] ) {
                sender.userData = data[index];
                me.projButton.title = @"选择项目";
            }
            
        } else if ( sender == me.projButton ) {
            
            if ( ![selectedOption isEqualToDictionary:[me.projButton.userData performSelector:@selector(shortItem) withObject:nil]] ) {
                sender.userData = data[index];
                
                me.queryParams.projID = [me.projButton.userData projectId];
                
                [me startLoadData];
            }
        }
        
        sender.title = selectedOption[@"name"];
        
    };
}

- (void)startLoadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认获取合同类别APP",
              @"param1": [self.projButton.userData projectId],
              @"param2": manID,
              } completion:^(id result, NSError *error) {
                  [me handleResult2:result error:error];
              }];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    //    NSLog(@"result: %@", result);
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"没有合同类别数据" offset:CGPointMake(0,20)];
        } else {
            NSArray *data = result[@"data"];
            
            [self prepareData2:data];
            
            self.leftMenuView.catalogData = self.catalogs;
            
            self.catalogMainView.catalogData = [[self.catalogs firstObject] children];
            
            self.catalogView.hidden = NO;
            
//            self.catalogView.backgroundColor = [UIColor redColor];
        }
    }
}

- (void)prepareData2:(id)data
{
    // level 1
    NSMutableArray *level1 = [NSMutableArray array];
    
    NSMutableArray *temp = [NSMutableArray array];
    for (id dict in data) {
        if ( [dict[@"ilevel"] integerValue] == 1 ) {
            OutputCatalog *catalog = [[OutputCatalog alloc] initWithDictionary:dict];
            [level1 addObject:catalog];
        } else {
            [temp addObject:dict];
        }
    }
    
    // level 2
    NSMutableArray *level2 = [NSMutableArray array];
    NSMutableArray *temp2 = [NSMutableArray array];
    for (id dict in temp) {
        if ( [dict[@"ilevel"] integerValue] == 2 ) {
            OutputCatalog *catalog2 = [[OutputCatalog alloc] initWithDictionary:dict];
            for (OutputCatalog *o in level1) {
                if ([o.mid isEqualToString:[catalog2.parentId description]]) {
                    [o.children addObject:catalog2];
                } else {
                    continue;
                }
            }
            [level2 addObject:catalog2];
        } else {
            [temp2 addObject:dict];
        }
    }
    
    // 第三极
    for (id dict in temp2) {
        OutputCatalog *catalog2 = [[OutputCatalog alloc] initWithDictionary:dict];
        
        for (OutputCatalog *o in level2) {
            if ([o.mid isEqualToString:[catalog2.parentId description]]) {
                [o.children addObject:catalog2];
            } else {
                continue;
            }
        }
    }
    
    //            NSLog(@"level1: %@", level1);
    self.catalogs = [level1 copy];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
//    NSLog(@"result: %@", result);
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"区域项目数据为空" succeed:NO];
        } else {
            NSArray *data = result[@"data"];
            
            [self prepareData:data];
        }
    }
    
//    self.areaButton.title = @"选择区域";
//    self.projButton.title = @"选择项目";
    
    [self setDefaultAreaProjects];
    
}

- (void)setDefaultAreaProjects
{
    id user = [[UserService sharedInstance] currentUser];
    
    OutputArea *defaultArea = nil;
    
    for (OutputArea *area in self.outputAreas) {
        if ( [area.areaName isEqualToString:user[@"area_name"]] ) {
            defaultArea = area;
            break;
        }
    }
    
    if ( !defaultArea ) {
        defaultArea = [self.outputAreas firstObject];
    }
    
//    self.currentArea = defaultArea;
    
    OutputProject *project = [self.outputProjects[defaultArea.areaId] firstObject];
    
    self.areaButton.userData = defaultArea;
    self.projButton.userData = project;
    
    self.areaButton.title = defaultArea.areaName;
    self.projButton.title = project.projectName;
    
    self.queryParams.projID = project.projectId;
    
    [self startLoadData];
}

- (void)setCurrentArea:(OutputArea *)currentArea
{
    _currentArea = currentArea;
    
    self.areaButton.title = currentArea.areaName;
}

- (void)setCurrentProject:(OutputProject *)currentProject
{
    _currentProject = currentProject;
    
    self.projButton.title = currentProject.projectName;
}

- (void)prepareData:(id)data
{
    for (id dict in data) {
        OutputArea *area = [[OutputArea alloc] initWithDictionary:dict];
        
        NSMutableArray *array = nil;
        if ([self.outputAreas containsObject:area]) {
            array = self.outputProjects[area.areaId];
            OutputProject *proj = [[OutputProject alloc] initWithDictionary:dict];
            [array addObject:proj];
            //                    continue;
        } else {
            array = [[NSMutableArray alloc] init];
            self.outputProjects[area.areaId] = array;
            
            OutputProject *proj = [[OutputProject alloc] initWithDictionary:dict];
            [array addObject:proj];
            
            [self.outputAreas addObject:area];
        }
    }
}

- (void)initCatalogList
{
    self.catalogView = [[UIView alloc] initWithFrame:
                            CGRectMake(0, self.captionView.bottom + 10,
                                       self.contentView.width,
                                       self.contentView.height - self.areaButton.height -
                                       self.captionView.height - 10)];
    self.catalogView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.catalogView];
    
    // 左边类别
    CatalogLeftMenuView *leftView = [[CatalogLeftMenuView alloc] init];
    [self.catalogView addSubview:leftView];
    leftView.frame = CGRectMake(15, 15, 90, self.catalogView.height - 30 - 45);
    
    self.leftMenuView = leftView;
    
    __weak typeof(self) me = self;
    leftView.didSelectCatalog = ^(OutputCatalog *catalog) {
        me.catalogMainView.catalogData = catalog.children;
    };
    
    // 右边的内容页
    CatalogContentView *contentView = [[CatalogContentView alloc] init];
    [self.catalogView addSubview:contentView];
    contentView.frame = CGRectMake(leftView.right + 15,
                                   leftView.top,
                                   self.catalogView.width - leftView.right - 15 - 15,
                                   leftView.height);
    
    self.catalogMainView = contentView;
    
    contentView.didSelectBlock = ^(OutputCatalog *catalog) {
        me.queryParams.queryType = @"1";
        
        me.queryParams.catalogID = [[catalog typeId] description];
        
        [me gotoConstract];
    };
    
    UILabel *tipLabel = AWCreateLabel(CGRectMake(15, leftView.bottom,
                                                 self.catalogView.width - 30,
                                                 40),
                                      @"只显示有签约的合同分类数据，(1)表示1个签约合同",
                                      NSTextAlignmentCenter,
                                      AWSystemFontWithSize(14, NO),
                                      MAIN_THEME_COLOR);
    tipLabel.numberOfLines = 2;
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.catalogView addSubview:tipLabel];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.queryParams.queryType = @"0";
    self.queryParams.where = [searchBar.text trim];
    
    [self gotoConstract];
}

- (void)initHeaderCaption
{
    self.areaButton.frame = self.projButton.frame = CGRectMake(0, 0, self.contentView.width / 2,40);
    self.projButton.left = self.areaButton.right;
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width
                                                             color:AWColorFromRGB(201, 201, 201)
                                                            inView:self.contentView];
    line.position = CGPointMake(0, self.areaButton.bottom - 1);
    
    line = [AWHairlineView verticalLineWithHeight:self.areaButton.height
                                            color:AWColorFromRGB(201, 201, 201)
                                           inView:self.contentView];
    line.position = CGPointMake(self.areaButton.right, 0);
    
    UIView *captionView = [[UIView alloc] init];
    [self.contentView addSubview:captionView];
    
    self.captionView = captionView;
    
    captionView.backgroundColor = [UIColor whiteColor];
    captionView.frame = CGRectMake(0, self.areaButton.bottom, self.contentView.width, 108);
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(15, 10, self.contentView.width - 30, 44)];
    [captionView addSubview:self.searchBar];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.backgroundImage = AWImageFromColor([UIColor whiteColor]);
    self.searchBar.placeholder = @"输入合同名称、编号、单位名称搜索";
    self.searchBar.delegate = self;
    
    self.unconfirmButton = AWCreateTextButton(CGRectZero,
                                              @"当月未确认产值合同",
                                              MAIN_THEME_COLOR,
                                              self,
                                              @selector(btnClicked:));
    self.unconfirmButton.tag = 10011;
    
    self.confirmButton = AWCreateTextButton(CGRectZero,
                                            @"当月已确认产值合同",
                                            MAIN_THEME_COLOR,
                                            self,
                                            @selector(btnClicked:));
    [captionView addSubview:self.unconfirmButton];
    [captionView addSubview:self.confirmButton];
    
    self.confirmButton.tag = 10012;
    
    CGFloat width = (self.contentView.width - 15 * 3) / 2.0;
    
    self.unconfirmButton.frame = self.confirmButton.frame = CGRectMake(0, 0, width, 37);
    
    self.unconfirmButton.position = CGPointMake(15, self.searchBar.bottom + 5);
    self.confirmButton.position   = CGPointMake(self.unconfirmButton.right + 15,
                                                self.unconfirmButton.top);
    
    self.unconfirmButton.layer.cornerRadius = 6;
    self.unconfirmButton.layer.borderColor = [MAIN_THEME_COLOR CGColor];
    self.unconfirmButton.layer.borderWidth = 1;
    self.unconfirmButton.clipsToBounds = YES;
    self.unconfirmButton.backgroundColor = [UIColor whiteColor];
    
    self.confirmButton.layer.cornerRadius = 6;
    self.confirmButton.layer.borderColor = [MAIN_THEME_COLOR CGColor];
    self.confirmButton.layer.borderWidth = 1;
    self.confirmButton.clipsToBounds = YES;
    self.confirmButton.backgroundColor = [UIColor whiteColor];
    
    self.unconfirmButton.titleLabel.font = AWSystemFontWithSize(14, NO);
    self.confirmButton.titleLabel.font = AWSystemFontWithSize(14, NO);
}

- (void)btnClicked:(id)sender
{
    NSInteger tag = [sender tag];
    if ( tag == 10011 ) {
        self.queryParams.queryType = @"2";
    } else if (tag == 10012) {
        self.queryParams.queryType = @"3";
    }
    
    [self gotoConstract];
}

- (void)gotoConstract
{
    [self.searchBar resignFirstResponder];
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputContractListVC"
                                                                params:
                            @{ @"queryParams": self.queryParams,
                               @"areas": self.outputAreas,
                               @"projects": self.outputProjects,
                               @"currentArea": self.areaButton.userData ?: [NSNull null],
                               @"currentProject": self.projButton.userData ?: [NSNull null],
                               }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (DMButton *)areaButton
{
    if ( !_areaButton ) {
        _areaButton = [[DMButton alloc] init];
        [self.contentView addSubview:_areaButton];
        
        __weak typeof(self) me = self;
        _areaButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.outputAreas sender:sender];
        };
        
        _areaButton.title = @"成都";
    }
    return _areaButton;
}

- (DMButton *)projButton
{
    if ( !_projButton ) {
        _projButton = [[DMButton alloc] init];
        [self.contentView addSubview:_projButton];
        
        __weak typeof(self) me = self;
        _projButton.selectBlock = ^(DMButton *sender) {
            OutputArea *area = me.areaButton.userData;
            [me openPickerForData:me.outputProjects[area.areaId] sender:sender];
        };
        
        _projButton.title = @"枫丹一期";
    }
    return _projButton;
}

@end
