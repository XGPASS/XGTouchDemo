//
//  CALayer+shake.m
//  PasscodeLockDemo
//
//  Created by MA806P on 16/8/10.
//  Copyright © 2016年 myz. All rights reserved.
//

#import "CALayer+shake.h"

@implementation CALayer (shake)

- (void)shake {
    CAKeyframeAnimation * keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat x = 5;
    keyAnimation.values = @[@(-x),@(0),@(x),@(0),@(-x),@(0),@(x),@(0)];
    keyAnimation.duration = 0.3;
    keyAnimation.repeatCount = 2;
    keyAnimation.removedOnCompletion = YES;
    [self addAnimation:keyAnimation forKey:nil];
}


@end
