//
//  ParticleSystemArray.h
//  SpaceBlaster2
//
//  Created by JRamos on 2/23/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ParticleSystemArray : NSObject

//This is almost exactly like SpriteArray.
- (id)initWithFile:(NSString *)file capacity:(int)capacity parent:(CCNode *)parent;
- (id)nextParticleSystem;
- (CCArray *)array;

@end
