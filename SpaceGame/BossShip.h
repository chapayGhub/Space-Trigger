//
//  BossShip.h
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/24/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "GameObject.h"

@class ActionLayer;

@interface BossShip : GameObject

- (id)initWithWorld:(b2World*)world layer:(ActionLayer*)layer;
- (void)updateWithShipPosition:(CGPoint)shipPosition;

@end
