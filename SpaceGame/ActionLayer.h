//
//  ActionLayer.h
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/22/12.
//  Copyright 2012 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

@interface ActionLayer : CCLayer

+ (id)scene;
- (void)beginContact:(b2Contact *)contact;
- (void)endContact:(b2Contact *)contact;
- (void)shootEnemyLaserFromPosition:(CGPoint)position;
- (void)shootCannonBallAtShipFromPosition:(CGPoint)position;

@end
