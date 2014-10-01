//
//  Button.h
//  SoccerGame
//
//  Created by Rafał Ostrowski on 30/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import "CCButton.h"

@interface Button : CCButton

- (void)setTouchBeganTarget:(id)target selector:(SEL)selector;
- (void)setTouchEndedTarget:(id)target selector:(SEL)selector;

@end
