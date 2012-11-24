//
//  GameObject.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/24/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "GameObject.h"
#import "ShapeCache.h"

@implementation GameObject {
    float _hp;
    b2World* _world;
    b2Body* _body;
    NSString *_shapeName;
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName world:(b2World *)world shapeName:(NSString *)shapeName maxHp:(float)maxHp {
    
    if ((self = [super
                 initWithSpriteFrameName:spriteFrameName])) {
        _hp = maxHp;
        _maxHp = maxHp;
        _world = world;
        _shapeName = shapeName;
    }
    return self;
}

- (void) destroyBody {
    if (_body != NULL) {
        _world->DestroyBody(_body);
        _body = NULL;
    }
}

- (void) createBody {
    
    [self destroyBody];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(self.position.x/PTM_RATIO,
                         self.position.y/PTM_RATIO);
    bodyDef.userData = (__bridge void *) self;
    _body = _world->CreateBody(&bodyDef);
    [[ShapeCache sharedShapeCache]
     addFixturesToBody:_body
     forShapeName:_shapeName
     scale:self.scale];
    [self setAnchorPoint:
     [[ShapeCache sharedShapeCache] anchorPointForShape:_shapeName]];
    
}

- (void)setNodeInvisible:(CCNode *)sender {
    sender.position = CGPointZero;
    sender.visible = NO;
    [self destroyBody];
}

- (void)revive {
    _hp = _maxHp;
    [self stopAllActions];
    self.visible = YES;
    self.opacity = 255;
    [self createBody];
}

- (BOOL)dead {
    return _hp == 0;
}

- (void)takeHit {
    if (_hp > 0) {
        _hp--;
    }
    if (_hp == 0) {
        [self destroy];
    }
}

- (void)destroy {
    
    _hp = 0;
    [self stopAllActions];
    [self runAction:
     [CCSequence actions:
      [CCFadeOut actionWithDuration:0.1],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(setNodeInvisible:)],
      nil]];
    
}

@end
