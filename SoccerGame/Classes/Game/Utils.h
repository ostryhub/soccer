//
//  Utils.h
//  SoccerGame
//
//  Created by Rafał Ostrowski on 01/10/14.
//  Copyright (c) 2014 Rafał Ostrowski. All rights reserved.
//

#ifndef SoccerGame_Utils_h
#define SoccerGame_Utils_h

#define ARC4RANDOM_MAX 0x100000000

inline float randomf() {return (float)arc4random() / ARC4RANDOM_MAX;}
inline float randomInRangef(float min, float max) { return randomf() * (max - min) + min;}

#endif
