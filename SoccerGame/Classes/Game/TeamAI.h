//
//  TeamAI.h
//  SoccerGame
//
//  Created by Rafał Ostrowski on 01/10/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _AI_STATE {
    AI_STATE_IDLE,
    AI_STATE_KICK,
    AI_STATE_NOKICK,
    
} AI_STATE;

@interface TeamAI : NSObject

@property (strong, nonatomic) NSArray *players;
@property (nonatomic) AI_STATE state;

- (id)initWithPlayers:(NSArray *)players;
- (void)performAIwithDelta:(float)delta andBallPosition:(CGPoint)position;

@end
