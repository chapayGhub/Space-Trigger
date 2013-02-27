//
//  ParticleSystemArray.m
//  SpaceBlaster2
//
//  Created by JRamos on 2/23/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "ParticleSystemArray.h"

@implementation ParticleSystemArray {
    CCArray * _array;
    int _nextItem;
}

- (id)initWithFile:(NSString *)file capacity:(int)capacity parent:(CCNode *)parent {
    
    if ((self = [super init])) {
        
        _array = [[CCArray alloc]
                  initWithCapacity:capacity];
        for(int i = 0; i < capacity; ++i) {
            
            CCParticleSystemQuad *particleSystem =
            [CCParticleSystemQuad particleWithFile:file];
            [particleSystem stopSystem];
            [parent addChild:particleSystem z:10];
            [_array addObject:particleSystem];
            
        }
        
    }
    return self;
    
}

- (id)nextParticleSystem {
    CCParticleSystemQuad * retval =
    [_array objectAtIndex:_nextItem];
    _nextItem++;
    if (_nextItem >= _array.count) _nextItem = 0;
    
    // Reset particle system scale
    if (UI_USER_INTERFACE_IDIOM() !=
        UIUserInterfaceIdiomPad) {
        retval.scale = 0.5;
    } else {
        retval.scale = 1.0;
    }
    
    return retval;
}

- (CCArray *)array {
    return _array;
}

@end

