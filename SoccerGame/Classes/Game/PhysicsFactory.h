//
//  ActorsFactory.h
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2dNode.h"

@interface PhysicsFactory : NSObject

+ (b2Body *)createGroundBoxWithSize:(CGSize)size andPosition:(CGPoint)position withBox2DNode:(Box2DNode *)box2dNode;
+ (b2Body *)createBallOfRadius:(float)radius position:(CGPoint)position andDensity:(float)density withBox2DNode:(Box2DNode*)box2dNode;
+ (CCNode *)createPlayerAtPosition:(CGPoint)position withBox2DNode:(Box2DNode*)box2dNode;


@end
