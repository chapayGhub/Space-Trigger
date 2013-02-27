//
//  SpriteArray.mm
//  SpaceBlaster2
//
//  Created by JRamos on 2/22/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "SpriteArray.h"

@implementation SpriteArray
{
    CCArray * _array;
    int _nextItem;
}

/*******************************************************************************
 * @method
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 The initializer creates a new array and fills it with a number of sprites,
 specified via the capacity variable. For each sprite, it sets it to initially
 invisible and adds it to the batch node and the array.
 *******************************************************************************/
- (id)initWithCapacity:(int)capacity spriteFrameName:(NSString *)spriteFrameName batchNode:(CCSpriteBatchNode *)batchNode world:(b2World *)world shapeName:(NSString *)shapeName maxHp:(int)maxHp healthBarType:(HealthBarType)healthBarType
{
    
    if ((self = [super init])){
        
        _array = [[CCArray alloc] initWithCapacity:capacity];
        for(int i = 0; i < capacity; ++i) {
            GameObject *sprite = [[GameObject alloc] initWithSpriteFrameName:spriteFrameName world:world shapeName:shapeName maxHp:maxHp healthBarType:healthBarType];
            sprite.visible = NO;
            [batchNode addChild:sprite];
            [_array addObject:sprite];
        }
        
    }
    return self;
    
}

/*******************************************************************************
 * @method      nextSprite
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 nextSprite is a helper method that gets the next available sprite and returns
 it—advancing the _nextItem variable along the way. It returns the item as an
 id type.
 *******************************************************************************/
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
