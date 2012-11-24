//
//  ParticleSystemArray.h
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/24/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "cocos2d.h"

@interface ParticleSystemArray : NSObject

- (id)initWithFile:(NSString *)file capacity:(int)capacity parent:(CCNode *)parent;
- (id)nextParticleSystem;
- (CCArray *)array;

@end
