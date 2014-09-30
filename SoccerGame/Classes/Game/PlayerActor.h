//
//  PlayerActor.h
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "cocos2d.h"
#import "Box2DNode.h"

typedef enum _Team : NSUInteger {
    TeamA,  // left
    TeamB   // right
} Team;

@interface PlayerActor : Actor

@property (strong, nonatomic) Box2DNode *box2DNode;
@property (strong, nonatomic) CCSprite *head;
@property (strong, nonatomic) CCSprite *chest;
@property (strong, nonatomic) CCSprite *legA;
@property (strong, nonatomic) CCSprite *legB;

@property (nonatomic) b2RevoluteJoint *legAJoint;
@property (nonatomic) b2RevoluteJoint *legBJoint;
@property (nonatomic) b2RevoluteJoint *weightChestJoint;
@property (nonatomic) b2DistanceJoint *standJoint;
@property (nonatomic) b2Body *weightBody;
@property (nonatomic) b2Body *chestBody;
@property (nonatomic) Team team;

@property (nonatomic) BOOL jumpingEnabled;

- (id)initWithPosition:(CGPoint)position size:(CGSize)size team:(Team)team andBox2DNode:(Box2DNode *)box2DNode;
- (void)logic;

- (void)startKick;
- (void)stopKick;
- (void)jumpInDirection:(CGPoint)point;
@end