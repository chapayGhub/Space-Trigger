//
//  ActionLayer.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/22/12.
//  Copyright 2012 Razeware LLC. All rights reserved.
//

#import "ActionLayer.h"
#import "SimpleAudioEngine.h"
#import "Common.h"
#import "SpriteArray.h"
#import "CCParallaxNode-Extras.h"

@implementation ActionLayer {
    CCLabelBMFont * _titleLabel1;
    CCLabelBMFont * _titleLabel2;
    CCMenuItemLabel * _playItem;
    CCSpriteBatchNode * _batchNode;
    CCSprite * _ship;
    float _shipPointsPerSecY;
    double _nextAsteroidSpawn;
    SpriteArray * _asteroidsArray;
    SpriteArray * _laserArray;
    CCParallaxNode * _backgroundNode;
    CCSprite * _spacedust1;
    CCSprite * _spacedust2;
    CCSprite * _planetsunrise;
    CCSprite * _galaxy;
    CCSprite * _spacialanomaly;
    CCSprite * _spacialanomaly2;
}

+ (id)scene {
    
    CCScene *scene = [CCScene node];
    ActionLayer *layer = [ActionLayer node];
    [scene addChild:layer];
    return scene;
    
}

- (void)removeNode:(CCNode *)sender {
    [sender removeFromParent];
}

- (void)invisNode:(CCNode *)sender {
    sender.visible = FALSE;
}

- (void)spawnShip {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _ship = [CCSprite spriteWithSpriteFrameName:@"SpaceFlier_sm_1.png"];
    _ship.position = ccp(-_ship.contentSize.width/2,
                         winSize.height * 0.5);
    [_batchNode addChild:_ship z:1];
    
    [_ship runAction:
     [CCSequence actions:
      [CCEaseOut actionWithAction:
       [CCMoveBy actionWithDuration:0.5
                           position:ccp(_ship.contentSize.width/2 + winSize.width*0.3, 0)]
                             rate:4.0],
      [CCEaseInOut actionWithAction:
       [CCMoveBy actionWithDuration:0.5
                           position:ccp(-winSize.width*0.2, 0)]
                               rate:4.0],
      nil]];
    
    CCSpriteFrameCache * cache =
    [CCSpriteFrameCache sharedSpriteFrameCache];

    CCAnimation *animation = [CCAnimation animation];
    [animation addSpriteFrame:
     [cache spriteFrameByName:@"SpaceFlier_sm_1.png"]];
    [animation addSpriteFrame:
     [cache spriteFrameByName:@"SpaceFlier_sm_2.png"]];
    animation.delayPerUnit = 0.2;

    [_ship runAction:
     [CCRepeatForever actionWithAction:
      [CCAnimate actionWithAnimation:animation]]];
    
}

- (void)playTapped:(id)sender {
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.caf"];
    
    NSArray * nodes = @[_titleLabel1, _titleLabel2, _playItem];
    for (CCNode *node in nodes) {
        [node runAction:
         [CCSequence actions:
          [CCEaseOut actionWithAction:
           [CCScaleTo actionWithDuration:0.5 scale:0] rate:4.0],
          [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
          nil]];
    }
    
    [self spawnShip];
    
}

- (void)setupTitle {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    NSLog(@"Window size (in points): %@", NSStringFromCGSize(winSize));
    
    NSString *fontName = @"SpaceGameFont.fnt";
    
    _titleLabel1 = [CCLabelBMFont labelWithString:@"Space Game" fntFile:fontName];
    _titleLabel1.scale = 0;
    _titleLabel1.position = ccp(winSize.width/2, winSize.height * 0.8);
    [self addChild:_titleLabel1 z:100];
    [_titleLabel1 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:1.0],
      [CCCallBlock actionWithBlock:^{
         [[SimpleAudioEngine sharedEngine] playEffect:@"title.caf"];
     }],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:1.0 scale:0.5] rate:4.0],
      nil]];
    
    _titleLabel2 = [CCLabelBMFont labelWithString:@"Starter Kit" fntFile:fontName];
    _titleLabel2.scale = 0;
    _titleLabel2.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:_titleLabel2 z:100];
    [_titleLabel2 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:1.0 scale:1.25] rate:4.0],
      nil]];
    
    CCLabelBMFont *playLabel = [CCLabelBMFont labelWithString:@"Play" fntFile:fontName];
    _playItem = [CCMenuItemLabel itemWithLabel:playLabel target:self selector:@selector(playTapped:)];
    _playItem.scale = 0;
    _playItem.position = ccp(winSize.width/2, winSize.height * 0.3);

    CCMenu *menu = [CCMenu menuWithItems:_playItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];

    [_playItem runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:0.5] rate:4.0],
      nil]];
    
}

- (void)setupSound {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"SpaceGame.caf" loop:YES];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"explosion_large.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"explosion_small.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"laser_enemy.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"laser_ship.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"shake.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"powerup.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"boss.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"cannon.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"title.caf"];
}

- (void)setupStars {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    NSArray *starsArray = @[@"Stars1.plist", @"Stars2.plist", @"Stars3.plist"];
    for(NSString *stars in starsArray) {
        CCParticleSystemQuad *starsEffect = [CCParticleSystemQuad particleWithFile:stars];
        starsEffect.position = ccp(winSize.width*1.5, winSize.height/2);
        starsEffect.posVar = ccp(starsEffect.posVar.x, (winSize.height/2) * 1.5);
        [self addChild:starsEffect];
    }
}

- (void)setupBatchNode {
    _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites.pvr.ccz"];
    [self addChild:_batchNode z:-1];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Sprites.plist"];
}

- (void)setupArrays {
    _asteroidsArray = [[SpriteArray alloc] initWithCapacity:30
                                            spriteFrameName:@"asteroid.png" batchNode:_batchNode];
    _laserArray = [[SpriteArray alloc] initWithCapacity:15
                                        spriteFrameName:@"laserbeam_blue.png" batchNode:_batchNode];    
}

- (void)setupBackground {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // 1) Create the CCParallaxNode
    _backgroundNode = [CCParallaxNode node];
    [self addChild:_backgroundNode z:-2];
    
    // 2) Create the sprites you’ll add to the
    // CCParallaxNode
    _spacedust1 = [CCSprite spriteWithFile:@"bg_front_spacedust.png"];
    _spacedust2 = [CCSprite spriteWithFile:@"bg_front_spacedust.png"];
    _planetsunrise = [CCSprite spriteWithFile:@"bg_planetsunrise.png"];
    _galaxy = [CCSprite spriteWithFile:@"bg_galaxy.png"];
    _spacialanomaly = [CCSprite spriteWithFile:@"bg_spacialanomaly.png"];
    _spacialanomaly2 = [CCSprite spriteWithFile:@"bg_spacialanomaly2.png"];
    
    // 3) Determine relative movement speeds for space dust
    // and background
    CGPoint dustSpeed = ccp(0.1, 0.1);
    CGPoint bgSpeed = ccp(0.05, 0.05);
    
    // 4) Add children to CCParallaxNode
    [_backgroundNode addChild:_spacedust1 z:0
                parallaxRatio:dustSpeed
               positionOffset:ccp(0,winSize.height/2)];
    [_backgroundNode addChild:_spacedust2 z:0
                parallaxRatio:dustSpeed
               positionOffset:ccp(_spacedust1.contentSize.width*
                                  _spacedust1.scale, winSize.height/2)];
    [_backgroundNode addChild:_galaxy z:-1
                parallaxRatio:bgSpeed
               positionOffset:ccp(0,winSize.height * 0.7)];
    [_backgroundNode addChild:_planetsunrise z:-1
                parallaxRatio:bgSpeed
               positionOffset:ccp(600,winSize.height * 0)];
    [_backgroundNode addChild:_spacialanomaly z:-1
                parallaxRatio:bgSpeed
               positionOffset:ccp(900,winSize.height * 0.3)];        
    [_backgroundNode addChild:_spacialanomaly2 z:-1 
                parallaxRatio:bgSpeed 
               positionOffset:ccp(1500,winSize.height * 0.9)];
}

- (id)init {
    if ((self = [super init])) {
        [self setupSound];
        [self setupTitle];
        [self setupStars];
        [self setupBatchNode];
        self.accelerometerEnabled = YES;
        [self scheduleUpdate];
        [self setupArrays];
        self.touchEnabled = YES;
        [self setupBackground];
    }
    return self;
}

- (void)updateShipPos:(ccTime)dt {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float maxY = winSize.height - _ship.contentSize.height/2;
    float minY = _ship.contentSize.height/2;
    
    float newY = _ship.position.y + (_shipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    _ship.position = ccp(_ship.position.x, newY);
    
}

- (void)updateAsteroids:(ccTime)dt {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    // Is it time to spawn an asteroid?
    double curTime = CACurrentMediaTime();
    if (curTime > _nextAsteroidSpawn) {
        
        // Figure out the next time to spawn an asteroid
        float randSecs = randomValueBetween(0.20, 1.0);
        _nextAsteroidSpawn = randSecs + curTime;
        
        // Figure out a random Y value to spawn at
        float randY = randomValueBetween(0.0,
                                         winSize.height);
        
        // Figure out a random amount of time to move
        // from right to left
        float randDuration = randomValueBetween(2.0, 10.0);
        
        // Create a new asteroid sprite
        CCSprite *asteroid = [_asteroidsArray nextSprite];
        [asteroid stopAllActions];
        asteroid.visible = YES;
        
        // Set its position to be offscreen to the right
        asteroid.position = ccp(winSize.width+asteroid.contentSize.width/2, randY);
        
        // Set it's size to be one of 3 random sizes
        int randNum = arc4random() % 3;
        if (randNum == 0) {
            asteroid.scale = 0.25;
        } else if (randNum == 1) {
            asteroid.scale = 0.5;
        } else {
            asteroid.scale = 1.0;
        }
        
        // Move it offscreen to the left, and when it's
        // done call removeNode
        [asteroid runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-asteroid.contentSize.width, 0)],
          [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
          nil]];
    }
}

- (void)updateCollisions:(ccTime)dt {
    
    for (CCSprite *laser in _laserArray.array) {
        if (!laser.visible) continue;
        
        for (CCSprite *asteroid in _asteroidsArray.array) {
            if (!asteroid.visible) continue;
            
            if (CGRectIntersectsRect(asteroid.boundingBox, laser.boundingBox)) {
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf" pitch:1.0f pan:0.0f gain:0.25f];
                asteroid.visible = NO;
                laser.visible = NO;
                break;
            }
        }
    }
    
}

- (void)updateBackground:(ccTime)dt {
    CGPoint backgroundScrollVel = ccp(-1000, 0);
    _backgroundNode.position =
    ccpAdd(_backgroundNode.position,
           ccpMult(backgroundScrollVel, dt));
    
}

- (void)visit {

    [super visit];
    
    NSArray *spaceDusts = @[_spacedust1, _spacedust2];
    for (CCSprite *spaceDust in spaceDusts) {
        if ([_backgroundNode
             convertToWorldSpace:spaceDust.position].x < -
            spaceDust.contentSize.width/2*self.scale) {
            [_backgroundNode
             incrementOffset:ccp(2*spaceDust.contentSize.width*
                                 spaceDust.scale,0)
             forChild:spaceDust];
        }
    }
    
    NSArray *backgrounds = @[_planetsunrise, _galaxy, _spacialanomaly, _spacialanomaly2];
    for (CCSprite *background in backgrounds) {
        if ([_backgroundNode
             convertToWorldSpace:background.position].x < -
            background.contentSize.width/2*self.scale) {
            [_backgroundNode incrementOffset:ccp(2000,0)
                                    forChild:background];
        }
    }
    
}


- (void)update:(ccTime)dt {
    [self updateShipPos:dt];
    [self updateAsteroids:dt];
    [self updateCollisions:dt];
    [self updateBackground:dt];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_ship == nil) return;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    [[SimpleAudioEngine sharedEngine]
     playEffect:@"laser_ship.caf" pitch:1.0f pan:0.0f
     gain:0.25f];
    
    CCSprite *shipLaser = [_laserArray nextSprite];
    [shipLaser stopAllActions];
    shipLaser.visible = YES;
    
    shipLaser.position = ccpAdd(_ship.position,
                                ccp(shipLaser.contentSize.width/2, 0));
    [shipLaser runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:0.5
                          position:ccp(winSize.width, 0)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
    
}


- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration {
    
#define kFilteringFactor 0.75
    static UIAccelerationValue rollingX = 0, rollingY = 0, rollingZ = 0;
    
    rollingX = (acceleration.x * kFilteringFactor) +
    (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor) +
    (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) +
    (rollingZ * (1.0 - kFilteringFactor));
    
    float accelX = rollingX;
    float accelY = rollingY;
    float accelZ = rollingZ;
    
    //NSLog(@"accelX: %f, accelY: %f, accelZ: %f",
    //      accelX, accelY, accelZ);
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
#define kRestAccelX 0.6
#define kShipMaxPointsPerSec (winSize.height*0.5)
#define kMaxDiffX 0.2
    
    float accelDiffX = kRestAccelX - ABS(accelX);
    float accelFractionX = accelDiffX / kMaxDiffX;
    float pointsPerSecX = kShipMaxPointsPerSec * accelFractionX;
    
    _shipPointsPerSecY = pointsPerSecX;

}

@end
