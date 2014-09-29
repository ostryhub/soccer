//
//  GameScene.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright Rafał Ostrowski 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "GameScene.h"
#import "Strings.h"
#import "IntroScene.h"
#import "Box2D.h"
#import "Box2DNode.h"
#import "ActorsFactory.h"
#import "PhysicsFactory.h"

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
    float visibleSceneWidth = 20;
    float viewScale = viewSize.width/(visibleSceneWidth*contentScaleFactor);
    
    // set up physics enabling node
    b2Vec2 gravity(0,-10);
    Box2DNode *box2DNode = [[Box2DNode alloc] initWithGravity:gravity];
    box2DNode.scale = viewScale;
    [self addChild:box2DNode];
    
    
    CCNode *ball = [ActorsFactory createBallWithImage:sprite_ball_soccer
                                               radius:0.5f
                                             position:CGPointMake(10,5)
                                           andDensity:1.0f
                                        withBox2DNode:box2DNode];
    [box2DNode addChild:ball];
    
    [PhysicsFactory createGroundBoxWithSize:CGSizeMake(10,0.1) andPosition:CGPointMake(10,1) withBox2DNode:box2DNode];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];

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
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    
    // Move our sprite to touch location
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:1.0f position:touchLoc];
    [_sprite runAction:actionMove];
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

// -----------------------------------------------------------------------
@end
