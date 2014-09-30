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
    box.SetAsBox(size.width/2, size.height/2);

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
    filter.categoryBits = 0x01 << FILTER_BALL;
    filter.maskBits = ~(0x00);
    
    b2Fixture *fixture = body->CreateFixture(&circle, density);
    fixture->SetFilterData(filter);
    fixture->SetFriction(0.9);
    fixture->SetRestitution(1.05);
    
    return body;
}

+ (b2Body *)createBoxWithSize:(CGSize)size
                     position:(CGPoint)position
                     angle:(float)angle
                     fixedRotation:(BOOL)fixedRotation
                     withBox2DNode:(Box2DNode *)box2dNode
{
    static b2BodyDef bodyDef;
    bodyDef.active = true;
    bodyDef.allowSleep = true;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(position.x, position.y);
    bodyDef.angle = angle;
    bodyDef.fixedRotation = fixedRotation;
    
    b2Body *body = box2dNode.world->CreateBody(&bodyDef);
    
    b2PolygonShape box;
    box.SetAsBox(size.width/2, size.height/2);
    
    b2Filter filter;
    filter.categoryBits = 0xFFFF;
    filter.maskBits = 0xFFFF;
    
    b2Fixture *fixture = body->CreateFixture(&box, 1);
    fixture->SetFilterData(filter);
    return body;

}

+ (NSMutableDictionary *)getDefaultRevoluteJointOptions {
    return [NSMutableDictionary dictionaryWithDictionary:@{
        @"collideConnected":    [NSNumber numberWithBool:NO],
        @"enableLimit":         [NSNumber numberWithBool:NO],
        @"lowerAngle":          [NSNumber numberWithFloat:0.0f],
        @"upperAngle":          [NSNumber numberWithFloat:0.0f],
        @"enableMotor":         [NSNumber numberWithBool:NO],
        @"maxMotorTorque":      [NSNumber numberWithFloat:0.0f],
        @"motorSpeed":          [NSNumber numberWithFloat:0.0f]}];
}

// opts must be a dictionary containing those NSNumber elements:
// "collideConnected" - BOOL
// "enableLimit" - BOOL
// "lowerAngle" - float
// "upperAngle" - float
// "enableMotor" - BOOL
// "maxMotorTorque" - float
// "motorSpeed" - float
+ (b2RevoluteJoint *)createRevoluteJointBetweenBodyA:(b2Body *)bodyA andBodyB:(b2Body *)bodyB
                                       atWorldAnchor:(CGPoint)anchor withOptions:(NSDictionary*)opts
                                       withBox2DNode:(Box2DNode*)box2DNode
{
    b2RevoluteJointDef jointDef;
    jointDef.Initialize(bodyB, bodyA, b2Vec2(anchor.x, anchor.y));
    
    jointDef.collideConnected = [opts[@"collideConnected"] boolValue];
    
    jointDef.enableLimit = [opts[@"enableLimit"] boolValue];
    jointDef.lowerAngle = [opts[@"lowerAngle"] floatValue];
    jointDef.upperAngle = [opts[@"upperAngle"] floatValue];

    jointDef.enableMotor = [opts[@"enableMotor"] boolValue];
    jointDef.maxMotorTorque = [opts[@"maxMotorTorque"] floatValue];
    jointDef.motorSpeed = [opts[@"motorSpeed"] floatValue];
    
    b2RevoluteJoint *joint = (b2RevoluteJoint*)box2DNode.world->CreateJoint(&jointDef);
    return joint;
}

+ (void)setBody:(b2Body*)body filterData:(b2Filter &)filter {
    for (b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext())
        f->SetFilterData(filter);
}

+ (void)setBody:(b2Body*)body mass:(float)mass {
    b2MassData md;
    body->GetMassData(&md);
    md.mass = mass;
    body->SetMassData(&md);
}

@end




































