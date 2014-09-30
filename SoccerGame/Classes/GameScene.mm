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

#pragma mark - GameScene

@implementation GameScene
{
    CCSprite *_sprite;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

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
    
    // Cocos2d "display values"
    CGSize viewSize = [[CCDirector sharedDirector] viewSizeInPixels];
    float contentScaleFactor = [CCDirector sharedDirector].contentScaleFactor;

    // how many meters wide we want to display (in box2d meters, since my arbitrary set box2d world scale is 1 unit == 1 meter)
    float visibleSceneWidth = 10;
    float viewScale = viewSize.width/(visibleSceneWidth*contentScaleFactor);
    
    // set up physics node
    b2Vec2 gravity(0,-10);
    Box2DNode *box2DNode = [[Box2DNode alloc] initWithGravity:gravity];
    box2DNode.scale = viewScale;
    [self addChild:box2DNode];
    
    // Create ground
    [PhysicsFactory createGroundBoxWithSize:CGSizeMake(30,0.2) andPosition:CGPointMake(5,1) withBox2DNode:box2DNode];
    
    // Init actors
    self.ball = [[BallActor alloc] initWithPosition:CGPointMake(5,7) radius:0.25f andBox2DNode:box2DNode];
    
    static CGSize playerSize = CGSizeMake(.8,2);
    self.playerKeeperA = [[PlayerActor alloc] initWithPosition:CGPointMake(2,3) size:playerSize team:TeamA andBox2DNode:box2DNode];
    self.playerStrikerA = [[PlayerActor alloc] initWithPosition:CGPointMake(2.5,3) size:playerSize team:TeamA andBox2DNode:box2DNode];
    self.playerKeeperB = [[PlayerActor alloc] initWithPosition:CGPointMake(8,3) size:playerSize team:TeamB andBox2DNode:box2DNode];
    self.playerStrikerB = [[PlayerActor alloc] initWithPosition:CGPointMake(7.5,3) size:playerSize team:TeamB andBox2DNode:box2DNode];
    
    // Add actors to box2DNode so that they can be prompted to update their logic
    [box2DNode addActor:self.ball];
    [box2DNode addActor:self.playerKeeperA];
    [box2DNode addActor:self.playerStrikerA];
    [box2DNode addActor:self.playerKeeperB];
    [box2DNode addActor:self.playerStrikerB];
    
    
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
    kickButton.position = ccp(0.8f, 0.25f);
    [kickButton setTouchBeganTarget:self selector:@selector(onKickBegan:)];
    [kickButton setTouchEndedTarget:self selector:@selector(onKickEnded:)];
    [self addChild:kickButton];


    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

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
    [self.playerStrikerA jumpInDirection:[self.ball getPosition]];
    [self.playerKeeperA jumpInDirection:[self.ball getPosition]];
    
    [self.playerStrikerA startKick];
    [self.playerKeeperA startKick];

    
    [self.playerStrikerB jumpInDirection:[self.ball getPosition]];
    [self.playerKeeperB jumpInDirection:[self.ball getPosition]];

    [self.playerStrikerB startKick];
    [self.playerKeeperB startKick];
}

- (void)onKickEnded:(id)sender
{
    [self.playerStrikerA stopKick];
    [self.playerKeeperA stopKick];
    
    [self.playerStrikerB stopKick];
    [self.playerKeeperB stopKick];
}

// -----------------------------------------------------------------------
@end
