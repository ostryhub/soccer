//
//  GameScene.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright Rafał Ostrowski 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "GameScene.h"
#import "IntroScene.h"
#import "Button.h"

#import "Strings.h"

#import "Box2D.h"
#import "Box2DNode.h"

#import "PhysicsFactory.h"
#import "BallActor.h"
#import "PlayerActor.h"

#import "TeamAI.h"

#pragma mark - GameScene

@implementation GameScene

+ (GameScene *)scene
{
    return [[self alloc] initWithMode:GameMode_OnePlayer];
}

+ (GameScene *)sceneWithMode:(GameMode)mode
{
    return [[self alloc] initWithMode:mode];
}

// -----------------------------------------------------------------------

- (id)initWithMode:(GameMode)mode
{
    self.multipleTouchEnabled = YES;
    self.gameMode = mode;
    
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // Create a colored background
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.7f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    
    // Score label
    self.labelScore = [CCLabelTTF labelWithString:[self getScoreText] fontName:@"ArialBlack" fontSize:60.0f];
    self.labelScore.positionType = CCPositionTypeNormalized;
    self.labelScore.color = [CCColor whiteColor];
    self.labelScore.position = ccp(0.5f, 0.8f);
    [self addChild:self.labelScore];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
    
    // kickButton scene button
    CCSpriteFrame *btn_1player_up = [CCSpriteFrame frameWithImageNamed: btn_menu_1_player_normal ];
    CCSpriteFrame *btn_1player_down = [CCSpriteFrame frameWithImageNamed: btn_menu_1_player_pushed];
    Button *kickButton = [Button buttonWithTitle:@""
                                     spriteFrame:btn_1player_up
                          highlightedSpriteFrame:btn_1player_down
                             disabledSpriteFrame:btn_1player_up];
    
    kickButton.positionType = CCPositionTypeNormalized;
    kickButton.position = ccp(0.9f, 0.1f);
    [kickButton setTouchBeganTarget:self selector:@selector(onKickBeganTeamB:)];
    [kickButton setTouchEndedTarget:self selector:@selector(onKickEndedTeamB:)];
    kickButton.exclusiveTouch = NO;
    [self addChild:kickButton];
    kickButton.multipleTouchEnabled = YES;
    
    if (self.gameMode==GameMode_TwoPlayers)
    {
        CCSpriteFrame *btn_2player_up = [CCSpriteFrame frameWithImageNamed: btn_menu_2_player_normal ];
        CCSpriteFrame *btn_2player_down = [CCSpriteFrame frameWithImageNamed: btn_menu_2_player_pushed];
        Button *kickButton = [Button buttonWithTitle:@""
                                         spriteFrame:btn_2player_up
                              highlightedSpriteFrame:btn_2player_down
                                 disabledSpriteFrame:btn_2player_up];
        
        kickButton.positionType = CCPositionTypeNormalized;
        kickButton.position = ccp(0.1f, 0.1f);
        [kickButton setTouchBeganTarget:self selector:@selector(onKickBeganTeamA:)];
        [kickButton setTouchEndedTarget:self selector:@selector(onKickEndedTeamA:)];
        kickButton.exclusiveTouch = NO;
        [self addChild:kickButton];
        kickButton.multipleTouchEnabled = YES;
    }

    // Start match
    [self startNewMatch];
    
    // done
	return self;
}

- (NSString *)getScoreText {
    return [NSString stringWithFormat:@"%d - %d", self.scoreTeamA, self.scoreTeamB];
}

- (void)startNewMatch {
    
    self.gameState = GameState_Play;
    
    if (self.box2DNode)
        [self removeChild:self.box2DNode];
    
    [self.labelScore setString:[self getScoreText]];
    
    // Cocos2d "display values"
    CGSize viewSize = [[CCDirector sharedDirector] viewSizeInPixels];
    float contentScaleFactor = [CCDirector sharedDirector].contentScaleFactor;
    
    // how many meters wide we want to display (in box2d meters, since my arbitrary set box2d world scale is 1 unit == 1 meter)
    float visibleSceneWidth = 10;
    float viewScale = viewSize.width/(visibleSceneWidth*contentScaleFactor);
    
    // set up physics node
    b2Vec2 gravity(0,-8);
    self.box2DNode = [[Box2DNode alloc] initWithGravity:gravity];
    self.box2DNode.scale = viewScale;
    [self addChild:self.box2DNode];
    self.box2DNode.multipleTouchEnabled = YES;
    
    // Init Ball
    self.ball = [[BallActor alloc] initWithPosition:CGPointMake(5,5) radius:0.25f andBox2DNode:self.box2DNode];
    
    // Init Players
    static CGSize playerSize = CGSizeMake(.8,1.6);
    self.playerKeeperA = [[PlayerActor alloc] initWithPosition:CGPointMake(2.8,3.5) size:playerSize team:TeamA andBox2DNode:self.box2DNode];
    self.playerStrikerA = [[PlayerActor alloc] initWithPosition:CGPointMake(4.0,3.5) size:playerSize team:TeamA andBox2DNode:self.box2DNode];
    self.playerKeeperB = [[PlayerActor alloc] initWithPosition:CGPointMake(7.2,3) size:playerSize team:TeamB andBox2DNode:self.box2DNode];
    self.playerStrikerB = [[PlayerActor alloc] initWithPosition:CGPointMake(6,3.5) size:playerSize team:TeamB andBox2DNode:self.box2DNode];

    // Add actors to box2DNode so that they can be prompted to update their logic
    self.actors = @[self.ball, self.playerKeeperA, self.playerStrikerA, self.playerKeeperB, self.playerStrikerB];
    
    if (self.gameMode==GameMode_OnePlayer)
    {
        // Create AI for tema A
        self.teamAI = [[TeamAI alloc] initWithPlayers:@[self.playerKeeperA, self.playerStrikerA]];
    }

    // Uncomment this line if you want to see CPU competing with itself
    //self.teamAI = [[TeamAI alloc] initWithPlayers:@[self.playerKeeperA, self.playerStrikerA, self.playerKeeperB, self.playerStrikerB]];

    // Create ground
    [PhysicsFactory createGroundBoxWithSize:CGSizeMake(30,0.5) andPosition:CGPointMake(5,1) withBox2DNode:self.box2DNode];
    
    // Create goal A
    [PhysicsFactory createGroundBoxWithSize:CGSizeMake(0.1,3) andPosition:CGPointMake(0.55, 2.75) withBox2DNode:self.box2DNode];
    [PhysicsFactory createGroundBoxWithSize:CGSizeMake(1.3,0.1) andPosition:CGPointMake(1.15, 4.2) withBox2DNode:self.box2DNode];
    CCSprite *goalA = [CCSprite spriteWithImageNamed:sprite_goal];
    goalA.anchorPoint = CGPointMake(0.5, 0.5);
    goalA.scaleX = -1.3/goalA.contentSize.width;
    goalA.scaleY = 3.0/goalA.contentSize.height;
    goalA.position = CGPointMake(1.15,2.75);
    [self.box2DNode addChild:goalA];
    
    // Create goal B
    [PhysicsFactory createGroundBoxWithSize:CGSizeMake(0.1,3) andPosition:CGPointMake(9.45, 2.75) withBox2DNode:self.box2DNode];
    [PhysicsFactory createGroundBoxWithSize:CGSizeMake(1.3,0.1) andPosition:CGPointMake(8.85, 4.2) withBox2DNode:self.box2DNode];
    CCSprite *goalB = [CCSprite spriteWithImageNamed:sprite_goal];
    goalB.anchorPoint = CGPointMake(0.5, 0.5);
    goalB.scaleX = 1.3/goalA.contentSize.width;
    goalB.scaleY = 3.0/goalA.contentSize.height;
    goalB.position = CGPointMake(8.85,2.75);
    [self.box2DNode addChild:goalB];

}

#pragma mark - In game middle screens

- (void)goal {
    if (self.gameState != GameState_Play)
        return;
    
    self.gameState = GameState_Goal;
    
    if (self.box2DNode)
        self.box2DNode.slowRate = 4;
    
    self.goalNode = [[CCNode alloc] init];
    self.goalNode.anchorPoint = CGPointMake(0.5, 0.5);
    self.goalNode.contentSize = self.contentSize;
    self.goalNode.positionType = CCPositionTypeNormalized;
    self.goalNode.position = CGPointMake(0.5, 2);
    
    // Create a colored background
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:0.2f]];
    [self.goalNode addChild:background];

    CCLabelTTF *labelGoal = [CCLabelTTF labelWithString:@"!!! GOAL !!!" fontName:@"ArialBlack" fontSize:60.0f];
    labelGoal.positionType = CCPositionTypeNormalized;
    labelGoal.color = [CCColor whiteColor];
    labelGoal.position = ccp(0.5f, 0.7f);
    [self.goalNode addChild:labelGoal];

    CCButton *btnNextMatch = [CCButton buttonWithTitle:@"[ Next match ]" fontName:@"ArialBlack" fontSize:60.0f];
    btnNextMatch.positionType = CCPositionTypeNormalized;
    btnNextMatch.position = ccp(0.5f, 0.25f);
    [btnNextMatch setTarget:self selector:@selector(onNextMatch)];
    [self.goalNode addChild:btnNextMatch];
    
    [self addChild:self.goalNode];
    [self.goalNode runAction:[CCActionMoveTo actionWithDuration:1.0f position:CGPointMake(0.5,0.5)]];
}

- (void)ballOut {
    if (self.gameState != GameState_Play)
        return;
    
    self.gameState = GameState_BallOut;
    
    if (self.box2DNode)
        self.box2DNode.slowRate = 4;
    
    self.goalNode = [[CCNode alloc] init];
    self.goalNode.anchorPoint = CGPointMake(0.5, 0.5);
    self.goalNode.contentSize = self.contentSize;
    self.goalNode.positionType = CCPositionTypeNormalized;
    self.goalNode.position = CGPointMake(0.5, 2);
    
    // Create a colored background
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:0.2f]];
    [self.goalNode addChild:background];
    
    CCLabelTTF *labelGoal = [CCLabelTTF labelWithString:@"BALL OUT" fontName:@"ArialBlack" fontSize:60.0f];
    labelGoal.positionType = CCPositionTypeNormalized;
    labelGoal.color = [CCColor whiteColor];
    labelGoal.position = ccp(0.5f, 0.7f);
    [self.goalNode addChild:labelGoal];
    
    CCButton *btnNextMatch = [CCButton buttonWithTitle:@"[ Next match ]" fontName:@"ArialBlack" fontSize:60.0f];
    btnNextMatch.positionType = CCPositionTypeNormalized;
    btnNextMatch.position = ccp(0.5f, 0.25f);
    [btnNextMatch setTarget:self selector:@selector(onNextMatch)];
    [self.goalNode addChild:btnNextMatch];
    
    [self addChild:self.goalNode];
    [self.goalNode runAction:[CCActionMoveTo actionWithDuration:1.0f position:CGPointMake(0.5,0.5)]];
}

#pragma mark - Main game "loop"


- (void)update:(CCTime)delta {
    
    // Update actors logic
    for(Actor *actor in self.actors)
        [actor logic];
    
    switch(self.gameState)
    {
        case GameState_Play:
            // Ball checks
            switch(self.ball.state)
            {
                case BallState_InsideGoalA:
                    self.scoreTeamB++;
                    self.ball = nil;
                    [self goal];
                    break;
                    
                case BallState_InsideGoalB:
                    self.scoreTeamA++;
                    self.ball = nil;
                    [self goal];
                    break;
                case BallState_Out:
                    self.ball = nil;
                    [self ballOut];
                    break;

                default:
                case BallState_Play:break;

            }

            // TeamA AI
            [self.teamAI performAIwithDelta:delta andBallPosition:self.ball.ball.position];
            
            break;
            
        default:
        case GameState_Goal:
        case GameState_BallOut:
            break;
    }
}

#pragma mark - UI Callbacks

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.2f]];
}

- (void)onKickBeganTeamB:(id)sender
{
    [self.playerStrikerB jumpInDirection:[self.ball getPosition]];
    [self.playerKeeperB jumpInDirection:[self.ball getPosition]];

    [self.playerStrikerB startKick];
    [self.playerKeeperB startKick];
}

- (void)onKickEndedTeamB:(id)sender
{
    [self.playerStrikerB stopKick];
    [self.playerKeeperB stopKick];
}

- (void)onKickBeganTeamA:(id)sender
{
    [self.playerStrikerA jumpInDirection:[self.ball getPosition]];
    [self.playerKeeperA jumpInDirection:[self.ball getPosition]];
    
    [self.playerStrikerA startKick];
    [self.playerKeeperA startKick];
}

- (void)onKickEndedTeamA:(id)sender
{
    [self.playerStrikerA stopKick];
    [self.playerKeeperA stopKick];
}


- (void)onNextMatch {
    [self removeChild:self.goalNode];
    [self startNewMatch];
}

// -----------------------------------------------------------------------
@end
