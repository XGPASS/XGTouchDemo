//
//  SCTouchIDController.m
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/19.
//  Copyright © 2016年 小广. All rights reserved.
//  指纹密码

#import "SCTouchIDController.h"
#import "SCSecureHelper.h"
#import "SCSwitchCell.h"

@interface SCTouchIDController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SCTouchIDController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"指纹密码";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SCSwitchCell class]) bundle:nil]
         forCellReuseIdentifier:NSStringFromClass([SCSwitchCell class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
    
    SCSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCSwitchCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = @"指纹解锁";
    kWeakSelf
    [cell setupSwitchOn:[SCSecureHelper touchIDOpenStatus] switchBlock:^(UISwitch *switchButton) {
        [weakSelf switchButtonAction:switchButton];
    }];
    return cell;
}

// 开启/关闭指纹识别的操作
- (void)switchButtonAction:(UISwitch *)sender {
    __weak UISwitch *weakSwitch = sender;
    kWeakSelf
    [[SCSecureHelper shareInstance] openTouchID:^(BOOL success, BOOL inputPassword, NSString *message) {
        
        if (inputPassword && !success) {
            // inputPassword是yes的话，调用登录页面，进行输入登录密码进行验证，相当于退出了登录，重新登录
            [weakSelf changeTouchIDByPassword:sender];
            return ;
        }
        // 如果其他结果
        [weakSelf showSwitchOnStatus:weakSwitch handleSuccess:success];
    }];
}

// 验证登录密码，来改变指纹识别的开闭
// 跳转到登录页面，登录成功的block回调里面处理,和指纹识别类似的判断
- (void)changeTouchIDByPassword:(UISwitch *)sender {

    // 弱引用
    //kWeakSelf
    
    // 以下代码是在登录结果的block里进行的处理
    BOOL success = YES;
    [self showSwitchOnStatus:sender handleSuccess:success];
}

/// handleResult 指纹识别/登录成功的操作结果 success是操作结果yes成功，no 失败
- (void)showSwitchOnStatus:(UISwitch *)sender handleSuccess:(BOOL)success {
    BOOL isOpen = [SCSecureHelper touchIDOpenStatus];
    if (isOpen) {
        // isOpen是YES，代表之前是开启状态
        if (success) {
            // 之前是开启状态，验证成功后就是关闭状态
            [SVProgressHUD showSuccessWithStatus:@"指纹验证已关闭"];
            [SCSecureHelper touchIDOpen:NO];
            [sender setOn:NO animated:YES];
        } else {
            // 之前是开启状态，验证失败后仍是开启状态
            [sender setOn:YES animated:YES];
        }
    } else {
        // isOpen是NO，代表之前是关闭状态
        if (success) {
            // 之前是关闭状态，验证成功后就是开启状态
            [SVProgressHUD showSuccessWithStatus:@"指纹验证开启成功"];
            [SCSecureHelper touchIDOpen:YES];
            [sender setOn:YES animated:YES];
        } else {
            // 之前是关闭状态，验证失败后仍是关闭状态
            [sender setOn:NO animated:YES];
        }
    }
}

- (void)dealloc {
    NSLog(@"%@===dealloc",NSStringFromClass([self class]));
}

@end
