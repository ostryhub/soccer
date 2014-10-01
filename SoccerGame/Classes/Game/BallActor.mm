//
//  BallActor.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 30/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//


#import "BallActor.h"
#import "Strings.h"
#import "PhysicsFactory.h"

@implementation BallActor


- (id)initWithPosition:(CGPoint)position radius:(float)radius andBox2DNode:(Box2DNode *)box2DNode {
    if (self=[super init])
    {
        self.state = BallState_Play;
        self.box2DNode = box2DNode;
        [self createBallAtPosition:position andRadius:radius];
    }
    return self;
}

- (void)createBallAtPosition:(CGPoint)position andRadius:(float)radius {
    self.ballBody = [PhysicsFactory createBallOfRadius:radius position:position andDensity:1.25 withBox2DNode:self.box2DNode];
    self.ballBody->SetLinearDamping(1);
    
    self.ball = [CCSprite spriteWithImageNamed:sprite_ball_soccer];
    self.ball.scaleX = radius*2/self.ball.contentSize.width;
    self.ball.scaleY = radius*2/self.ball.contentSize.height;
    
    // ...so that body can update sprites transform
    self.ballBody->SetUserData((__bridge void *)self.ball);
    
    [self.box2DNode addChild:self.ball];
}

- (CGPoint)getPosition {
    return CGPointMake(self.ballBody->GetPosition().x, self.ballBody->GetPosition().y);
};

- (void)logic {
    CGPoint p = [self getPosition];
    
    self.state =    (p.x<1.7 && p.x>0.5 && p.y<4.25)    ? BallState_InsideGoalA :
                    (p.x>8.3 && p.x<9.5 && p.y<4.25)    ? BallState_InsideGoalB :
                    (p.x<0 || p.x>10)                   ? BallState_Out:
                                                          BallState_Play;
}

@end
