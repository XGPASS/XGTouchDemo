//
//  GCDDelay.h
//  口算达人
//
//  Created by app on 2017/6/27.
//  Copyright © 2017年 William. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GCDTask)(BOOL cancel);
typedef void(^gcdBlock)();

@interface GCDDelay : NSObject

+ (GCDTask)gcdDelay:(NSTimeInterval)time task:(gcdBlock)block;

+ (void)gcdCancel:(GCDTask)task;

@end
