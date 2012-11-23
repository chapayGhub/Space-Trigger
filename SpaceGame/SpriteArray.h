//
//  SpriteArray.h
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/23/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"

@interface SpriteArray : NSObject

- (id)initWithCapacity:(int)capacity spriteFrameName:(NSString *)spriteFrameName batchNode:(CCSpriteBatchNode *)batchNode;
- (id)nextSprite;
- (CCArray *)array;

@end
