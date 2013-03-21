//
//  BigTurret.h
//  SpaceGame
//
//  Created by JRamos on 2/26/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "GameObject.h"

@class ActionLayer;

/*******************************************************************************

 *******************************************************************************/

@interface BigTurret : GameObject

- (id)initWithWorld:(b2World*)world layer:(ActionLayer*)layer;
- (void)updateWithShipPosition:(CGPoint)shipPosition;
-(void)turretDead;

@end
