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
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
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
    
    // Start match
    [self startNewMatch];
    
    ///////////////////////////////////////////////////////////////////////////////////
    // UI CONTROLS
    
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
    [kickButton setTouchBeganTarget:self selector:@selector(onKickBegan:)];
    [kickButton setTouchEndedTarget:self selector:@selector(onKickEnded:)];
    [self addChild:kickButton];

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
    
    if (self.ball)
        [self.ball.ball.parent removeChild:self.ball.ball];
    
    self.teamAI = nil;
    
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
    
    // Create ground
    [PhysicsFactory createGroundBoxWithSize:CGSizeMake(30,0.5) andPosition:CGPointMake(5,1) withBox2DNode:self.box2DNode];
    
    // Init Ball
    self.ball = [[BallActor alloc] initWithPosition:CGPointMake(5,5) radius:0.25f andBox2DNode:self.box2DNode];
    
    // Init Players
    static CGSize playerSize = CGSizeMake(.8,1.6);

    self.playerKeeperA = [[PlayerActor alloc] initWithPosition:CGPointMake(2.8,3.5) size:playerSize team:TeamA andBox2DNode:self.box2DNode];
    self.playerStrikerA = [[PlayerActor alloc] initWithPosition:CGPointMake(4.0,3.5) size:playerSize team:TeamA andBox2DNode:self.box2DNode];
    self.playerKeeperB = [[PlayerActor alloc] initWithPosition:CGPointMake(7.2,3) size:playerSize team:TeamB andBox2DNode:self.box2DNode];
    self.playerStrikerB = [[PlayerActor alloc] initWithPosition:CGPointMake(6,3.5) size:playerSize team:TeamB andBox2DNode:self.box2DNode];

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

    // Add actors to box2DNode so that they can be prompted to update their logic
    [self.box2DNode addActor:self.ball];
    [self.box2DNode addActor:self.playerKeeperA];
    [self.box2DNode addActor:self.playerStrikerA];
    [self.box2DNode addActor:self.playerKeeperB];
    [self.box2DNode addActor:self.playerStrikerB];
    
    // Create AI for tema A
    self.teamAI = [[TeamAI alloc] initWithPlayers:@[self.playerKeeperA, self.playerStrikerA]];
}

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

    CCButton *btnNextMatch = [CCButton buttonWithTitle:@"Next match" fontName:@"ArialBlack" fontSize:60.0f];
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
    
    CCButton *btnNextMatch = [CCButton buttonWithTitle:@"Next match" fontName:@"ArialBlack" fontSize:60.0f];
    btnNextMatch.positionType = CCPositionTypeNormalized;
    btnNextMatch.position = ccp(0.5f, 0.25f);
    [btnNextMatch setTarget:self selector:@selector(onNextMatch)];
    [self.goalNode addChild:btnNextMatch];
    
    [self addChild:self.goalNode];
    [self.goalNode runAction:[CCActionMoveTo actionWithDuration:1.0f position:CGPointMake(0.5,0.5)]];
}

- (void)update:(CCTime)delta {
    
    switch(self.gameState)
    {
        case GameState_Play:

            // Ball checks
            if (self.ball)
            {
                CGPoint p = self.ball.ball.position;
                if (p.x<1.5 && p.x>0.5 && p.y<4.25)
                {
                    self.scoreTeamB++;
                    self.ball = nil;
                    [self goal];
                }
                else if (p.x>8.5 && p.x<9.5 && p.y<4.25)
                {
                    self.scoreTeamA++;
                    self.ball = nil;
                    [self goal];
                }
                else if (p.x<0 || p.x>10)
                {
                    self.ball = nil;
                    [self ballOut];
                }
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

- (void)dealloc {
    self.ball = nil;
    self.playerKeeperA = nil;
    self.playerStrikerA = nil;
    self.playerKeeperB = nil;
    self.playerStrikerB = nil;
}

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
}

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.2f]];
}

- (void)onKickBegan:(id)sender
{
    [self.playerStrikerB jumpInDirection:[self.ball getPosition]];
    [self.playerKeeperB jumpInDirection:[self.ball getPosition]];

    [self.playerStrikerB startKick];
    [self.playerKeeperB startKick];
}

- (void)onKickEnded:(id)sender
{
    [self.playerStrikerB stopKick];
    [self.playerKeeperB stopKick];
}

- (void)onNextMatch {
    [self removeChild:self.goalNode];
    [self startNewMatch];
}

// -----------------------------------------------------------------------
@end
