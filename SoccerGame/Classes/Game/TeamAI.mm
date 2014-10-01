//
//  TeamAI.m
//  SoccerGame
//
//  Created by Rafał Ostrowski on 01/10/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#import "TeamAI.h"
#import "PlayerActor.h"
#import "Strings.h"
#import "Utils.h"

#define BALL_DISTANCE_LIMIT 1.7

@implementation TeamAI {
    float _time;
    
    float _kickDuration;
    float _kickTime;
    
    float _noKickDuration;
    float _noKickTime;
    
    float _lastTimeRandomKick;
    BOOL _shouldPerformRandomKick;

    BOOL _ballCloseEnough;
    CGPoint _ballPosition;
}

- (id)initWithPlayers:(NSArray *)players {
    if (self=[super init])
    {
        self.state = AI_STATE_IDLE;
        self.players = players;
    }
    return self;
}

- (void)gatherData {
    _ballCloseEnough = NO;
    
    for(PlayerActor *player in self.players)
    {
        CGPoint p = CGPointMake(player.chestBody ->GetPosition().x, player.weightBody->GetPosition().y);
        p.x -= _ballPosition.x;
        p.y -= _ballPosition.y;

        float dist = sqrtf(p.x*p.x+p.y*p.y);
        _ballCloseEnough = _ballCloseEnough ? YES : dist<=BALL_DISTANCE_LIMIT;
    }
    
    if (_time>_lastTimeRandomKick+0.5)
    {
        _lastTimeRandomKick = _time;
        _shouldPerformRandomKick = randomf() <.6;
    }
}

- (void)performAIwithDelta:(float)delta andBallPosition:(CGPoint)position {

    // Gathering Data
    
    _time += delta;
    _ballPosition = position;
    
    // wait a second before hitting on the ball
    if (_time<1)
        return;
    
    [self gatherData];
    
    // Decisions
    
    switch(self.state)
    {
        case AI_STATE_IDLE:
            if (_ballCloseEnough || _shouldPerformRandomKick)
            {
                _shouldPerformRandomKick = NO;
                
                _kickDuration = randomInRangef(0.3, 0.8);
                _kickTime = _time;
                
                for(PlayerActor *player in self.players)
                {
                    [player jumpInDirection:_ballPosition];
                    [player startKick];
                }
                
                self.state = AI_STATE_KICK;
            }
            break;
            
        case AI_STATE_KICK:
            if (_time>_kickTime+_kickDuration || !_ballCloseEnough)
            {
                for(PlayerActor *player in self.players)
                    [player stopKick];

                _noKickDuration = randomInRangef(0.2, 0.5);
                _noKickTime = _time;

                self.state = AI_STATE_NOKICK;
            }
            break;
            
        case AI_STATE_NOKICK:
            if (_time>_noKickTime+_noKickDuration || !_ballCloseEnough)
                self.state = AI_STATE_IDLE;
            break;
    }
    
}

@end
