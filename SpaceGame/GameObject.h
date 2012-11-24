//
//  GameObject.h
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/24/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "Common.h"

typedef enum {
    HealthBarTypeNone = 0,
    HealthBarTypeGreen,
    HealthBarTypeRed
} HealthBarType;

@interface GameObject : CCSprite

@property (assign) float maxHp;

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName world:(b2World *)world shapeName:(NSString *)shapeName maxHp:(float)maxHp healthBarType:(HealthBarType)healthBarType;
- (BOOL)dead;
- (void)destroy;
- (void)revive;
- (void)takeHit;

@end
