//
//  ActionLayer.h
//  SpaceBlaster
//
//  Created by JRamos on 2/22/13.
//  Copyright 2013 JRamos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "HUDLayer.h"

@interface ActionLayer : CCLayer {
    HUDLayer * _hud;
    CCLabelBMFont *label_;
    
    CCSprite *arrowsBar_;
    CCSprite *arrows_;
    
    CCMenuItemFont *lastSentenceItem_, *lastAlignmentItem_;
    
    BOOL drag_;
}

+ (id)scene;

- (void)beginContact:(b2Contact *)contact;
- (void)endContact:(b2Contact *)contact;

- (void)shootEnemyLaserFromPosition:(CGPoint)position;
- (void)shootEnemyVerticalDownLaserFromPosition:(CGPoint)position;
- (void)shootEnemyVerticalUpLaserFromPosition:(CGPoint)position;


- (void)shootCannonBallAtShipFromPosition:(CGPoint)position;
- (void)setupBackground;

//We’re importing the new layer here, and creating an instance variable so we can
//keep a reference to it. We’re also modifying our initializer to take the HUDLayer as a parameter.
- (id)initWithHUD:(HUDLayer *)hud;
@end
