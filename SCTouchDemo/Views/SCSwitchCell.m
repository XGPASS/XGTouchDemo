//
//  SCSwitchCell.m
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/19.
//  Copyright © 2016年 小广. All rights reserved.
//

#import "SCSwitchCell.h"

@interface SCSwitchCell ()
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

@property (nonatomic, copy) SCSwitchBlock block;
@end

@implementation SCSwitchCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setupSwitchOn:(BOOL)isOn switchBlock:(SCSwitchBlock)block {
    [self.switchButton setOn:isOn animated:YES];
    self.block = block;
}

- (IBAction)switchAction:(UISwitch *)sender {
    if (self.block) {
        self.block(sender);
    }
}

@end
