//
//  Actor.h
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCSprite;

@interface Actor : NSObject

- (void)logic;
- (void)destroy;

@end