//
//  SpriteArray.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/23/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "SpriteArray.h"

@implementation SpriteArray {
    CCArray * _array;
    int _nextItem;
}

- (id)initWithCapacity:(int)capacity spriteFrameName:(NSString *)spriteFrameName batchNode:(CCSpriteBatchNode *)batchNode {
    
    if ((self = [super init])) {
        
        _array = [[CCArray alloc] initWithCapacity:capacity];
        for(int i = 0; i < capacity; ++i) {
            CCSprite *sprite = [CCSprite
                                spriteWithSpriteFrameName:spriteFrameName];
            sprite.visible = NO;
            [batchNode addChild:sprite];
            [_array addObject:sprite];
        }
        
    }
    return self;
    
}

- (id)nextSprite {
    id retval = [_array objectAtIndex:_nextItem];
    _nextItem++;
    if (_nextItem >= _array.count) _nextItem = 0;
    return retval;
}

- (CCArray *)array {
    return _array;
}

@end
