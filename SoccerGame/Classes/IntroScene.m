//
//  IntroScene.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 29/09/14.
//  Copyright Rafał Ostrowski 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "GameScene.h"
#import "Strings.h"

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0f green:1.0f blue:0.1f alpha:1.0f]];
    [self addChild:background];
    
    // Physics Soccer
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"SOCCER\nPHYSICS" fontName:@"ArialBlack" fontSize:60.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor whiteColor];
    label.position = ccp(0.5f, 0.5f); // Middle of screen
    [self addChild:label];
    
    float labelRockDuration = .3;   // seconds for one side slide
    float labelEaseRate = 0.5f;
    CCActionMoveTo *actionRockRight = [CCActionMoveTo actionWithDuration:labelRockDuration position:CGPointMake(0.52,0.5)];
    CCActionMoveTo *actionRockLeft = [CCActionMoveTo actionWithDuration:labelRockDuration position:CGPointMake(0.48,0.5)];
    CCActionSequence *actionSequence = [CCActionSequence actionWithArray:@[[CCActionEaseIn actionWithAction:actionRockRight rate:labelEaseRate],
                                                                           [CCActionEaseIn actionWithAction:actionRockLeft rate:labelEaseRate]]];
    
    [label runAction:[CCActionRepeatForever actionWithAction:actionSequence]];
    
    // OnePlayerButton scene button
    CCSpriteFrame *btn_1player_up = [CCSpriteFrame frameWithImageNamed: btn_menu_1_player_normal ];
    CCSpriteFrame *btn_1player_down = [CCSpriteFrame frameWithImageNamed: btn_menu_1_player_pushed];
    CCButton *btn_player_1 = [CCButton buttonWithTitle:@""
                                               spriteFrame:btn_1player_up
                                    highlightedSpriteFrame:btn_1player_down
                                       disabledSpriteFrame:btn_1player_up];
    
    btn_player_1.positionType = CCPositionTypeNormalized;
    btn_player_1.position = ccp(0.4f, 0.25f);
    [btn_player_1 setTarget:self selector:@selector(onOnePlayerGameClicked:)];
    [self addChild:btn_player_1];

    // twoPlayerButton scene button
    CCSpriteFrame *btn_2player_up = [CCSpriteFrame frameWithImageNamed: btn_menu_2_player_normal ];
    CCSpriteFrame *btn_2player_down = [CCSpriteFrame frameWithImageNamed: btn_menu_2_player_pushed];
    CCButton *btn_player_2 = [CCButton buttonWithTitle:@""
                                           spriteFrame:btn_2player_up
                                highlightedSpriteFrame:btn_2player_down
                                   disabledSpriteFrame:btn_2player_up];
    
    btn_player_2.positionType = CCPositionTypeNormalized;
    btn_player_2.position = ccp(0.6f, 0.25f);
    [btn_player_2 setTarget:self selector:@selector(onTwoPlayerGameClicked:)];
    [self addChild:btn_player_2];


    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onOnePlayerGameClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithMode:GameMode_OnePlayer]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.2f]];
}

- (void)onTwoPlayerGameClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithMode:GameMode_TwoPlayers]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.2f]];
}


// -----------------------------------------------------------------------
@end

