//
//  SCGestureSetController.h
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/20.
//  Copyright © 2016年 小广. All rights reserved.
//  手势设置/删除/修改页面

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCGestureSetType) {
    SCGestureSetTypeSetting = 1,   // 设置
    SCGestureSetTypeDelete,        // 删除设置
    SCGestureSetTypeChange         // 修改
};

// 设置的结果
typedef void(^SCGestureSetBlock)(BOOL success);

@interface SCGestureSetController : UIViewController

@property (nonatomic, assign) SCGestureSetType gestureSetType;

/// 设置手势完成的回调
- (void)gestureSetComplete:(SCGestureSetBlock)block;

@end
