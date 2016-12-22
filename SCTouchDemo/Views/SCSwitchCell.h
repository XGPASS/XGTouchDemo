//
//  SCSwitchCell.h
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/19.
//  Copyright © 2016年 小广. All rights reserved.
//  有UISwitch按钮的cell

#import <UIKit/UIKit.h>

typedef void(^SCSwitchBlock)(UISwitch *switchButton);

@interface SCSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setupSwitchOn:(BOOL)isOn switchBlock:(SCSwitchBlock)block;

@end
