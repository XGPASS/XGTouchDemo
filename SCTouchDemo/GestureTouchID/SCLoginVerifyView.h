//
//  SCLoginVerifyView.h
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/22.
//  Copyright © 2016年 小广. All rights reserved.
//  手势/TouchID登录验证的view

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCLoginVerifyType) {
    SCLoginVerifyTypeTouchID,   // 指纹密码验证登录
    SCLoginVerifyTypeGesture    // 手势密码验证登录
};

typedef void(^SCLoginVerifyBlock)(BOOL success);

@interface SCLoginVerifyView : UIView

- (instancetype)initWithFrame:(CGRect)frame verifyType:(SCLoginVerifyType)verifyType;

/// 显示view
- (void)showView;

/// 验证结果的回调
- (void)loginVerifyResult:(SCLoginVerifyBlock)block;

@end
