//
//  SCSearchView.h
//  Butler
//
//  Created by 小广 on 2017/1/19.
//  Copyright © 2017年 UAMA Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCSearchType) {
    SCSearchTypeNormal, // 正常的搜索（类型按钮+输入框）
    SCSearchTypeScan,   // 有扫描搜索 （类型按钮+输入框+扫描按钮）
    SCSearchTypeAddress // 地址搜索 （类型按钮+地址按钮）
};

typedef NS_ENUM(NSInteger, SCButtonType) {
    SCButtonTypeTitle,  // 左侧的类型按钮
    SCButtonTypeScan,   // 扫描按钮
    SCButtonTypeAddress // 地址按钮
};

typedef void(^SCSearchBarBlock)(NSString *text);
typedef void(^SCSearchButtonBlock)(UIButton *button, SCButtonType buttonType);

@interface SCSearchView : UIView

/// 是否显示搜索按钮
@property (nonatomic, assign) BOOL showScan;
@property (nonatomic, assign) SCSearchType searchType;
/// 搜索类型的按钮title
@property (nonatomic, copy) NSString  *searchTypeString;
/// 搜索textField的text
@property (nonatomic, copy) NSString  *searchText;
/// 为地址选择时，地址按钮的title
@property (nonatomic, copy) NSString  *addressString;


+ (id)loadNibView;

/// 点击键盘的搜索按钮获取到的
- (void)gainSearchText:(SCSearchBarBlock)textBlock;

/// 按钮的点击事件
- (void)searchBarAction:(SCSearchButtonBlock)block;


@end
