//
//  PlayerActor.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import "PlayerActor.h"
#import "PhysicsFactory.h"
#import "Box2D.h"
#import "Strings.h"

#define ARC4RANDOM_MAX 0x100000000

const static float _standUpFrequency = 2.0f;
const static float _standUpDamping = 1.0f;

@implementation PlayerActor {
    unsigned int _id;
}

static unsigned int idCounter;

- (id)initWithPosition:(CGPoint)position size:(CGSize)size team:(Team)team andBox2DNode:(Box2DNode *)box2DNode {
    if (self=[super init])
    {
        _id = ++idCounter;
        self.box2DNode = box2DNode;
        [self createRagdollAtPosition:position size:size forTeam:team];
        self.jumpingEnabled = YES;
        self.team = team;
    }
    return self;
}

- (void)logic {
    [super logic];
    
    self.jumpingEnabled = self.chestBody->GetPosition().y<=2.5;
}

- (void)destroy {}

- (void)startKick {
    switch(self.team)
    {
        case TeamA:
            self.legAJoint->SetMotorSpeed(10);
            self.legBJoint->SetMotorSpeed(10);
            self.chestBody->ApplyAngularImpulse(-0.4, true);
            break;

        case TeamB:
            self.legAJoint->SetMotorSpeed(-10);
            self.legBJoint->SetMotorSpeed(-10);
            self.chestBody->ApplyAngularImpulse(0.4, true);
            break;
    }
    self.standJoint->SetFrequency(0.01);
}

- (void)stopKick {
    self.legAJoint->EnableMotor(true);
    self.legAJoint->SetMaxMotorTorque(10);
    self.legAJoint->SetMotorSpeed(10);
    
    self.legBJoint->EnableMotor(true);
    self.legBJoint->SetMaxMotorTorque(10);
    self.legBJoint->SetMotorSpeed(-10);
    
    self.standJoint->SetFrequency(_standUpFrequency);
}

- (void)jumpInDirection:(CGPoint)point {
    if (!self.jumpingEnabled)
    {
        NSLog(@"Player %d didnt jump", _id);
                return;
    }
    
    CGPoint totalImpulse = CGPointMake(0,0);
    
    CGPoint dir = point;
    dir.x -= self.chestBody->GetPosition().x;
    dir.y -= self.chestBody->GetPosition().y;

    // Impulse into direction of specified point (should be ball)
    float len = sqrtf(dir.x*dir.x + dir.y*dir.y);
    if (len<3)
    {
        dir.x /= len;
        dir.y /= len;

        float angleNoiseRange = 30 * M_PI/180;
        float angleNoise = ((double)arc4random() / ARC4RANDOM_MAX) * angleNoiseRange - angleNoiseRange/2;
        dir = CGPointApplyAffineTransform(dir, CGAffineTransformMakeRotation(angleNoise));

        float impulseValueMax = 9;
        float impulseValueMin = 6;
        float impulseValue = ((double)arc4random() / ARC4RANDOM_MAX) * (impulseValueMax - impulseValueMin) + impulseValueMin;

        CGPoint impulse = CGPointMake(dir.x*impulseValue, dir.y*impulseValue);
        totalImpulse.x += impulse.x;
        totalImpulse.y += impulse.y;
    }

    // Impulse into direction of player orientation
    {
        float angleNoiseRange = 0 * M_PI/180;
        float angleNoise = ((double)arc4random() / ARC4RANDOM_MAX) * angleNoiseRange - angleNoiseRange/2;
        float angle = self.chestBody->GetAngle()+angleNoise;

        float impulseValueMax = 7;
        float impulseValueMin = 5;
        float impulseValue = ((double)arc4random() / ARC4RANDOM_MAX) * (impulseValueMax - impulseValueMin) + impulseValueMin;
        
        CGPoint impulse = CGPointApplyAffineTransform(CGPointMake(0, impulseValue), CGAffineTransformMakeRotation(angle));
        totalImpulse.x += impulse.x;
        totalImpulse.y += impulse.y;
    }
    
    totalImpulse.x /= 2.0;
    totalImpulse.y /= 2.0;

    self.weightBody->ApplyLinearImpulse(b2Vec2(totalImpulse.x, totalImpulse.y),  self.weightBody->GetPosition(), true);
}

- (void)createRagdollAtPosition:(CGPoint)position size:(CGSize)size forTeam:(Team)team {
    
    // total dimensions of player ragdoll (enclosing AABB) with regards to given position (which is center-bottom)
    float w = size.width;  // width in meters
    float h = size.height; // height in meters

    //////////////////////////////////////////////////////////////////////////////
    // Legs
    
    CGSize leg_a_size = CGSizeMake(w*0.55/2, h*0.45);
    CGPoint leg_a_pos = CGPointMake(position.x - leg_a_size.width/2, position.y + leg_a_size.height/2);

    b2Body *leg_a_body = [PhysicsFactory createBoxWithSize:leg_a_size
                                                  position:leg_a_pos
                                                     angle:0
                                             fixedRotation:NO
                                             withBox2DNode:self.box2DNode];
    
    self.legA = [CCSprite spriteWithImageNamed:btn_menu_1_player_pushed];
    self.legA.scaleX = leg_a_size.width/self.legA.contentSize.width;
    self.legA.scaleY = leg_a_size.height/self.legA.contentSize.height;
    self.legA.opacity = 0.5f;
    
    leg_a_body->SetUserData((__bridge void *)_legA);
    [self.box2DNode addChild:self.legA];

    CGSize leg_b_size = CGSizeMake(w*0.55/2, h*0.45);
    CGPoint leg_b_pos = CGPointMake(position.x + leg_b_size.width/2, position.y + leg_b_size.height/2);
    
    b2Body *leg_b_body = [PhysicsFactory createBoxWithSize:leg_b_size
                                                  position:leg_b_pos
                                                     angle:0
                                             fixedRotation:NO
                                             withBox2DNode:self.box2DNode];
    
    self.legB = [CCSprite spriteWithImageNamed:btn_menu_1_player_pushed];
    self.legB.scaleX = leg_b_size.width/self.legB.contentSize.width;
    self.legB.scaleY = leg_b_size.height/self.legB.contentSize.height;

    leg_b_body->SetUserData((__bridge void *)_legB);
    [self.box2DNode addChild:self.legB];

    //////////////////////////////////////////////////////////////////////////////
    // Chest
    
    CGSize chest_size = CGSizeMake(w*0.55, h*0.35);
    CGPoint chest_pos = CGPointMake(position.x, position.y + leg_a_size.height + chest_size.height/2);
    b2Body *chest_body = [PhysicsFactory createBoxWithSize:chest_size
                                                  position:chest_pos
                                                     angle:0
                                             fixedRotation:NO
                                             withBox2DNode:self.box2DNode];
    

    self.chest = [CCSprite spriteWithImageNamed:btn_menu_1_player_pushed];
    self.chest.scaleX = chest_size.width/self.chest.contentSize.width;
    self.chest.scaleY = chest_size.height/self.chest.contentSize.height;
    
    chest_body->SetUserData((__bridge void *)_chest);
    self.chestBody = chest_body;
    
    [self.box2DNode addChild:self.chest];
    
    //////////////////////////////////////////////////////////////////////////////
    // Head

    float head_dx = (team==TeamA ? 1 : -1) * 0.15*w;
    CGSize head_size = CGSizeMake(0.5*w, 0.2*h);
    CGPoint head_pos = CGPointMake(position.x + head_dx, position.y + leg_a_size.height + chest_size.height + head_size.height/2);
    b2Body *head_body = [PhysicsFactory createBoxWithSize:head_size
                                                 position:head_pos
                                                    angle:0
                                            fixedRotation:NO
                                            withBox2DNode:self.box2DNode];
    
    self.head = [CCSprite spriteWithImageNamed:btn_menu_1_player_normal];
    self.head.scaleX = head_size.width/self.head.contentSize.width;
    self.head.scaleY = head_size.height/self.head.contentSize.height;
    
    head_body->SetUserData((__bridge void *)_head);
    
    [self.box2DNode addChild:self.head];

    //////////////////////////////////////////////////////////////////////////////
    // Weight

    CGSize weight_size = CGSizeMake(w/4, h/4);
    CGPoint weight_pos = CGPointMake(position.x, position.y+weight_size.height/2);
    self.weightBody = [PhysicsFactory createBoxWithSize:weight_size
                                               position:weight_pos
                                                  angle:0
                                          fixedRotation:YES
                                          withBox2DNode:self.box2DNode];
    self.weightBody->SetLinearDamping(5);
    
    //////////////////////////////////////////////////////////////////////////////
    // Joints

    // head - chest
    CGPoint head_chest_anchor = CGPointMake(position.x, position.y+leg_a_size.height+chest_size.height);
    NSMutableDictionary *head_chest_joint_opts = [PhysicsFactory getDefaultRevoluteJointOptions];
    head_chest_joint_opts[@"enableLimit"] = [NSNumber numberWithBool:YES];
    head_chest_joint_opts[@"lowerAngle"] = [NSNumber numberWithFloat:-7 *M_PI/180];
    head_chest_joint_opts[@"upperAngle"] = [NSNumber numberWithFloat:7 *M_PI/180];
    [PhysicsFactory createRevoluteJointBetweenBodyA:head_body
                                           andBodyB:chest_body
                                      atWorldAnchor:head_chest_anchor
                                        withOptions:head_chest_joint_opts
                                      withBox2DNode:self.box2DNode];

    // legA - chest
    CGPoint leg_a_chest_anchor = CGPointMake(position.x-leg_a_size.width/2, position.y+leg_a_size.height);
    NSMutableDictionary *leg_a_chest_joint_opts = [PhysicsFactory getDefaultRevoluteJointOptions];
    leg_a_chest_joint_opts[@"enableLimit"] = [NSNumber numberWithBool:YES];
    leg_a_chest_joint_opts[@"lowerAngle"] = [NSNumber numberWithFloat:-100 *M_PI/180];
    leg_a_chest_joint_opts[@"upperAngle"] = [NSNumber numberWithFloat:0];
    leg_a_chest_joint_opts[@"enableMotor"] = [NSNumber numberWithBool:YES];
    leg_a_chest_joint_opts[@"maxMotorTorque"] = [NSNumber numberWithFloat:10];
    self.legAJoint = [PhysicsFactory createRevoluteJointBetweenBodyA:leg_a_body
                                                            andBodyB:chest_body
                                                       atWorldAnchor:leg_a_chest_anchor
                                                         withOptions:leg_a_chest_joint_opts
                                                       withBox2DNode:self.box2DNode];

    // legB - chest
    CGPoint leg_b_chest_anchor = CGPointMake(position.x+leg_b_size.width/2, position.y+leg_b_size.height);
    NSMutableDictionary *leg_b_chest_joint_opts = [PhysicsFactory getDefaultRevoluteJointOptions];
    leg_b_chest_joint_opts[@"enableLimit"] = [NSNumber numberWithBool:YES];
    leg_b_chest_joint_opts[@"lowerAngle"] = [NSNumber numberWithFloat:0];
    leg_b_chest_joint_opts[@"upperAngle"] = [NSNumber numberWithFloat:100 *M_PI/180];
    leg_b_chest_joint_opts[@"enableMotor"] = [NSNumber numberWithBool:YES];
    leg_b_chest_joint_opts[@"maxMotorTorque"] = [NSNumber numberWithFloat:10];
    self.legBJoint = [PhysicsFactory createRevoluteJointBetweenBodyA:leg_b_body
                                                            andBodyB:chest_body
                                                       atWorldAnchor:leg_b_chest_anchor
                                                         withOptions:leg_b_chest_joint_opts
                                                       withBox2DNode:self.box2DNode];
    
    // weight - chest
    CGPoint weight_chest_anchor = CGPointMake(position.x, position.y);
    NSMutableDictionary *weight_chest_joint_opts = [PhysicsFactory getDefaultRevoluteJointOptions];
    [PhysicsFactory createRevoluteJointBetweenBodyA:chest_body
                                           andBodyB:self.weightBody
                                      atWorldAnchor:weight_chest_anchor
                                        withOptions:weight_chest_joint_opts
                                      withBox2DNode:self.box2DNode];

    b2DistanceJointDef jointDef;
    b2Vec2 jointPos(position.x + (self.team==TeamA?1:-1)*w, position.y+h*3);
    jointDef.Initialize(self.chestBody, self.weightBody, b2Vec2(chest_pos.x, chest_pos.y), jointPos);
    jointDef.length = jointDef.length*0.9; // so that there is a bit more tension constantly
    jointDef.frequencyHz = _standUpFrequency;
    jointDef.dampingRatio = _standUpDamping;
    self.standJoint = (b2DistanceJoint*)self.box2DNode.world->CreateJoint(&jointDef);
    
    //////////////////////////////////////////////////////////////////////////////
    // Collision filtering
    
    static b2Filter filter;
    filter.groupIndex = 0;

    // head and chest
    filter.categoryBits = 0x01 << FILTER_HEAD_AND_CHEST;
    filter.maskBits = ~(0x00);     // collide with all
    [PhysicsFactory setBody:head_body filterData:filter];
    [PhysicsFactory setBody:chest_body filterData:filter];

    // legs
    filter.groupIndex = -_id;
    filter.categoryBits = 0x01 << FILTER_LEG;
    filter.maskBits = ~(0x00);      // collide with all
    [PhysicsFactory setBody:leg_a_body filterData:filter];
    [PhysicsFactory setBody:leg_b_body filterData:filter];
    
    // weight
    filter.groupIndex = 0;
    filter.categoryBits = 0x00;
    filter.maskBits = 0x00;
    [PhysicsFactory setBody:self.weightBody filterData:filter];
}

@end
