//
//  GCDDelay.m
//  口算达人
//
//  Created by app on 2017/6/27.
//  Copyright © 2017年 William. All rights reserved.
//

#import "GCDDelay.h"

@implementation GCDDelay

/// 开启GCD延时
+ (void)gcdLater:(NSTimeInterval)time block:(gcdBlock)block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

/// 获取GCD延时任务
+ (GCDTask)gcdDelay:(NSTimeInterval)time task:(gcdBlock)block {
    
    __block dispatch_block_t closure = block;
    __block GCDTask result;
    GCDTask delayedClosure = ^(BOOL cancel){
        if (closure) {
            if (!cancel) {
                dispatch_async(dispatch_get_main_queue(), closure);
            }
        }
        closure = nil;
        result = nil;
    };
    result = delayedClosure;
    [self gcdLater:time block:^{
        if (result)
            result(NO);
    }];
    
    return result;
}

/// 取消GCD任务
+ (void)gcdCancel:(GCDTask)task {
    if (task) {
        task(YES);
    }
}

@end
