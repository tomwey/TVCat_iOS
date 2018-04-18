//
//  PayTimeView.h
//  HN_Vendor
//
//  Created by tomwey on 03/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayTimeView : UIView

- (void)showInView:(UIView *)superView atPosition:(CGPoint)position;

- (void)close;

@property (nonatomic, copy) NSString *beginDate;
@property (nonatomic, copy) NSString *endDate;

@property (nonatomic, copy) void (^didSelectDate)(PayTimeView *sender, NSDate *beginDate, NSDate *endDate);

@end
