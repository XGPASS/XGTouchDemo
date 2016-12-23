//
//  SCHeader.h
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/19.
//  Copyright © 2016年 小广. All rights reserved.
//

#ifndef SCHeader_h
#define SCHeader_h

// 指纹密码是否开启的key
#define TouchID_Password_Open      @"TouchID_Password_Open"
// 手势密码是否开启的key
#define Gesture_Password_Open      @"Gesture_Password_Open"
// 记录手势密码GestureCodeKey
#define Gesture_Code_Key           @"Gesture_Code_Key"
// 手势密码是否显示轨迹的key
#define Gesture_Password_Show      @"Gesture_Password_Show"


#define ScreenBounds [UIScreen mainScreen].bounds
#define ScreenWidth  ScreenBounds.size.width
#define ScreenHeight ScreenBounds.size.height
#define SCViewHeight   CGRectGetHeight(ScreenBounds) - 44.0 - 20.0 // 去掉导航条的高度

/// 根据16位RBG值转换成颜色，格式:UIColorFrom16RGB(0xFF0000)
#define UIColorFrom16RGB(rgbValue,alp) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alp]

/// 根据10位RBG值转换成颜色, 格式:UIColorFrom10RGB(255,255,255)
#define UIColorFrom10RGB(RED, GREEN, BLUE,alp) [UIColor colorWithRed:RED/255.0 green:GREEN/255.0 blue:BLUE/255.0 alpha:alp]


/// 手势圆圈正常的颜色
#define SCCircleNormalColor   UIColorFrom16RGB(0x33CCFF,1.0)
/// 手势圆圈选中的颜色
#define SCCircleSelectedColor UIColorFrom16RGB(0x3393F2,1.0)
/// 手势圆圈错误的颜色
#define SCCircleErrorColor    UIColorFrom16RGB(0xFF0033,1.0)

// 手势密码提示Label的高度
#define LabelHeight 20.0f
// 手势密码九宫格view的宽高
#define GestureWH   260.0f

// 对于block的弱引用
#define kWeakSelf __weak __typeof(self)weakSelf = self;

#endif /* SCHeader_h */
