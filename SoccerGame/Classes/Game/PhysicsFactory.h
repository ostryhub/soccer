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

// b2Filter category/mask bits meanings
#define FILTER_GROUND           0
#define FILTER_LEG              1
#define FILTER_HEAD_AND_CHEST   2
#define FILTER_BALL             3


@interface PhysicsFactory : NSObject

+ (b2Body *)createGroundBoxWithSize:(CGSize)size andPosition:(CGPoint)position withBox2DNode:(Box2DNode *)box2dNode;
+ (b2Body *)createBallOfRadius:(float)radius position:(CGPoint)position andDensity:(float)density withBox2DNode:(Box2DNode*)box2dNode;

// theese are used to create football player ragdolls
+ (b2Body *)createBoxWithSize:(CGSize)size
                     position:(CGPoint)position
                        angle:(float)angle
                fixedRotation:(BOOL)fixedRotation
                withBox2DNode:(Box2DNode *)box2dNode;

+ (NSMutableDictionary *)getDefaultRevoluteJointOptions;
+ (b2RevoluteJoint *)createRevoluteJointBetweenBodyA:(b2Body *)bodyA andBodyB:(b2Body *)bodyB
                                       atWorldAnchor:(CGPoint)anchor withOptions:(NSDictionary*)opts
                                       withBox2DNode:(Box2DNode*)box2DNode;

+ (void)setBody:(b2Body*)body filterData:(b2Filter &)filter;
+ (void)setBody:(b2Body*)body mass:(float)mass;

@end
