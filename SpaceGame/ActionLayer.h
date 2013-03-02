//
//  ActionLayer.h
//  SpaceBlaster
//
//  Created by JRamos on 2/22/13.
//  Copyright 2013 JRamos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface ActionLayer : CCLayer + (id)scene;

- (void)beginContact:(b2Contact *)contact;
- (void)endContact:(b2Contact *)contact;

- (void)shootEnemyLaserFromPosition:(CGPoint)position;
- (void)shootEnemyVerticalDownLaserFromPosition:(CGPoint)position;
- (void)shootEnemyVerticalUpLaserFromPosition:(CGPoint)position;


- (void)shootCannonBallAtShipFromPosition:(CGPoint)position;

@end
