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
@class Box2DNode;

typedef enum _GameState {
    GameState_Play,
    GameState_Goal,
    GameState_BallOut
} GameState;

/**
 *  The main scene
 */
@interface GameScene : CCScene

// GameState
@property (nonatomic) GameState gameState;

// Nodes
@property (strong, nonatomic) Box2DNode *box2DNode;
@property (strong, nonatomic) CCNode *goalNode;

// Actors
@property (strong, nonatomic) BallActor *ball;

@property (strong, nonatomic) PlayerActor *playerKeeperA;
@property (strong, nonatomic) PlayerActor *playerStrikerA;

@property (strong, nonatomic) PlayerActor *playerKeeperB;
@property (strong, nonatomic) PlayerActor *playerStrikerB;

// Score
@property (nonatomic) int scoreTeamA;
@property (nonatomic) int scoreTeamB;

// -----------------------------------------------------------------------

+ (GameScene *)scene;
- (id)init;

- (void)startNewMatch;

// -----------------------------------------------------------------------
@end