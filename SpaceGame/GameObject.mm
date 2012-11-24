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
    HealthBarType _healthBarType;
    CCSprite * _healthBarBg;
    CCSprite * _healthBarProgress;
    CCSpriteFrame * _healthBarProgressFrame;
    float _fullWidth;
    float _displayedWidth;
}

- (void)setupHealthBar {
    
    if (_healthBarType == HealthBarTypeNone) return;
    
    _healthBarBg = [CCSprite spriteWithSpriteFrameName:
                    @"healthbar_bg.png"];
    _healthBarBg.position = ccpAdd(self.position,
     ccp(self.contentSize.width/2, -_healthBarBg.contentSize.height));
    [self addChild:_healthBarBg];
    
    NSString *progressSpriteName;
    if (_healthBarType == HealthBarTypeGreen) {
        progressSpriteName = @"healthbar_green.png";
    } else {
        progressSpriteName = @"healthbar_red.png";
    }
    _healthBarProgressFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:progressSpriteName];
    _healthBarProgress = [CCSprite spriteWithSpriteFrameName:progressSpriteName];
    _healthBarProgress.position =
    ccp(_healthBarProgress.contentSize.width/2,
        _healthBarProgress.contentSize.height/2);
    _fullWidth = _healthBarProgress.textureRect.size.width;
    [_healthBarBg addChild:_healthBarProgress];
    
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName world:(b2World *)world shapeName:(NSString *)shapeName maxHp:(float)maxHp healthBarType:(HealthBarType)healthBarType {
    
    if ((self = [super
                 initWithSpriteFrameName:spriteFrameName])) {
        _hp = maxHp;
        _maxHp = maxHp;
        _world = world;
        _shapeName = shapeName;
        
        _healthBarType = healthBarType;
        [self setupHealthBar];
        [self scheduleUpdate];
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
    _displayedWidth = _fullWidth;
    _healthBarBg.visible = NO;
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

- (void)update:(ccTime)dt {
    
    if (_healthBarType == HealthBarTypeNone) return;
    
    float POINTS_PER_SEC = 50;
    
    float percentage = _hp / _maxHp;
    percentage = MIN(percentage, 1.0);
    percentage = MAX(percentage, 0);
    float desiredWidth = _fullWidth *percentage;
    
    if (desiredWidth < _displayedWidth) {
        _displayedWidth = MAX(desiredWidth,
                              _displayedWidth - POINTS_PER_SEC*dt);
    } else {
        _displayedWidth = MIN(desiredWidth,
                              _displayedWidth + POINTS_PER_SEC*dt);
    }
    
    CGRect oldTextureRect = _healthBarProgressFrame.rect;
    CGRect newTextureRect = CGRectMake(
                                       oldTextureRect.origin.x, oldTextureRect.origin.y,
                                       _displayedWidth, oldTextureRect.size.height);
    
    [_healthBarProgress setTextureRect:newTextureRect rotated:_healthBarProgressFrame.rotated untrimmedSize:_healthBarProgressFrame.originalSize];
    
    _healthBarProgress.position = ccp(_displayedWidth/2,
                                      _healthBarProgress.contentSize.height/2);

    if (desiredWidth != _displayedWidth) {
        _healthBarBg.visible = TRUE;
        [_healthBarBg stopAllActions];
        [_healthBarBg runAction:
         [CCSequence actions:
          [CCFadeTo actionWithDuration:0.25 opacity:255],
          [CCDelayTime actionWithDuration:2.0],
          [CCFadeTo actionWithDuration:0.25 opacity:0],
          [CCCallFunc actionWithTarget:self selector:@selector(fadeOutDone)],
          nil]];
        [_healthBarProgress stopAllActions];
        [_healthBarProgress runAction:
         [CCSequence actions:
          [CCFadeTo actionWithDuration:0.25 opacity:255],
          [CCDelayTime actionWithDuration:2.0],
          [CCFadeTo actionWithDuration:0.25 opacity:0],
          nil]];
    }
    
}

- (void)fadeOutDone {
    _healthBarBg.visible = FALSE;
}

@end
