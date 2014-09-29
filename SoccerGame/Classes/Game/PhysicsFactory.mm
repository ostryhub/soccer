//
//  ActorsFactory.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import "PhysicsFactory.h"

@implementation PhysicsFactory

+ (b2Body *)createGroundBoxWithSize:(CGSize)size andPosition:(CGPoint)position withBox2DNode:(Box2DNode *)box2dNode {

    static b2BodyDef bodyDef;
    bodyDef.active = true;
    bodyDef.allowSleep = false;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(position.x, position.y);
    
    b2Body *body = box2dNode.world->CreateBody(&bodyDef);
    
    b2PolygonShape box;
    box.SetAsBox(size.width, size.height);

    b2Filter filter;
    filter.categoryBits = 0xFFFF;
    filter.maskBits = 0xFFFF;
    
    b2Fixture *fixture = body->CreateFixture(&box, 0);
    fixture->SetFilterData(filter);
    return body;
}

+ (b2Body *)createBallOfRadius:(float)radius position:(CGPoint)position andDensity:(float)density withBox2DNode:(Box2DNode*)box2dNode {
    static b2BodyDef bodyDef;
    bodyDef.active = true;
    bodyDef.allowSleep = true;
    bodyDef.bullet = true;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(position.x, position.y);
    
    b2Body *body = box2dNode.world->CreateBody(&bodyDef);
    
    b2CircleShape circle;
    circle.m_radius = radius;
    circle.m_p = b2Vec2(0,0);
    
    b2Filter filter;
    filter.categoryBits = 0xFFFF;
    filter.maskBits = 0xFFFF;
    
    b2Fixture *fixture = body->CreateFixture(&circle, density);
    fixture->SetFilterData(filter);
    
    return body;
}

+ (CCNode *)createPlayerAtPosition:(CGPoint)position withBox2DNode:(Box2DNode*)box2dNode {
    
}

@end
