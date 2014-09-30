//
//  Button.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 30/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import "Button.h"

@implementation Button {
    id _touchBeganTarget;
    SEL _touchBeganTargetSelector;
    
    id _touchEndedTarget;
    SEL _touchEndedTargetSelector;
}


- (void)setTouchBeganTarget:(id)target selector:(SEL)selector {
    _touchBeganTarget = target;
    _touchBeganTargetSelector = selector;
}

- (void)setTouchEndedTarget:(id)target selector:(SEL)selector {
    _touchEndedTarget = target;
    _touchEndedTargetSelector = selector;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [super touchBegan:touch withEvent:event];
    [_touchBeganTarget performSelector:_touchBeganTargetSelector withObject:nil];
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [super touchEnded:touch withEvent:event];
    [_touchEndedTarget performSelector:_touchEndedTargetSelector withObject:nil];
}

@end
