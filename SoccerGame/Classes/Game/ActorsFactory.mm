//
//  ActorsFactory.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import "ActorsFactory.h"
#import "PhysicsFactory.h"

@implementation ActorsFactory

+ (CCNode *)createBallWithImage:(NSString *)image radius:(float)radius position:(CGPoint)position andDensity:(float)density withBox2DNode:(Box2DNode*)box2DNode {
    b2Body *body = [PhysicsFactory createBallOfRadius:0.5f
                                             position:position
                                           andDensity:density
                                        withBox2DNode:box2DNode];

    CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
    sprite.scaleX = (radius*2)/sprite.contentSize.width;
    sprite.scaleY = (radius*2)/sprite.contentSize.height;

    // ...so that body can update sprites transform
    body->SetUserData((__bridge void *)sprite);

    return sprite;
}

@end
