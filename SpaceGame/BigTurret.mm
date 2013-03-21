//
//  BigTurret.m
//  SpaceBlaster2
//
//  Created by JRamos on 2/23/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "BigTurret.h"
#import "ActionLayer.h"
#import <Foundation/Foundation.h>

@implementation BigTurret
{
    
    //Variables to keep a reference to the ActionLayer, and one to keep
    //track of whether it’s made it’s initial move yet or not
    ActionLayer * _layer;
    BOOL _initialMove;
    
    //Turret weapons
    CCSprite * _shooter1;
    CCSprite * _shooter2;
    CCSprite * _cannon;
    
    id _timer;
    
}

- (id)initWithWorld:(b2World*)world layer:(ActionLayer*)layer {
    
    if ((self = [super initWithSpriteFrameName:@"carrier1.png"
                                         world:world
                                     shapeName:@"carrier1"
                                         maxHp:500
                                 healthBarType:HealthBarTypeRed])) {
        
        _layer = layer;
        
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
    
}
- (void)moveTurret {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int randomAction = arc4random() % 5;
    
    CCFiniteTimeAction *action;
    if (randomAction == 0 || !_initialMove) {
        if(_initialMove == NO){
            [self shootTimer];
        }
        _initialMove = YES;
        
        
        float randWidth = winSize.width *
        randomValueBetween(0.3, 1.0);
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
        
        CCSpriteFrameCache * cache =
        [CCSpriteFrameCache sharedSpriteFrameCache];
        
        CCAnimation *animation = [CCAnimation animation];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"carrier1.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"carrier1.png"]];
        animation.delayPerUnit = 0.2;
        
        [self runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];

    
    
    action = [CCMoveTo actionWithDuration:4
                                 position:ccp(winSize.width * .8, randHeight)];
    } else if (randomAction == 1) {
        
        action = [CCDelayTime actionWithDuration:0.1];
        
    } else if (randomAction >= 2 && randomAction < 4) {
        
        action = [CCDelayTime actionWithDuration:0.1];
        
    }
    //This figures out where the cannon’s opening is, and tells the
    //layer to shoot a cannon ball at the ship from that position.
    else if (randomAction == 4) {
        
              action = [CCDelayTime actionWithDuration:0.1];
        
    }
    
    
    [self runAction:
     [CCSequence actions:action,
      [CCCallFunc actionWithTarget:self
                          selector:@selector(moveTurret)],
      nil]];
    
    

    
}

- (void)shootTimer {
    
    CCCallFunc *call = [CCCallFunc actionWithTarget:self selector:@selector(shootLasers)];
    CCDelayTime *delay1 = [CCDelayTime actionWithDuration:1];
    CCDelayTime *delay2 = [CCDelayTime actionWithDuration:4];
    CCDelayTime *delay3 = [CCDelayTime actionWithDuration:.4];
    
    
    //CCSequence *actionToRun = [CCSequence actions:shootFireball, nil];
    CCSequence *actionToRun = [CCSequence actions:call,delay1,call,delay1,call,delay2,call,delay1,call,delay1,call,delay1,call,delay1,call,
                               call,delay3,call,delay3,call,delay2,call,delay3,call,delay3,call,delay3,call,delay3,call,nil];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:actionToRun];
    [self runAction:repeat];
    
}

-(void)shootLasers
{
    CGPoint lasers = ccp(self.position.x - 150, self.position.y);
    CGPoint lasers2 = ccp(self.position.x - 150, self.position.y);
    CGPoint lasers3 = ccp(self.position.x - 50, self.position.y );
    CGPoint lasers4 = ccp(self.position.x - 50, self.position.y );
    
    [_layer shootAngleFromPosition:
     lasers];
    [_layer shootEnemyLaserFromPosition:
     lasers2];
    [_layer shootEnemyVerticalDownLaserFromPosition:
     lasers3];
    [_layer shootEnemyVerticalUpLaserFromPosition:
     lasers4];
}

-(void)turretDead
{
    [self unschedule:@selector(shootLasers)];
}

- (void)revive {
    [super revive];
    _initialMove = NO;
    [self moveTurret];
}

@end
