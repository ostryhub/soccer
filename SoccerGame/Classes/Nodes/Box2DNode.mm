//
//  Box2DNode.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import "Box2DNode.h"
#import "Actor.h"
#import "cocos2d.h"

@implementation Box2DNode

- (id)initWithGravity:(b2Vec2 &)gravity {
    if (self=[super init])
    {
        self.slowRate = 1;
        
        self.world = new b2World(gravity);
        self.actors = [NSMutableArray arrayWithArray:@[]];
    }
    
    return self;
};

- (void)update:(CCTime)delta {

    // Better physics accuracy to run twice with half step rather than once with double step
    for(int i=0; i<2; ++i)
        self.world->Step(1.0/(120*_slowRate), 4, 7);
    
    for(b2Body* b=self.world->GetBodyList(); b; b=b->GetNext())
    {
        void *userdata = b->GetUserData();
        if (userdata)
        {
            CCNode *node = (__bridge CCNode*)userdata;
            b2Vec2 position = b->GetPosition();
            float32 angle = b->GetAngle();
            node.position = ccp(position.x, position.y);
            node.rotation = -angle*180/M_PI;
        }
    }
    
    for(Actor *actor in self.actors)
        [actor logic];
}

- (void)dealloc {
    [self.actors removeAllObjects];
    
    for(b2Body* b=self.world->GetBodyList(); b; b=b->GetNext())
        self.world->DestroyBody(b);
    
    delete self.world;
}

- (void)addActor:(Actor*)actor {
    [self.actors addObject:actor];
}

@end