//
//  SCSecureHelper.h
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/21.
//  Copyright © 2016年 小广. All rights reserved.
//  指纹密码/手势密码的helper类

#import <Foundation/Foundation.h>

/**
 指纹密码结果的回调block
 
 @param success        验证的结果
 @param inputPassword  输入登录密码验证
 @param message        验证结果的提示信息
 */
typedef void(^SCTouchIDOpenBlock)(BOOL success, BOOL inputPassword, NSString *message);

@interface SCSecureHelper : NSObject
/// 单例
+ (SCSecureHelper *)shareInstance;

/// 手势密码的开启状态
+ (BOOL)gestureOpenStatus;

/// 手势密码轨迹显示开启状态
+ (BOOL)gestureShowStatus;

/// 关闭/开启手势密码
+ (void)openGesture:(BOOL)open;

/// 关闭/开启手势密码
+ (void)openGestureShow:(BOOL)open;

/// 获取保存手势密码的code
+ (NSString *)gainGestureCodeKey;

/// 保存手势密码的code
+ (void)saveGestureCodeKey:(NSString *)gestureCode;

/// 关闭/开启touchID
+ (void)touchIDOpen:(BOOL)open;
/// touchID开启状态
+ (BOOL)touchIDOpenStatus;

/// 开启指纹扫描的函数
- (void)openTouchID:(SCTouchIDOpenBlock)block;

@end
