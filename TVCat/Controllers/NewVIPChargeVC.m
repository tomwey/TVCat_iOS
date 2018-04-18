//
//  NewVIPChargeVC.m
//  TVCat
//
//  Created by tomwey on 18/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "NewVIPChargeVC.h"
#import "Defines.h"

@interface NewVIPChargeVC ()

@property (nonatomic, weak) UITextField *codeField;

@end

@implementation NewVIPChargeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"新增VIP充值";
    
    [self addLeftItemWithView:HNCloseButton(34, self, @selector(close))];
    
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, self.contentView.width - 30, 120)];
    [self.contentView addSubview:boxView];
    boxView.backgroundColor = [UIColor whiteColor];
    
    AWTextField *textField = [[AWTextField alloc] initWithFrame:CGRectMake(10, 10, boxView.width - 20,
                                                                           40)];
    [boxView addSubview:textField];
    
    textField.tintColor = MAIN_THEME_COLOR;
    
    self.codeField = textField;
    
    textField.cornerRadius = 0;
    
    textField.placeholder = @"输入VIP激活码";
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
    textField.layer.borderColor = AWColorFromHex(@"#e6e6e6").CGColor;
    textField.layer.borderWidth = 0.88;
    
    UIButton *okButton = AWCreateTextButton(textField.frame, @"确认激活",
                                      [UIColor whiteColor],
                                      self,
                                      @selector(commit));
    [boxView addSubview:okButton];
    
    okButton.top = textField.bottom + 20;
    
    okButton.backgroundColor = MAIN_THEME_COLOR;
    okButton.titleLabel.font = AWSystemFontWithSize(14, NO);
    
}

- (void)commit
{
    if ([self.codeField.text trim].length == 0) {
        [self.contentView showHUDWithText:@"激活码不能为空"];
        return;
    }
    
    [self.codeField resignFirstResponder];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [[CatService sharedInstance] activeVIPCode:[self.codeField.text trim] completion:^(id result, NSError *error) {
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        if ( error ) {
            [self.contentView showHUDWithText:error.domain succeed:NO];
        } else {
            [AWAppWindow() showHUDWithText:@"VIP激活成功" succeed:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kVIPActiveSuccessNotification" object:nil];
            
            [self close];
        }
    }];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
