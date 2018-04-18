//
//  DeclareFormVC.m
//  HN_Vendor
//
//  Created by tomwey on 26/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SignFormVC.h"
#import "Defines.h"

@interface SignFormVC ()

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *commitButton;

@property (nonatomic, strong) NSMutableArray *projects;

@property (nonatomic, strong) NSMutableDictionary *contracts;

@property (nonatomic, strong) NSMutableDictionary *contracts2;

@property (nonatomic, strong) NSMutableArray *changeEvents;

@property (nonatomic, strong) NSMutableArray *changeReason;

@property (nonatomic, assign) NSInteger counter;

@property (nonatomic, strong) NSMutableArray *inFormControls;

//@property (nonatomic, strong) NSDictionary *selectedContract;

@property (nonatomic, assign) NSInteger totalCounter;

@property (nonatomic, strong) NSArray *changeOptions;

@property (nonatomic, strong) id selectedContact;
@property (nonatomic, strong) id selectedChangeItem;

@end

@implementation SignFormVC

- (void)viewDidLoad {
    
    self.inFormControls =
    [@[
      @{
          @"data_type": @"9",
          @"datatype_c": @"下拉选",
          @"describe": @"项目名称",
          @"field_name": @"proj_name",
          @"item_name": @"枫丹铂麓一期",
          @"placeholder": @"选择项目",
          @"item_value": @"30",
          @"change_action": @"projectDidSelect:",
          },
      @{
          @"data_type": @"9",
          @"datatype_c": @"下拉选",
          @"describe": @"合同名称",
          @"field_name": @"contract_name",
          @"placeholder": @"选择合同",
          @"item_name": @"",
          @"item_value": @"",
          @"change_action": @"contractDidSelect:",
          },
      
      @{
          @"data_type": @"1",
          @"datatype_c": @"文本框",
          @"describe": @"合同金额",
          @"field_name": @"money",
          @"item_name": @"",
          @"item_value": @"",
          @"placeholder": @"请先选择合同",
          @"readonly": @"1",
          },
      @{
          @"data_type": @"1",
          @"datatype_c": @"文本框",
          @"describe": @"合同编号",
          @"field_name": @"contract_no",
          @"item_name": @"",
          @"item_value": @"",
          @"readonly": @"1",
          @"placeholder": @"请先选择合同",
          },
      @{
          @"data_type": @"20",
          @"datatype_c": @"打开新页面",
          @"describe": @"指令/变更主题",
          @"field_name": @"sign_subject",
          @"item_name": @"",
          @"item_value": @"",
          @"open_action": @"openSelect:",
          },
      @{
          @"data_type": @"1",
          @"datatype_c": @"文本框",
          @"describe": @"签证名称",
          @"field_name": @"sign_name",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"1",
          @"datatype_c": @"文本框",
          @"describe": @"申报金额(元)",
          @"field_name": @"money2",
          @"item_name": @"",
          @"item_value": @"",
          @"keyboard_type": @(UIKeyboardTypeNumbersAndPunctuation),
          },
      @{
          @"data_type": @"1",
          @"datatype_c": @"文本框",
          @"describe": @"签证目前进展说明",
          @"field_name": @"sign_desc",
          @"item_name": @"",
          @"item_value": @"",
          @"placeholder": @"进展说明"
          },
      @{
          @"data_type": @"1",
          @"datatype_c": @"文本框",
          @"describe": @"签证产生原因说明",
          @"field_name": @"sign_reason",
          @"item_name": @"",
          @"item_value": @"",
          @"placeholder": @"原因说明"
          },
      @{
          @"data_type": @"10",
          @"datatype_c": @"多行文本",
          @"describe": @"变更内容",
          @"field_name": @"sign_content",
          @"item_name": @"",
          @"item_value": @"",
          },
      @{
          @"data_type": @"19",
          @"datatype_c": @"上传组件",
          @"describe": @"照片",
          @"field_name": @"photos",
          @"item_name": @"",
          @"item_value": @"",
          @"annex_table_name": @"H_APP_Supplier_Contract_Change_Annex",
          @"annex_field_name": @"AnnexKeyID",
//          @"required": @"0",
          },
      ] mutableCopy];
    
    [super viewDidLoad];
    
    self.projects = [@[] mutableCopy];
    self.contracts = [@{} mutableCopy];
    self.contracts2 = [@{} mutableCopy];
    self.changeReason = [@[] mutableCopy];
    self.changeEvents = [@[] mutableCopy];
    
    self.navBar.title = self.params[@"title"] ?: @"";
    
    [self addLeftItemWithView:HNCloseButton(34, self, @selector(close))];
    
    if (!self.params[@"state_num"] || [self.params[@"canvisa"] boolValue]) {
        // 新建
        self.disableFormInputs = NO;
        self.totalCounter = 3;
        
        [self addToolButtons];
    } else {
        // 添加状态显示
        self.totalCounter = 4; // 加载附件
        
        if ([self.params[@"state_num"] integerValue] == 0) {
            // 待申报
            self.disableFormInputs = NO;
            [self addToolButtons];
        } else if ( [self.params[@"state_num"] integerValue] == 10 ) {
            // 已申报
            self.disableFormInputs = YES;
            [self addCancelButton];
        } else {
            self.disableFormInputs = YES;
        }
        
        if ( [self.params[@"state_num"] integerValue] >= 40 ) {
            // 已申报
            [self.inFormControls insertObject:      @{
                                                      @"data_type": @"1",
                                                      @"datatype_c": @"文本框",
                                                      @"describe": @"核定金额(元)",
                                                      @"field_name": @"money3",
                                                      @"item_name": @"",
                                                      @"item_value": @"",
//                                                      @"readonly": @"1",
                                                      @"keyboard_type": @(UIKeyboardTypeNumberPad),
                                                      } atIndex:7];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self loadData];
}

- (void)addCancelButton
{
    UIButton *cancelBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width,
                                  50),
                       @"取消",
                       [UIColor whiteColor],
                       self,
                       @selector(cancelClick));
    [self.contentView addSubview:cancelBtn];
    cancelBtn.backgroundColor = MAIN_THEME_COLOR;
    cancelBtn.position = CGPointMake(0, self.contentView.height - 50);
    
    self.tableView.height -= cancelBtn.height;
}

- (void)addToolButtons
{
    UIButton *commitBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                        50),
                                             @"提交",
                                             [UIColor whiteColor],
                                             self,
                                             @selector(commit));
    [self.contentView addSubview:commitBtn];
    commitBtn.backgroundColor = MAIN_THEME_COLOR;
    commitBtn.position = CGPointMake(0, self.contentView.height - 50);
    
    self.commitButton = commitBtn;
    
    UIButton *moreBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
                                                      50),
                                           @"保存",
                                           MAIN_THEME_COLOR,
                                           self,
                                           @selector(save));
    [self.contentView addSubview:moreBtn];
    moreBtn.backgroundColor = [UIColor whiteColor];
    moreBtn.position = CGPointMake(commitBtn.right, self.contentView.height - 50);
    
    self.saveButton = moreBtn;
    
    UIView *hairLine = [AWHairlineView horizontalLineWithWidth:moreBtn.width
                                                         color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                        inView:moreBtn];
    hairLine.position = CGPointMake(0,0);
    
    commitBtn.left = 0;
    moreBtn.left = commitBtn.right;
    
    self.tableView.height -= moreBtn.height;
}

- (void)prepareFormObjects
{
//    addmoney = NULL;
//    contractid = 2203231;
//    contractmoney = "1681393.39";
//    contractname = "\U67ab\U4e39\U94c2\U9e93\U4e00\U671f1\U30017\U30018\U30019\U53f7\U697c\U516c\U5171\U533a\U57df\U88c5\U9970\U5de5\U7a0b\U5408\U540c";
//    contractphyno = "\U5408\Uff08WA\Uff09-E214-2017-015";
//    "flow_mid" = NULL;
//    order = 1;
//    "project_id" = 1290827;
//    "project_name" = "\U67ab\U4e39\U94c2\U9e93\U4e00\U671f";
//    "state_desc" = "\U5f85\U7533\U62a5";
//    "state_num" = 0;
//    supchangeid = 0;
//    supvisaid = 4011;
//    visaappmoney = 987654321;
//    visaconfrimmoney = NULL;
//    visacontent = "";
//    visadate = "2018-03-16T10:23:29+08:00";
//    visaprogress = "\U521a\U5f00\U59cb\U8fdb\U5c55";
//    visareason = "\U6ca1\U5f97\U539f\U56e0";
//    visatheme = "\U6709\U7167\U7247\U7684";
    
    if ( self.params[@"supvisaid"] || [self.params[@"canvisa"] boolValue] ) {
        self.formObjects[@"proj_name"] = @{ @"name": self.params[@"project_name"] ?: @"",
                                            @"value": [self.params[@"project_name"] ?: @"" description],
                                            };
        [self projectDidSelect:self.formObjects[@"proj_name"]];
        
        self.formObjects[@"contract_name"] = @{
                                               @"name": self.params[@"contractname"] ?: @"",
                                               @"value": [self.params[@"contractid"] ?: @"" description],
                                               };
        
        if (self.formObjects[@"contract_name"]) {
            self.selectedContact = self.formObjects[@"contract_name"];
        }
        
        self.formObjects[@"money"] = self.params[@"contractmoney"];
        self.formObjects[@"contract_no"] = self.params[@"contractphyno"];
        
        self.formObjects[@"sign_subject"] = @{ @"name": self.params[@"changetheme"] ?: @"", @"value": self.params[@"supchangeid"] ?: @"0" };
        
        self.selectedChangeItem = self.formObjects[@"sign_subject"];
        
        self.formObjects[@"sign_content"] = self.params[@"visacontent"] ?: @"";
        self.formObjects[@"money2"] = self.params[@"visaappmoney"] ?: @"";
        self.formObjects[@"money3"] = @([self.params[@"visaconfrimmoney"] floatValue]);
        
        self.formObjects[@"sign_desc"] = self.params[@"visaprogress"] ?: @"";
        
        self.formObjects[@"sign_reason"] = self.params[@"visareason"] ?: @"";
        
        self.formObjects[@"sign_name"] = self.params[@"visatheme"] ?: @"";
        
    } else {
        
    }
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    
    id userInfo = [[UserService sharedInstance] currentUser];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商查询合同列表APP",
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": [userInfo[@"loginname"] ?: @"" description],
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              } completion:^(id result, NSError *error) {
                  [me loadDone1:result error:error];
              }];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商取值列表数据查询APP",
              @"param1": @"变更事项进展"
              } completion:^(id result, NSError *error) {
                  [me loadDone2:result error: error];
              }];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商取值列表数据查询APP",
              @"param1": @"变更原因"
              } completion:^(id result, NSError *error) {
                  [me loadDone3:result error: error];
              }];
    
    if ( self.totalCounter == 4 ) { // 需要加载附件列表
        [[self apiServiceWithName:@"APIService"]
         POST:nil
         params:@{
                  @"dotype": @"GetData",
                  @"funname": @"供应商查询变更指令附件APP",
                  @"param1": [userInfo[@"supid"] ?: @"0" description],
                  @"param2": [userInfo[@"loginname"] ?: @"" description],
                  @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
                  @"param4": [self.params[@"supvisaid"] ?: @"0" description],
                  @"param5": @"11",
                  } completion:^(id result, NSError *error) {
                      [me loadDone4:result error:error];
                  }];
    }
    
}

- (void)loadDone4:(id)result error:(NSError *)error
{
//    annexkeyid = 285434;
//    annextype = NULL;
//    annexurl = "hnapp://open-file?file=http://erp20-app.heneng.cn:16681/office/erp20-annex.heneng.cn/H_APP_Supplier_Contract_Change_Annex/2017-12-29/285434/wopi/files/285434.png&filename=IMG_0295.PNG&fileid=285434&isdoc=0";
//    "create_date" = "2017-12-29T11:05:40+08:00";
//    "create_id" = NULL;
//    deleted = 0;
//    "edit_date" = NULL;
//    "edit_id" = NULL;
//    isvalid = 1;
//    supchangeannexid = 24;
//    supchangeid = 12;
    if ( [result[@"rowcount"] integerValue] > 0 && result[@"data"] ) {
        NSMutableArray *temp = [NSMutableArray array];
        NSArray *array = result[@"data"];
        for (id obj in array) {
            id ID = obj[@"annexkeyid"] ?: @"0";
            NSString *imageUrl = [[obj[@"annexurl"] componentsSeparatedByString:@"?"] lastObject];
            NSDictionary *params = [imageUrl queryDictionaryUsingEncoding:NSUTF8StringEncoding];
            imageUrl = [params[@"file"] stringByAppendingPathComponent:@"contents"];
            
            id item = @{ @"id": ID, @"imageURL": imageUrl };
            [temp addObject:item];
        }
        
        self.formObjects[@"photos"] = temp;
    }
    
    [self loadDone];
}

- (void)loadDone1:(id)result error:(NSError *)error
{
    if ( [result[@"rowcount"] integerValue] > 0 ) {
        NSArray *data = result[@"data"];
        
//        appstatus = 40;
//        appstatusdesc = "\U6267\U884c\U4e2d";
//        contractid = 2206412;
//        contractmoney = 1957620;
//        contractname = "\U5173\U4e8e\U4ee5\U73cd\U5b9d\U4e00\U671f\U9879\U76ee\U5546\U54c1\U623f\U4f5c\U4ef7\U652f\U4ed8\U4e00\U671f\U9879\U76ee\U63a8\U4ecb\U670d\U52a1\U8d39\U7684\U534f\U8bae\U4e66";
//        contractphyno = "\U5408\Uff08JC\Uff09-E312-2017-003";
//        contractsysno = "\U5408\Uff08JC\Uff09-E312-2017-003";
//        "project_name" = "\U73cd\U5b9d\U9526\U57ce\U4e00\U671f";
//        signdate = "2017-06-02T00:00:00+08:00";
        
        for (id item in data) {
            if (item && item[@"contractid"]) {
                self.contracts2[[item[@"contractid"] description]] = item;
            }
            
            NSString *projName = item[@"project_name"];
            if ( !projName ) {
                continue;
            }
            
//            [self.projects addObject:projName];
            
            NSMutableArray *obj = self.contracts[projName];
            if ( !obj ) {
                obj = [[NSMutableArray alloc] init];
                self.contracts[projName] = obj;
                
                [self.projects addObject:projName];
                
                [obj addObject:item];
            } else {
                [obj addObject:item];
            }
            
//            if ( ![obj containsObject:item] ) {
//                [obj addObject:item];
//            }
        }
    }
    
    [self loadDone];
}

- (void)loadDone2:(id)result error:(NSError *)error
{
    if ( [result[@"rowcount"] integerValue] > 0 ) {
        for (id item in result[@"data"]) {
            [self.changeEvents addObject:@{
                                           @"name": item[@"dic_name"] ?: @"",
                                           @"value": item[@"dic_value"] ?: @"",
                                           }];
        }
    }
    
    [self loadDone];
}

- (void)loadDone3:(id)result error:(NSError *)error
{
    if ( [result[@"rowcount"] integerValue] > 0 ) {
//        self.changeReason = [result[@"data"] mutableCopy];
        for (id item in result[@"data"]) {
            [self.changeReason addObject:@{
                                           @"name": item[@"dic_name"] ?: @"",
                                           @"value": item[@"dic_value"] ?: @"",
                                           }];
        }
    }
    
    [self loadDone];
}

- (void)projectDidSelect:(id)selectedItem
{
    [self.formObjects removeObjectForKey:@"contract_name"];
    [self.formObjects removeObjectForKey:@"money"];
    [self.formObjects removeObjectForKey:@"contract_no"];
    
    [self populateData:selectedItem];
    
    [self formControlsDidChange];
}

- (void)populateData:(id)selectedItem
{
    NSArray *array = self.contracts[selectedItem[@"name"]];
    
    NSMutableArray *temp1 = [NSMutableArray array];
    NSMutableArray *temp2 = [NSMutableArray array];
    for (id item in array) {
        [temp1 addObject:item[@"contractname"]];
        [temp2 addObject:item[@"contractid"]];
    }
    
    id dict = [self.inFormControls objectAtIndex:1];
    NSMutableDictionary *newDict = [dict mutableCopy];
    newDict[@"item_name"] = [temp1 componentsJoinedByString:@","];
    newDict[@"item_value"] = [temp2 componentsJoinedByString:@","];
    [self.inFormControls replaceObjectAtIndex:1 withObject:newDict];
}

- (void)contractDidSelect:(id)selectedItem
{
    id item = self.contracts2[[selectedItem[@"value"] description]];
    self.selectedContact = selectedItem;
    
    if (item) {
        [self.formObjects removeObjectForKey:@"sign_subject"];
        
        self.formObjects[@"contract_no"] = item[@"contractphyno"];
        self.formObjects[@"money"] = item[@"contractmoney"];
        
//        [self formControlsDidChange];
        [self.tableView reloadData];
        
//        [self loadData2:[selectedItem[@"value"] description]];
    }
}

- (void)openSelect:(id)item
{
    if ( [self.params[@"canvisa"] boolValue] ) {
        return;
    }
    
    if ( !self.selectedContact ) {
        [self.contentView showHUDWithText:@"请先选择合同" offset:CGPointMake(0,20)];
        return;
    }
    
    __weak typeof(self) me = self;
    void (^selectCallback)(id data) = ^(id data) {
        me.formObjects[@"sign_subject"] = @{ @"name": data[@"changetheme"] ?: @"", @"value": [data[@"supchangeid"] ?: @"0" description] };
        [me.tableView reloadData];
    };
    
    NSMutableDictionary *dict = [@{
                                  @"contract_id": [self.selectedContact[@"value"] description],
                                  @"selectCallback": selectCallback,
                                  } mutableCopy];
    if ( item || self.selectedChangeItem ) {
        [dict setObject:item ?: self.selectedChangeItem forKey:@"item"];
    }
    
    UIViewController *vc = [[AWMediator sharedInstance] openNavVCWithName:@"SignOptionsVC" params:dict];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadData2:(NSString *)contractNo
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商可发起签证的变更列表APP",
              @"param1": contractNo ?: @"",
              @"param2": @"40",
              @"param3": @"0"
              } completion:^(id result, NSError *error) {
//                  [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
//
//                  if ( [result[@"rowcount"] integerValue] != 0 ) {
//                      self.changeOptions = result[@"data"];
//                  } else {
//                      self.changeOptions = nil;
//                  }
                  [me handleResult2:result error:error];
              }];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    id dict = [self.inFormControls objectAtIndex:4];
    NSMutableDictionary *newDict = [dict mutableCopy];
    
    if ([result[@"rowcount"] integerValue] > 0) {
        NSMutableArray *temp1 = [NSMutableArray array];
        NSMutableArray *temp2 = [NSMutableArray array];
        for (id item in result[@"data"]) {
            [temp1 addObject:item[@"changetheme"]];
            [temp2 addObject:item[@"supchangeid"]];
        }
        newDict[@"item_name"] = [temp1 componentsJoinedByString:@","];
        newDict[@"item_value"] = [temp2 componentsJoinedByString:@","];
    } else {
        newDict[@"item_name"] = @"";
        newDict[@"item_value"] = @"";
    }
    
    [self.inFormControls replaceObjectAtIndex:4 withObject:newDict];
    
    [self formControlsDidChange];
}

- (void)loadDone
{
    self.counter ++;
    
    if ( self.counter == self.totalCounter ) {
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        
        id dict = [self.inFormControls objectAtIndex:0];
        NSMutableDictionary *newDict = [dict mutableCopy];
        newDict[@"item_name"] = [self.projects componentsJoinedByString:@","];
        newDict[@"item_value"] = [self.projects componentsJoinedByString:@","];
        [self.inFormControls replaceObjectAtIndex:0 withObject:newDict];
        
        ///
//        dict = [self.inFormControls objectAtIndex:5];
//        NSMutableArray *temp1 = [NSMutableArray array];
//        NSMutableArray *temp2 = [NSMutableArray array];
//        for (id item in self.changeEvents) {
//            [temp1 addObject:item[@"name"]];
//            [temp2 addObject:item[@"value"]];
//        }
//
//        newDict = [dict mutableCopy];
//        newDict[@"item_name"] = [temp1 componentsJoinedByString:@","];
//        newDict[@"item_value"] = [temp2 componentsJoinedByString:@","];
//
//        [self.inFormControls replaceObjectAtIndex:5 withObject:newDict];
//
//
//        ////
//        dict = [self.inFormControls objectAtIndex:6];
//        temp1 = [NSMutableArray array];
//        temp2 = [NSMutableArray array];
//        for (id item in self.changeReason) {
//            [temp1 addObject:item[@"name"]];
//            [temp2 addObject:item[@"value"]];
//        }
//
//        newDict = [dict mutableCopy];
//        newDict[@"item_name"] = [temp1 componentsJoinedByString:@","];
//        newDict[@"item_value"] = [temp2 componentsJoinedByString:@","];
//
//        [self.inFormControls replaceObjectAtIndex:6 withObject:newDict];
        
        [self formControlsDidChange];
    }
    
    [self prepareFormObjects];
}

//@iSupID bigint,
//@sLoginName varchar(30),
//@iSymbolKeyID bigint,
//@iOperateType int, --1保存草稿  2-提交   3--删除   4-取消
//@iChangeID bigint,--变更/指令ID  新建的变更/指令则为0
//@sChangeType varchar(20), --变更/指令
//@iContractID bigint,--合同ID
//@sTheme varchar(500), --主题
//@sProgress varchar(30),--事项当前进展
//@iChangeReasonID bigint,--变更/指令原因
//@dChangeMoney decimal(18,2),--变更金额
//@sContentDesc varchar(8000),--变更内容
//@sAnnexIDs varchar(500)='',--附件/图片ID

+ (BOOL)isValidMoney:(NSString *)str{
    NSString * regex        = @"((-?\\d+)(\\.\\d+)?)|(-?\\d+)";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch            = [pred evaluateWithObject:str];
    //
    //    if ( isMatch ) {
    //        return YES;
    //    }
    //
    //    // 匹配浮点数
    //    regex   = @"(/^-?([1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*|0?\\.0+|0)$/)";
    //    pred    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    //    isMatch = [pred evaluateWithObject:str];
    //
    return isMatch;
}

- (void)sendReqForType:(NSInteger)type
{
    // 合同
    NSString *contractID = @"";
    if ( self.formObjects[@"contract_name"] ) {
        contractID = [self.formObjects[@"contract_name"][@"value"] description];
    }
    if ( contractID.length == 0 ) {
        [self.contentView showHUDWithText:@"必须选择合同" offset:CGPointMake(0,20)];
        return;
    }
    
    NSString *changeID = @"";
    if ( self.formObjects[@"sign_subject"] ) {
        changeID = [self.formObjects[@"sign_subject"][@"value"] description];
    }
    
    if (changeID.length == 0) {
        [self.contentView showHUDWithText:@"必须选择指令/变更主题" offset:CGPointMake(0,20)];
        return;
    }
    
    // 主题
    NSString *theme = self.formObjects[@"sign_name"] ?: @"";
    theme = [theme trim];
    if ( theme.length == 0 ) {
        [self.contentView showHUDWithText:@"签证主题不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    NSString *summary = self.formObjects[@"sign_desc"] ?: @"";
    summary = [summary trim];
    if ( summary.length == 0 ) {
        [self.contentView showHUDWithText:@"进展说明不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    
    NSString *reason = self.formObjects[@"sign_reason"] ?: @"";
    reason = [reason trim];
    if ( reason.length == 0 ) {
        [self.contentView showHUDWithText:@"产生原因不能为空" offset:CGPointMake(0,20)];
        return;
    }
    

    // 变更金额
    NSString *money = [self.formObjects[@"money2"] ?: @"" description];
    if ( money.length == 0 ) {
        [self.contentView showHUDWithText:@"申报金额不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    if ( ![[self class] isValidMoney:money] ) {
        [self.contentView showHUDWithText:@"不是一个正确的金额" offset:CGPointMake(0,20)];
        return;
    }
    
    NSString *content = [self.formObjects[@"sign_content"] ?: @"" description];
    if ( content.length == 0 ) {
        [self.contentView showHUDWithText:@"签证内容不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    // 附件
    NSArray *photos = self.formObjects[@"photos"] ?: @[];
    if ( photos.count == 0 ) {
        [self.contentView showHUDWithText:@"至少需要上传一张图片" offset:CGPointMake(0,20)];
        return;
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    for (id p in photos) {
        [temp addObject:[p[@"id"] ?: @"" description]];
    }
    
    NSString *IDs = [temp componentsJoinedByString:@","];
    
    // 发请求
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id userInfo = [[UserService sharedInstance] currentUser];
    
    NSString *visaID = [self.params[@"supvisaid"] ?: @"0" description];
    
    [self hideKeyboard];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商发起变更签证APP",
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": [userInfo[@"loginname"] ?: @"" description],
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              @"param4": [@(type) description],
              @"param5": visaID,
              @"param6": changeID,
              @"param7": contractID,
              @"param8": theme,
              @"param9": @"1",
              @"param10": summary,
              @"param11": reason,
              @"param12": money,
              @"param13": content,
              @"param14": IDs,
              @"param15": @"1"
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
//        NSLog(@"error: %@", error);
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            
        } else {
            id item = [result[@"data"] firstObject];
            if ( [item[@"hinttype"] integerValue] == 1 ||
                (item[@"code"] && [item[@"code"] integerValue] == 0) ||
                ([[[item allValues] firstObject] integerValue] == 1) ) {
                NSString *msg = item[@"hint"] ?: @"操作成功";
                [AWAppWindow() showHUDWithText:msg succeed:YES];
                
                if ( self.params[@"_flag"] ) {
//                    [self.presentingViewController dismissViewControllerAnimated:YES
//                                                                  completion:^{
//                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"kReloadDeclareDataNotification" object:nil];
//                                                                  }];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNeedDismissNotification"
                                                                        object:nil];
                } else {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kReloadDeclareDataNotification" object:nil];
                    }];
                }
                
            } else {
                [self.contentView showHUDWithText:item[@"hint"] succeed:NO];
            }
        }
    }
}

- (void)commit
{
//    NSLog(@"%@", self.formObjects);
    [self sendReqForType:2];
}

- (void)cancelClick
{
    [self sendReqForType:4];
}

- (void)save
{
//    NSLog(@"%@", self.formObjects)
    [self sendReqForType:1];
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    [super keyboardWillShow:noti];
    
    NSDictionary *userInfo = noti.userInfo;
    CGRect frame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.commitButton.top =
        self.saveButton.top =
        self.contentView.height - CGRectGetHeight(frame) - self.commitButton.height;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    [super keyboardWillHide:noti];
    
    NSDictionary *userInfo = noti.userInfo;
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.commitButton.top =
        self.saveButton.top =
        self.contentView.height - self.commitButton.height;
    } completion:^(BOOL finished) {
        
    }];
}

- (NSArray *)formControls
{
    return self.inFormControls;
}

- (BOOL)supportsTextArea
{
    return NO;
}

- (BOOL)supportsAttachment
{
    return NO;
}

- (BOOL)supportsCustomOpinion
{
    return NO;
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
