//
//  BossShip.h
//  SpaceBlaster2
//
//  Created by JRamos on 2/23/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"

@class ActionLayer;

/*******************************************************************************
 This is a subclass of GameObject with two methods—an initializer, and a method
 that the ActionLayer will call every frame to give the BossShip time to do
 actions. It passes the position of the ship as a parameter, because the
 BossShip will want to know where the space ship is so it can shoot at it.
 *******************************************************************************/

@interface BossShip : GameObject

- (id)initWithWorld:(b2World*)world layer:(ActionLayer*)layer;
- (void)updateWithShipPosition:(CGPoint)shipPosition;

@end
