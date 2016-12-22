//
//  SCLoginVerifyView.m
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/22.
//  Copyright © 2016年 小广. All rights reserved.
//  手势/TouchID登录验证的view

#import "SCLoginVerifyView.h"
#import "MYZGestureView.h"
#import "MYZCircleView.h"
#import "MYZGestureShapeView.h"
#import "CALayer+shake.h"
#import "SCSecureHelper.h"

NSString * const passwordErrorMessage =    @"手势密码错误";

#define MarginTop     64.0
#define Margin        15.0
#define BottomHeight  44.0
#define HeadWH        80.0
#define TouchIDHeight  100.0


@interface SCLoginVerifyView ()
/// 手势九宫格
@property (nonatomic, strong) MYZGestureView * gestureView;
/// 手势错误的提示
@property (nonatomic, strong) UILabel * messageLabel;
/// 顶部的头像按钮
@property (nonatomic, strong) UIImageView *headImageView;
/// 底部的切换登录方式按钮
@property (nonatomic, strong) UIButton * bottomButton;
/// 指纹验证按钮
@property (nonatomic, strong) UIButton * touchIDButton;
@property (nonatomic, assign) SCLoginVerifyType  verifyType;
@property (nonatomic, assign) SCLoginVerifyBlock  block;

/// 防止按钮重复点击
@property (nonatomic, assign) BOOL bottomBtnClick;
@property (nonatomic, assign) BOOL touchBtnClick;



@end

@implementation SCLoginVerifyView

#pragma mark -  初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 默认指纹密码登录
        _verifyType = SCLoginVerifyTypeTouchID;
        [self layoutUI:_verifyType];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame verifyType:(SCLoginVerifyType)verifyType {
    self = [super initWithFrame:frame];
    if (self) {
        _verifyType = verifyType;
        [self layoutUI:verifyType];
    }
    return self;
}

#pragma mark - 对外方法
/// 验证结果的回调
- (void)loginVerifyResult:(SCLoginVerifyBlock)block {
    self.block = block;
}

/// 显示view(此方法是加载在window上 ,遮住导航条)
- (void)showView {
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self];
}

#pragma mark - 布局UI
/// 根据验证类型布局UI
- (void)layoutUI:(SCLoginVerifyType)verifyType {
    self.backgroundColor = [UIColor whiteColor];
    // 顶部的头像和底部的切换登录方式按钮，是共有的
    // 头像
    if (!_headImageView) {
        CGFloat posX = (ScreenWidth - HeadWH) * 0.5;
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(posX, MarginTop, HeadWH, HeadWH)];
        _headImageView.clipsToBounds = YES;
        _headImageView.layer.cornerRadius = HeadWH * 0.5;
    }
    _headImageView.image = [UIImage imageNamed:@"head_Img.JPG"];
    [self addSubview:_headImageView];
    
    // 底部按钮
    
    if (!_bottomButton) {
        CGFloat posY = ScreenHeight - BottomHeight * 1.5;
        _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomButton.backgroundColor = [UIColor clearColor];
        _bottomButton.frame = CGRectMake(0.0, posY, ScreenWidth, BottomHeight);
        _bottomButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_bottomButton setTitleColor:UIColorFrom16RGB(0x3393F2, 1.0) forState:UIControlStateNormal];
        [_bottomButton setTitle:@"切换其他账号登录" forState:UIControlStateNormal];
    }
    [_bottomButton addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_bottomButton];
    
    
    switch (verifyType) {
            
        case SCLoginVerifyTypeTouchID:
            // 指纹密码登录
            [self loginVerifyTouchID];
            break;
            
        case SCLoginVerifyTypeGesture:
            // 手势密码登录
            [self loginVerifyGesture];
            break;
            
        default:
            break;
    }
}

/// 指纹密码登录
- (void)loginVerifyTouchID {
    if (!_touchIDButton) {
        CGFloat posY = CGRectGetMaxY(_headImageView.frame) + TouchIDHeight;
        UIButton *touchIDButton = [UIButton buttonWithType:UIButtonTypeCustom];
        touchIDButton.frame = CGRectMake(0.0, posY, ScreenWidth, TouchIDHeight);
        touchIDButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        touchIDButton.imageEdgeInsets = UIEdgeInsetsMake(-30.0, 100.0, 0.0, 0.0); // 上左下右
        touchIDButton.titleEdgeInsets = UIEdgeInsetsMake(50.0, -40.0, 0.0, 0.0);
        [touchIDButton setTitleColor:UIColorFrom16RGB(0x3393F2, 1.0) forState:UIControlStateNormal];
        [touchIDButton setImage:[UIImage imageNamed:@"fingerprint"] forState:UIControlStateNormal];
        [touchIDButton setTitle:@"点击进行指纹解锁" forState:UIControlStateNormal];
        _touchIDButton = touchIDButton;
    }
    [_touchIDButton addTarget:self action:@selector(touchIDButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_touchIDButton];
    [self touchIDButtonAction:_touchIDButton];
}

/// 手势密码登录
- (void)loginVerifyGesture {
    
    // 错误的警告Label
    if (!_messageLabel) {
        CGFloat labelY = CGRectGetMaxY(self.headImageView.frame) + Margin;
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, labelY, ScreenWidth, LabelHeight)];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:15.0];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = SCCircleErrorColor;
    }
    [self addSubview:_messageLabel];
    
    // 手势九宫格
    if (!_gestureView) {
        CGFloat gestureViewX = (ScreenWidth - GestureWH) * 0.5;
        CGFloat gestureViewY = CGRectGetMaxY(self.messageLabel.frame) + LabelHeight;
        _gestureView = [[MYZGestureView alloc] initWithFrame:CGRectMake(gestureViewX, gestureViewY, GestureWH, GestureWH)];
    }
    //是否显示指示手势划过的方向箭头, 在初始设置手势密码的时候才显示, 其他的不用显示
    _gestureView.showArrowDirection = [SCSecureHelper gestureShowStatus];
    [self addSubview:_gestureView];
    
    kWeakSelf
    [self.gestureView setGestureResult:^BOOL(NSString *gestureCode) {
        return [weakSelf gestureResult:gestureCode];
    }];
    
}

#pragma mark - 内部方法

// 手势密码结果的处理
- (BOOL)gestureResult:(NSString *)gestureCode {
    
    if (gestureCode.length >= 4) {
        // 验证原密码
        NSString * saveGestureCode = [SCSecureHelper gainGestureCodeKey];
        if ([gestureCode isEqualToString:saveGestureCode]) {
            // 验证成功 进行进一步处理
            [self dismiss];
            return YES;
        }
        // 错误就提醒
        [self showGestureCodeErrorMessage];
    } else {
        [self showGestureCodeErrorMessage];
    }
    
    return NO;
}

/// 手势密码错误的提示
- (void)showGestureCodeErrorMessage {
    self.messageLabel.text =  passwordErrorMessage;
    self.messageLabel.textColor = SCCircleErrorColor;
    [self.messageLabel.layer shake];
}

/// 移除view
- (void)dismiss {
    kWeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - action事件

// 进行指纹解锁按钮的action
- (void)touchIDButtonAction:(UIButton *)sender {
    if (self.touchBtnClick) {
        return;
    }
    self.touchBtnClick = YES;
    kWeakSelf
    [[SCSecureHelper shareInstance] openTouchID:^(BOOL success, BOOL inputPassword, NSString *message) {
        weakSelf.touchBtnClick = NO;
        if (success) {
            [weakSelf dismiss];
        }
    }];
    
}

// 切换其他账号登录
- (void)bottomButtonAction:(UIButton *)sender {
    if (self.bottomBtnClick) {
        return;
    }
    self.bottomBtnClick = YES;
    [self dismiss];
    self.bottomBtnClick = NO;
}



@end
