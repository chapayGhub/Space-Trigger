//
//  BossShip.m
//  SpaceBlaster2
//
//  Created by JRamos on 2/23/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "BossShip.h"
#import "ActionLayer.h"

@implementation BossShip
{
    
    //Variables to keep a reference to the ActionLayer, and one to keep
    //track of whether it’s made it’s initial move yet or not
    ActionLayer * _layer;
    BOOL _initialMove;
    
    //boss weapons
    CCSprite * _shooter1;
    CCSprite * _shooter2;
    CCSprite * _cannon;
    
}

- (id)initWithWorld:(b2World*)world layer:(ActionLayer*)layer {
    
    if ((self = [super initWithSpriteFrameName:@"Big_turret.png" world:world
                                     shapeName:@"Boss_ship" maxHp:50 healthBarType:HealthBarTypeRed])) {
        _layer = layer;
        
        //initialize weapons
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
    
    /*******************************************************************************
     This code is going to make sure that the cannon always points at the ship.
     
     •  The first line figures out where the left side of the cannon is(where the
     big hole is that cannon balls come out of. The position of a sprite is its
     center—so it subtracts half the width of the x axis to get the left hand side.
     It also needs to convert the coordinate to world space.
     •  The second line figures out the vector between where the cannon is and where
     the ship is by simply subtracting the two.
     •  The third line figures out the angle to point the cannon. There’s a helper
     method to figure out the angle of a vector that you use here (ccpToAngle).
     However, it reverses this angle to get the cannon to point toward the ship
     (rather than away).
     •  The final line converts the rotation from radians to what Cocos2D needs
     (degrees!)
     
     *******************************************************************************/
    CGPoint cannonHeadWorld =
    [self convertToWorldSpace:
     ccp(_cannon.position.x - _cannon.contentSize.width/2,
         _cannon.position.y)];
    CGPoint shootVector =
    ccpSub(cannonHeadWorld, shipPosition);
    float cannonAngle = -1 * ccpToAngle(shootVector);
    _cannon.rotation = CC_RADIANS_TO_DEGREES(cannonAngle);
    
}

/*******************************************************************************
 * @method      randomAction
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This code:
 •	Picks a random number, and based on the random number, will create a different
 type of CCAction to run. At the end of the method, it runs this action, and
 then call randomAction again to run another one.
 •	To figure out a random spot to move the boss, it figure out a random
 x-coordinate between 0.6-1.0 times the screen width, and 0.1 -0.9 times the
 screen height. That way the boss will never collide with the ship, but will
 move around in a random pattern.
 •	CCMoveTo doesn't pass a movement rate, it passes a duration. So to figure out
 the duration, it figures out how far the ship will be moving by subtracting
 the destination from the current position. The helper function figures out
 the length based on this vector (ccpLength). It then divides it by a rate
 (in points per second) to get seconds to move. For the rate, it gets a random
 value between 0.25-0.5 the width of the screen per second.
 •	In order to get the guns to shoot properly, we can’t use the shooter’s
 positions as is, because since they are children of the boss, their positions
 are relative to the boss. So we use the convertToWorldSpace method to conver
 the shooter’s positons to the world coordinates. convertToWorldSpace is
 called on the parent, passing in the child coordinate to convert. In this
 case the parent is the boss ship (self) and the children are the shooters.
 *******************************************************************************/
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
        
    }
    //This figures out where the cannon’s opening is, and tells the
    //layer to shoot a cannon ball at the ship from that position.
    else if (randomAction == 4) {
        
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
     [CCSequence actions:action,
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
