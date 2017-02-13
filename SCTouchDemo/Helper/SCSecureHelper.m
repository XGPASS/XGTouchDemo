//
//  SCSecureHelper.m
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/21.
//  Copyright © 2016年 小广. All rights reserved.
//

#import "SCSecureHelper.h"
#import <LocalAuthentication/LocalAuthentication.h>

// ios 版本判断
#define SCSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define iOS9 (SCSystemVersion >= 9.0)

@interface SCSecureHelper ()

@property (nonatomic, copy) SCTouchIDOpenBlock block;

@end

@implementation SCSecureHelper

/// 单例
+ (SCSecureHelper *)shareInstance {
    
    static SCSecureHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[SCSecureHelper alloc] init];
    });
    return helper;
}

#pragma mark - 手势密码（Public）
/// 手势密码的开启状态
+ (BOOL)gestureOpenStatus {
    NSNumber *tempNum = [[NSUserDefaults standardUserDefaults] objectForKey:Gesture_Password_Open];
    BOOL gestureOpen = tempNum ? [tempNum boolValue] : NO;
    return gestureOpen;
}

/// 手势密码轨迹显示开启状态
+ (BOOL)gestureShowStatus {
    NSNumber *tempNum = [[NSUserDefaults standardUserDefaults] objectForKey:Gesture_Password_Show];
    BOOL gestureShow = tempNum ? [tempNum boolValue] : NO;
    return gestureShow;
}

/// 关闭/开启手势密码
+ (void)openGesture:(BOOL)open {
    
    NSNumber *tempNum = open ? @(1) : @(0);
    [[NSUserDefaults standardUserDefaults] setObject:tempNum forKey:Gesture_Password_Open];
    [[NSUserDefaults standardUserDefaults] setObject:tempNum forKey:Gesture_Password_Show];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (!open) {
        [self saveGestureCodeKey:nil];
    }
}

/// 关闭/开启手势密码
+ (void)openGestureShow:(BOOL)open {
    NSNumber *tempNum = open ? @(1) : @(0);
    [[NSUserDefaults standardUserDefaults] setObject:tempNum forKey:Gesture_Password_Show];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// 获取保存手势密码的code
+ (NSString *)gainGestureCodeKey {
    NSString *gestureCode = [[NSUserDefaults standardUserDefaults] objectForKey:Gesture_Code_Key];
    return gestureCode ? gestureCode : @"";
}
/// 保存手势密码的code
+ (void)saveGestureCodeKey:(NSString *)gestureCode {
    [[NSUserDefaults standardUserDefaults] setObject:gestureCode forKey:Gesture_Code_Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - TouchID（Public）
/// touchID开启状态
+ (BOOL)touchIDOpenStatus {
    NSNumber *tempNum = [[NSUserDefaults standardUserDefaults] objectForKey:TouchID_Password_Open];
    BOOL touchID = tempNum ? [tempNum boolValue] : NO;
    return touchID;
}

/// 关闭/开启touchID
+ (void)touchIDOpen:(BOOL)open {
    NSNumber *tempNum = open ? @(1) : @(0);
    [[NSUserDefaults standardUserDefaults] setObject:tempNum forKey:TouchID_Password_Open];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// 开启指纹扫描的函数
- (void)openTouchID:(SCTouchIDOpenBlock)block {
    self.block = block;
    [self openTouchIDWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics touchIDBlock:block];
    
}

#pragma mark - 内部方法（Private）

#pragma mark - 手势密码（Private）

#pragma mark - TouchID（Private）
/*
typedef NS_ENUM(NSInteger, LAError)
{
    LAErrorAuthenticationFailed,     // 验证信息出错，就是说你指纹不对
    LAErrorUserCancel               // 用户取消了验证
    LAErrorUserFallback             // 用户点击了手动输入密码的按钮，所以被取消了
    LAErrorSystemCancel             // 被系统取消，就是说你现在进入别的应用了，不在刚刚那个页面，所以没法验证
    LAErrorPasscodeNotSet           // 用户没有设置TouchID
    LAErrorTouchIDNotAvailable      // 用户设备不支持TouchID
    LAErrorTouchIDNotEnrolled       // 用户没有设置手指指纹
    LAErrorTouchIDLockout           // 用户错误次数太多，现在被锁住了
    LAErrorAppCancel                // 在验证中被其他app中断
    LAErrorInvalidContext           // 请求验证出错
}
 
 typedef NS_ENUM(NSInteger, LAPolicy)
 {
 LAPolicyDeviceOwnerAuthenticationWithBiometrics NS_ENUM_AVAILABLE(NA, 8_0) __WATCHOS_AVAILABLE(3.0) __TVOS_AVAILABLE(10.0) = kLAPolicyDeviceOwnerAuthenticationWithBiometrics,
 LAPolicyDeviceOwnerAuthentication NS_ENUM_AVAILABLE(10_11, 9_0) = kLAPolicyDeviceOwnerAuthentication
 
 }
 第一个枚举LAPolicyDeviceOwnerAuthenticationWithBiometrics就是说，用的是手指指纹去验证的；NS_ENUM_AVAILABLE(NA, 8_0)iOS8 可用
 第二个枚举LAPolicyDeviceOwnerAuthentication少了WithBiometrics则是使用TouchID或者密码验证,默认是错误两次指纹或者锁定后,弹出输入密码界面;NS_ENUM_AVAILABLE(10_11, 9_0)iOS 9可用
 */
/// 开启指纹扫描
- (void)openTouchIDWithPolicy:(LAPolicy )policy touchIDBlock:(SCTouchIDOpenBlock)block {
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"验证登录密码";
    // LAPolicyDeviceOwnerAuthentication
    kWeakSelf
    [context evaluatePolicy:policy localizedReason:@"通过Home键验证已有手机指纹" reply:^(BOOL success, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = @"";
            if (success) {
                message = @"通过了Touch ID 指纹验证";
                block(YES, NO, message);
            } else {
                //失败操作
                LAError errorCode = error.code;
                BOOL inputPassword = NO;
                switch (errorCode) {
                    case LAErrorAuthenticationFailed: {
                        // -1
                        [SVProgressHUD showErrorWithStatus:@"指纹不匹配"];
                        message = @"连续三次指纹识别错误";
                    }
                        break;
                        
                    case LAErrorUserCancel: {
                        // -2
                        message = @"用户取消验证Touch ID";
                    }
                        break;
                        
                    case LAErrorUserFallback: {
                        // -3
                        inputPassword = YES;
                        message = @"用户选择输入密码";
                    }
                        break;
                        
                    case LAErrorSystemCancel: {
                        // -4 TouchID对话框被系统取消，例如按下Home或者电源键
                        message = @"取消授权，如其他应用切入";
                    }
                        break;
                        
                    case LAErrorPasscodeNotSet: {
                        // -5
                        [SVProgressHUD showErrorWithStatus:@"此设备未设置系统密码"];
                        message = @"设备系统未设置密码";
                    }
                        break;
                        
                    case LAErrorTouchIDNotAvailable: {
                        // -6
                        [SVProgressHUD showErrorWithStatus:@"此设备不支持 Touch ID"];
                        message = @"此设备不支持 Touch ID";
                    }
                        break;
                        
                    case LAErrorTouchIDNotEnrolled: {
                        // -7
                        [SVProgressHUD showErrorWithStatus:@"用户未录入指纹"];
                        message = @"用户未录入指纹";
                    }
                        break;
                        
                    case LAErrorTouchIDLockout: {
                        // -8 连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
                        if (iOS9) {
                            [weakSelf openTouchIDWithPolicy:LAPolicyDeviceOwnerAuthentication touchIDBlock:block];
                        }
                        message = @"Touch ID被锁，需要用户输入密码解锁";
                    }
                        break;
                        
                    case LAErrorAppCancel: {
                        // -9 如突然来了电话，电话应用进入前台，APP被挂起啦
                        message = @"用户不能控制情况下APP被挂起";
                    }
                        break;
                        
                    case LAErrorInvalidContext: {
                        // -10
                        message = @"Touch ID 失效";
                    }
                        break;
                        
                    default:
                        // [SVProgressHUD showErrorWithStatus:@"此设备不支持 Touch ID"];
                        break;
                }
                block(success, inputPassword, message);
            }
        });
    }];
}

@end
