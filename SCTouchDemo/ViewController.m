//
//  ViewController.m
//  SCTouchDemo
//
//  Created by 小广 on 2016/12/15.
//  Copyright © 2016年 小广. All rights reserved.
//

#import "ViewController.h"
#import "SCGestureController.h"
#import "SCTouchIDController.h"
#import "SCMainCell.h"
#import "SCSecureHelper.h"
#import "SCLoginVerifyView.h"
#import "XGTestViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"安全设置";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SCMainCell class]) bundle:nil]
         forCellReuseIdentifier:NSStringFromClass([SCMainCell class])];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadArray];
    [self.tableView reloadData];
}

- (void)reloadArray {
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    BOOL gestureOpen = [SCSecureHelper gestureOpenStatus];
    BOOL touchIDOpen = [SCSecureHelper touchIDOpenStatus];
    self.dataArray = [NSMutableArray arrayWithArray:@[@"手势密码", @"指纹密码"]];
    if (gestureOpen) {
        [self.dataArray addObject:@"手势密码验证"];
    }
    
    if (touchIDOpen) {
        [self.dataArray addObject:@"指纹密码验证"];
    }
}

// iOS8 分割线右移15像素 下面将其归零
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
    
    SCMainCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SCMainCell class]) forIndexPath:indexPath];
    NSString *title = self.dataArray[indexPath.row];
    NSString *content = @"";
    if ([title isEqualToString:@"手势密码"]) {
        content = [SCSecureHelper gestureOpenStatus] ? @"已开启" : @"未设置";
    } else if ([title isEqualToString:@"指纹密码"]) {
        content = [SCSecureHelper touchIDOpenStatus] ? @"已开启" : @"未设置";
    }
    cell.titleLabel.text = title;
    cell.contentLabel.text = content;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SCLoginVerifyType type = SCLoginVerifyTypeTouchID;
    UIViewController *controller = [[XGTestViewController alloc] init];
    NSString *tempTitle = self.dataArray[indexPath.row];
    if ([tempTitle isEqualToString:@"手势密码"]) {
        controller = [[SCGestureController alloc] init];
    } else if ([tempTitle isEqualToString:@"指纹密码"]) {
        controller = [[SCTouchIDController alloc] init];
    } else if ([tempTitle isEqualToString:@"手势密码验证"]) {
        type = SCLoginVerifyTypeGesture;
    } else if ([tempTitle isEqualToString:@"指纹密码验证"]) {
        type = SCLoginVerifyTypeTouchID;
    }
    if (controller) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        SCLoginVerifyView *verifyView = [[SCLoginVerifyView alloc] initWithFrame:CGRectMake(0.0, 0.0, ScreenWidth, ScreenHeight) verifyType:type];
        [verifyView showView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 对编辑图片后图片反转90度的处理
 */
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
