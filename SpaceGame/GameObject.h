//
//  GameObject.h
//  SpaceBlaster2
//
//  Created by JRamos on 2/22/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "Common.h"

@interface GameObject : CCSprite

//This declares the type of health bar to display for the GameObject.
typedef enum {
    HealthBarTypeNone = 0,
    HealthBarTypeGreen,
    HealthBarTypeRed
} HealthBarType;


//This creates a subclass of CCSprite that has instance variables for the object’s current hit point, max hit points, a reference to the Box2D world, the Box2D shape that it is associated with, and the name of the shape made with Physics Editor.
//It also has a few helper methods. A method to check if the object is “dead” (i.e. 0 hp), a method to destroy the object, a method to bring the object “back to life”, and a method to make the object take a hit (i.e. lose an hp).

@property (assign) float maxHp;

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName world:(b2World *)world shapeName:(NSString *)shapeName maxHp:(float)maxHp healthBarType:(HealthBarType)healthBarType;
- (BOOL)dead;
- (void)destroy;
- (void)revive;
- (void)takeHit;
-(float)whatHP;

@end
