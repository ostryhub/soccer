//
//  Box2DNode.h
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import "CCNode.h"
#import "Box2D.h"

/**
 * Box2DNode is the root physics node of the scene. All physics actors need to be descendants of this node.
 * Bacause Box2D likes objects around ~1m in size this node "active area" is about 10x7.7 units.
 * Later on a scale value is applied to this node to stretch it so that it fill the whole available screen space.
 */
@interface Box2DNode : CCNode

@property (nonatomic) b2World* world;

- (id)initWithGravity:(b2Vec2 &)gravity;
- (void)dealloc;

@end
