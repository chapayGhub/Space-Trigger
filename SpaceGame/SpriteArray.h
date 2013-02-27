//
//  SpriteArray.h
//  SpaceBlaster2
//
//  Created by JRamos on 2/22/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameObject.h"

@interface SpriteArray : NSObject

//This class has an initializer and two helper methods – one to get the next available sprite, and one to get the array of sprites.
//Note that this uses CCArray for the array of sprites, instead of NSMutableArray. CCArray is a helper class that comes with Cocos2D that has an API very similar to NSMutableArray, but it’s optimized for speed.
- (id)initWithCapacity:(int)capacity spriteFrameName:(NSString *)spriteFrameName batchNode:(CCSpriteBatchNode *)batchNode world:(b2World *)world shapeName:(NSString *)shapeName maxHp:(int)maxHp healthBarType:(HealthBarType)healthBarType;
- (id)nextSprite;
- (CCArray *)array;

@end
