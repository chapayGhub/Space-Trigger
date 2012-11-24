//
//  BossShip.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/24/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "BossShip.h"
#import "ActionLayer.h"

@implementation BossShip {
    ActionLayer * _layer;
    BOOL _initialMove;
    CCSprite * _shooter1;
    CCSprite * _shooter2;
    CCSprite * _cannon;
}

- (id)initWithWorld:(b2World*)world layer:(ActionLayer*)layer {
    
    if ((self = [super initWithSpriteFrameName:@"Boss_ship.png" world:world shapeName:@"Boss_ship" maxHp:50 healthBarType:HealthBarTypeRed])) {
        _layer = layer;
        
        _shooter1 = [CCSprite
                     spriteWithSpriteFrameName:@"Boss_shooter.png"];
        _shooter1.position = ccp(self.contentSize.width*0.65,
                                 self.contentSize.height*0.5);
        [self addChild:_shooter1];
        
        _shooter2 = [CCSprite
                     spriteWithSpriteFrameName:@"Boss_shooter.png"];
        _shooter2.position = ccp(self.contentSize.width*0.55,
                                 self.contentSize.height*0.1);
        [self addChild:_shooter2];
        
        _cannon = [CCSprite
                   spriteWithSpriteFrameName:@"Boss_cannon.png"];
        _cannon.position = ccp(self.contentSize.width*0.5, 
                               self.contentSize.height * 0.95);
        [self addChild:_cannon z:-1];

    }
    return self;
}

- (void)updateWithShipPosition:(CGPoint)shipPosition {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    if (!_initialMove) {
        _initialMove = YES;
        CGPoint midScreen =
        ccp(winSize.width/2, winSize.height/2);
        [self runAction:
         [CCMoveTo actionWithDuration:4.0
                             position:midScreen]];
    }
    
    CGPoint cannonHeadWorld =
    [self convertToWorldSpace:
     ccp(_cannon.position.x - _cannon.contentSize.width/2,
         _cannon.position.y)];
    CGPoint shootVector =
    ccpSub(cannonHeadWorld, shipPosition);
    float cannonAngle = -1 * ccpToAngle(shootVector);
    _cannon.rotation = CC_RADIANS_TO_DEGREES(cannonAngle);
    
}

- (void)randomAction {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int randomAction = arc4random() % 5;
    
    CCFiniteTimeAction *action;
    if (randomAction == 0 || !_initialMove) {
        
        _initialMove = YES;
        
        float randWidth = winSize.width *
        randomValueBetween(0.6, 1.0);
        float randHeight = winSize.height *
        randomValueBetween(0.1, 0.9);
        CGPoint randDest = ccp(randWidth, randHeight);
        
        float randVel =
        randomValueBetween(winSize.height/4,
                           winSize.height/2);
        float randLength =
        ccpLength(ccpSub(self.position, randDest));
        float randDuration = randLength / randVel;
        randDuration = MAX(randDuration, 0.2);
        
        action = [CCMoveTo actionWithDuration:randDuration
                                     position:ccp(randWidth, randHeight)];
        
    } else if (randomAction == 1) {
        
        action = [CCDelayTime actionWithDuration:0.2];
        
    } else if (randomAction >= 2 && randomAction < 4) {
        
        [_layer shootEnemyLaserFromPosition:
         [self convertToWorldSpace:
          _shooter1.position]];
        [_layer shootEnemyLaserFromPosition:
         [self convertToWorldSpace:
          _shooter2.position]];
        
        action = [CCDelayTime actionWithDuration:0.2];
        
    } else if (randomAction == 4) {
        
        CGPoint cannonHeadWorld =
        [self convertToWorldSpace:
         ccp(_cannon.position.x -
             _cannon.contentSize.width/2,
             _cannon.position.y)];
        [_layer shootCannonBallAtShipFromPosition:
         cannonHeadWorld];
        
        action = [CCDelayTime actionWithDuration:0.2];
        
    }
    
    [self runAction:
     [CCSequence actions:
      action,
      [CCCallFunc actionWithTarget:self
                          selector:@selector(randomAction)],
      nil]];
    
}

- (void)revive {
    [super revive];
    _initialMove = NO;
    [self randomAction];
}

@end
