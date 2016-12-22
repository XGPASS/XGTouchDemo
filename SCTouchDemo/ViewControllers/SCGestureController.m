//
//  SCGestureController.m
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/19.
//  Copyright © 2016年 小广. All rights reserved.
//  手势密码

#import "SCGestureController.h"
#import "SCGestureSetController.h"
#import "SCSecureHelper.h"
#import "SCSwitchCell.h"
#import "SCNormalCell.h"

@interface SCGestureController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISwitch *openSwitch; // 开启/关闭手势的Switch
@property (nonatomic, strong) UISwitch *showSwitch; // 显示/隐藏手势轨迹的Switch
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SCGestureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手势密码";
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SCSwitchCell class]) bundle:nil]
         forCellReuseIdentifier:NSStringFromClass([SCSwitchCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SCNormalCell class]) bundle:nil]
         forCellReuseIdentifier:NSStringFromClass([SCNormalCell class])];
    
    [self reloadGestureData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if ([SCSecureHelper gestureOpenStatus] && indexPath.row == 2) {
        
        SCNormalCell *normalCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCNormalCell class]) forIndexPath:indexPath];
        normalCell.titleLabel.text = self.dataArray[indexPath.row];
        normalCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = normalCell;
        
    } else {
        
        SCSwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCSwitchCell class]) forIndexPath:indexPath];
        NSString *title = self.dataArray[indexPath.row];
        BOOL isOn = indexPath.row == 0 ? [SCSecureHelper gestureOpenStatus] : [SCSecureHelper gestureShowStatus];
        kWeakSelf
        [switchCell setupSwitchOn:isOn switchBlock:^(UISwitch *switchButton) {
            if (indexPath.row == 0) {
                [weakSelf gestureOpenSwitchAction:switchButton];
                return ;
            }
            [weakSelf gestureShowSwitchAction:switchButton];
        }];
        switchCell.titleLabel.text = title;
        cell = switchCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([SCSecureHelper gestureOpenStatus] && indexPath.row == 2) {
        // 修改手势密码的处理
        SCGestureSetController *controller = [[SCGestureSetController alloc] init];
        controller.gestureSetType = SCGestureSetTypeChange;
        [controller gestureSetComplete:^(BOOL success) {
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"修改手势成功"];
            }
        }];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

// 刷新手势密码开启状态，对应的显示内容
- (void)reloadGestureData {
    BOOL isOpen = [SCSecureHelper gestureOpenStatus];
    NSLog(@"isOpen====状态是%@==",(isOpen ? @"开启" : @"关闭"));
    if (isOpen) {
        self.dataArray = @[@"手势密码", @"显示手势密码轨迹", @"修改手势密码"];
        return;
    }
    self.dataArray = @[@"手势密码"];
}

// 显示/隐藏手势密码轨迹
- (void)gestureShowSwitchAction:(UISwitch *)sender {
    BOOL  show = [SCSecureHelper gestureShowStatus];
    // 直接取反就行
    [SCSecureHelper openGestureShow:!show];
    [sender setOn:!show animated:YES];
}

// 开启/关闭手势密码
- (void)gestureOpenSwitchAction:(UISwitch *)sender {
    
    BOOL isOpen = [SCSecureHelper gestureOpenStatus];
    // isOpen是YES代表之前是开启的，现在关闭，setType为SCGestureSetTypeDelete;
    // isOpen是NO代表之前是关闭的，现在开启，setType为SCGestureSetTypeSetting;
    SCGestureSetType  setType = isOpen ? SCGestureSetTypeDelete : SCGestureSetTypeSetting;
    
    SCGestureSetController *controller = [[SCGestureSetController alloc] init];
    controller.gestureSetType = setType;
    kWeakSelf
    [controller gestureSetComplete:^(BOOL success) {
        [weakSelf showSwitchOnStatus:sender handleSuccess:success];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

/// handleResult 手势操作结果 success是操作结果yes成功，no 失败
- (void)showSwitchOnStatus:(UISwitch *)sender handleSuccess:(BOOL)success {
    
    BOOL isOpen = [SCSecureHelper gestureOpenStatus];
    if (!success) {
        // 不成功，依旧为当前的值
        [sender setOn:isOpen animated:YES];
        return;
    }
    
    // isOpen是YES代表之前是开启的，现在关闭，nowOpenStatus为NO; isOpen是NO代表之前是关闭的，现在开启，nowOpenStatus为YES;
    BOOL nowOpenStatus = isOpen ? NO : YES;
    [SCSecureHelper openGesture:nowOpenStatus];
    [sender setOn:nowOpenStatus animated:YES];
    [self reloadGestureData];
    if (!isOpen) {
        [SVProgressHUD showSuccessWithStatus:@"手势密码已设置"];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)dealloc {
    NSLog(@"%@===dealloc",NSStringFromClass([self class]));
}

@end
