//
//  TestScene.h
//  SpaceGame
//
//  Created by JRamos on 3/4/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "HUDLayer.h"

@interface BigBoss : CCLayer {
    
    CCParticleSystemQuad *emitter;
    CCParticleSystemQuad *emitter2;
    CCParticleSystemQuad *emitter3;
    CCParticleSystemQuad *emitter4;
    CCParticleSystemQuad *emitter5;
    CCParticleSystemQuad *emitter6;
    
}

- (void)beginContact:(b2Contact *)contact;
- (void)endContact:(b2Contact *)contact;

+ (id)scene;

@end
