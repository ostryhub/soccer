//
//  GameScene.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright Rafał Ostrowski 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------

@class BallActor;
@class PlayerActor;

/**
 *  The main scene
 */
@interface GameScene : CCScene

@property (strong, nonatomic) BallActor *ball;

@property (strong, nonatomic) PlayerActor *playerKeeperA;
@property (strong, nonatomic) PlayerActor *playerStrikerA;

@property (strong, nonatomic) PlayerActor *playerKeeperB;
@property (strong, nonatomic) PlayerActor *playerStrikerB;


// -----------------------------------------------------------------------

+ (GameScene *)scene;
- (id)init;

// -----------------------------------------------------------------------
@end