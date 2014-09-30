//
//  BallActor.h
//  SoccerGame
//
//  Created by Rafał Ostrowski on 30/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import "Actor.h"
#import "cocos2d.h"
#import "Box2DNode.h"

@interface BallActor : Actor

@property (strong, nonatomic) Box2DNode *box2DNode;
@property (strong, nonatomic) CCSprite *ball;
@property (nonatomic) b2Body *ballBody;

- (id)initWithPosition:(CGPoint)position radius:(float)radius andBox2DNode:(Box2DNode *)box2DNode;
- (void)createBallAtPosition:(CGPoint)position andRadius:(float)radius;
- (CGPoint)getPosition;

@end

