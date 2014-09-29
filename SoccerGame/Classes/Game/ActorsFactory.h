//
//  ActorsFactory.h
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2DNode.h"

@interface ActorsFactory : NSObject

+ (CCNode *)createBallWithImage:(NSString*)image radius:(float)radius position:(CGPoint)position andDensity:(float)density withBox2DNode:(Box2DNode*)box2DNode;

@end
