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
#import "Box2D.h"
#import "GLES-Render.h"
#import "GameObject.h"
#import "ShapeCache.h"
#import "SimpleContactListener.h"
#import "ParticleSystemArray.h"
#import "LevelManager.h"
#import "BossShip.h"

#define kCategoryShip       0x1
#define kCategoryShipLaser  0x2
#define kCategoryEnemy      0x4
#define kCategoryPowerup    0x8

enum GameStage {
    GameStageTitle = 0,
    GameStageAsteroids,
    GameStageDone
};

@implementation ActionLayer {
    CCLabelBMFont * _titleLabel1;
    CCLabelBMFont * _titleLabel2;
    CCMenuItemLabel * _playItem;
    CCSpriteBatchNode * _batchNode;
    GameObject * _ship;
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
    b2World * _world;
    GLESDebugDraw * _debugDraw;
    b2ContactListener * _contactListener;
    ParticleSystemArray * _explosions;
    GameStage _gameStage;
    BOOL _gameOver;
    //double _gameWonTime;
    LevelManager * _levelManager;
    CCLabelBMFont *_levelIntroLabel1;
    CCLabelBMFont *_levelIntroLabel2;
    SpriteArray * _alienArray;
    double _nextAlienSpawn;
    double _numAlienSpawns;
    CGPoint _alienSpawnStart;
    ccBezierConfig _bezierConfig;
    double _nextShootChance;
    SpriteArray * _enemyLasers;
    SpriteArray * _powerups;
    double _nextPowerupSpawn;
    BOOL _invincible;
    ParticleSystemArray * _boostEffects;
    BossShip * _boss;
    BOOL _wantNextStage;
    SpriteArray * _cannonBalls;
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

- (void)invisNode:(GameObject *)sender {
    [sender destroy];
}

- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    CCScene *scene = [ActionLayer scene];
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionZoomFlipX transitionWithDuration:0.5
                                             scene:scene]];
    
}

- (void)endScene:(BOOL)win {
    
    if (_gameOver) return;
    _gameOver = TRUE;
    //_gameStage = GameStageDone;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    if (win) {
        message = @"You win!";
    } else {
        message = @"You lose!";
    }
    
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:message fntFile:@"SpaceGameFont.fnt"];
    label.scale = 0.1;
    label.position = ccp(winSize.width/2,
                         winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"SpaceGameFont.fnt"];
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel
                                    itemWithLabel:restartLabel target:self
                                    selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2,
                               winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [restartItem runAction:[CCScaleTo
                            actionWithDuration:0.5 scale:0.5]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 
                                             scale:0.5]];
    
}

- (void)spawnShip {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _ship = [[GameObject alloc] initWithSpriteFrameName:@"SpaceFlier_sm_1.png" world:_world shapeName:@"SpaceFlier_sm_1" maxHp:10 healthBarType:HealthBarTypeGreen];
    _ship.position = ccp(-_ship.contentSize.width/2,
                         winSize.height * 0.5);
    [_ship revive];
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
    //_gameStage = GameStageAsteroids;
    [_levelManager nextStage];
    [self newStageStarted];
    
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
    _asteroidsArray = [[SpriteArray alloc] initWithCapacity:30 spriteFrameName:@"asteroid.png" batchNode:_batchNode world:_world shapeName:@"asteroid" maxHp:1 healthBarType:HealthBarTypeNone];
    _laserArray = [[SpriteArray alloc] initWithCapacity:15 spriteFrameName:@"laserbeam_blue.png" batchNode:_batchNode world:_world shapeName:@"laserbeam_blue" maxHp:1 healthBarType:HealthBarTypeNone];
    _explosions = [[ParticleSystemArray alloc] initWithFile:@"Explosion.plist" capacity:3 parent:self];
    _alienArray = [[SpriteArray alloc] initWithCapacity:15 spriteFrameName:@"enemy_spaceship.png" batchNode:_batchNode world:_world shapeName:@"enemy_spaceship" maxHp:1 healthBarType:HealthBarTypeNone];
    _enemyLasers = [[SpriteArray alloc] initWithCapacity:15 spriteFrameName:@"laserbeam_red.png" batchNode:_batchNode world:_world shapeName:@"laserbeam_red" maxHp:1 healthBarType:HealthBarTypeNone];
    _powerups = [[SpriteArray alloc] initWithCapacity:1 spriteFrameName:@"powerup.png" batchNode:_batchNode world:_world shapeName:@"powerup" maxHp:1 healthBarType:HealthBarTypeNone];
    _boostEffects = [[ParticleSystemArray alloc] initWithFile:@"Boost.plist" capacity:1 parent:self];
    _cannonBalls = [[SpriteArray alloc] initWithCapacity:5 spriteFrameName:@"Boss_cannon_ball.png" batchNode:_batchNode world:_world shapeName:@"Boss_cannon_ball" maxHp:1 healthBarType:HealthBarTypeNone];
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

- (void)setupDebugDraw {
    _debugDraw = new GLESDebugDraw(PTM_RATIO);
    _world->SetDebugDraw(_debugDraw);
    _debugDraw->SetFlags(b2Draw::e_shapeBit | b2Draw::e_jointBit);
}

- (void)setupWorld {
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    _world = new b2World(gravity);
    _contactListener = new SimpleContactListener(self);
    _world->SetContactListener(_contactListener);
}

- (void)testBox2D {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(winSize.width/2/PTM_RATIO,
                              winSize.height/2/PTM_RATIO);
    b2Body *body = _world->CreateBody(&bodyDef);
    
    b2CircleShape circleShape;
    circleShape.m_radius = 0.25;
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleShape;
    fixtureDef.density = 1.0;
    body->CreateFixture(&fixtureDef);
    
    body->ApplyAngularImpulse(0.01);
    
}

- (void)setupShapeCache {
    [[ShapeCache sharedShapeCache] addShapesWithFile:@"Shapes.plist"];
}

- (void)setupLevelManager {
    _levelManager = [[LevelManager alloc] init];
}

- (void)setupBoss {
    _boss = [[BossShip alloc] initWithWorld:_world layer:self];
    _boss.visible = NO;
    [_batchNode addChild:_boss];
}

- (id)init {
    if ((self = [super init])) {
        
        [self setupWorld];
        [self setupDebugDraw];
        //[self testBox2D];
        [self setupShapeCache];
        
        [self setupSound];
        [self setupTitle];
        [self setupStars];
        [self setupBatchNode];
        self.accelerometerEnabled = YES;
        [self scheduleUpdate];
        [self setupArrays];
        self.touchEnabled = YES;
        [self setupBackground];
        
        //double curTime = CACurrentMediaTime();
        //_gameWonTime = curTime + 30.0;
        [self setupLevelManager];
        [self setupBoss];

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

    //if (_gameStage != GameStageAsteroids) return;
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnAsteroids"]) return;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    // Is it time to spawn an asteroid?
    double curTime = CACurrentMediaTime();
    if (curTime > _nextAsteroidSpawn) {
        
        float spawnSecsLow = [_levelManager floatForProp:@"ASpawnSecsLow"];
        float spawnSecsHigh = [_levelManager floatForProp:@"ASpawnSecsHigh"];
        float randSecs = randomValueBetween(spawnSecsLow, spawnSecsHigh);
        _nextAsteroidSpawn = randSecs + curTime;

        float randY = randomValueBetween(0.0, winSize.height);

        float moveDurationLow = [_levelManager floatForProp:@"AMoveDurationLow"];
        float moveDurationHigh = [_levelManager floatForProp:@"AMoveDurationHigh"];
        float randDuration = randomValueBetween(moveDurationLow, moveDurationHigh);
        
        // Create a new asteroid sprite
        GameObject *asteroid = [_asteroidsArray nextSprite];
        [asteroid stopAllActions];
        asteroid.visible = YES;
        
        // Set its position to be offscreen to the right
        asteroid.position = ccp(winSize.width+asteroid.contentSize.width/2, randY);
        
        // Set it's size to be one of 3 random sizes
        int randNum = arc4random() % 3;
        if (randNum == 0) {
            asteroid.scale = 0.25;
            asteroid.maxHp = 2;
        } else if (randNum == 1) {
            asteroid.scale = 0.5;
            asteroid.maxHp = 4;
        } else {
            asteroid.scale = 1.0;
            asteroid.maxHp = 6;
        }
        [asteroid revive];
        
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

- (void)updateBox2D:(ccTime)dt {
    _world->Step(dt, 1, 1);
    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            GameObject *sprite =
            (__bridge GameObject *)b->GetUserData();
            
            b2Vec2 b2Position =
            b2Vec2(sprite.position.x/PTM_RATIO,
                   sprite.position.y/PTM_RATIO);
            float32 b2Angle =
            -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
            
            b->SetTransform(b2Position, b2Angle);
        }
    }
    
}


- (void)updateLevel:(ccTime)dt {
    BOOL newStage = [_levelManager update];
    if (newStage) {
        [self newStageStarted];
    }
    if (_wantNextStage) {
        _wantNextStage = NO;
        [_levelManager nextStage];
        [self newStageStarted];
    }
}

- (void)doLevelIntro {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message1 = [NSString stringWithFormat:@"Level %d",
     _levelManager.curLevelIdx+1];
    NSString *message2 = [_levelManager stringForProp:@"LText"];
    
    _levelIntroLabel1 = [CCLabelBMFont labelWithString:message1 fntFile:@"SpaceGameFont.fnt"];
    _levelIntroLabel1.scale = 0;
    _levelIntroLabel1.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:_levelIntroLabel1 z:100];
    
    [_levelIntroLabel1 runAction:
     [CCSequence actions:
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:0.5] rate:4.0],
      [CCDelayTime actionWithDuration:3.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:0] rate:4.0],
      [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
      nil]];
    
    _levelIntroLabel2 = [CCLabelBMFont labelWithString:message2 fntFile:@"SpaceGameFont.fnt"];
    _levelIntroLabel2.position = ccp(winSize.width/2, winSize.height * 0.4);
    _levelIntroLabel2.scale = 0;
    [self addChild:_levelIntroLabel2 z:100];
    
    [_levelIntroLabel2 runAction:
     [CCSequence actions:
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:0.5] rate:4.0],
      [CCDelayTime actionWithDuration:3.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:0] rate:4.0],
      [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
      nil]];
    
}

- (void)spawnBoss {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _boss.position = ccp(winSize.width*1.2,
                         winSize.height*1.2);
    
    [_boss revive];
    
    [self shakeScreen:30];
    [[SimpleAudioEngine sharedEngine]
     playEffect:@"boss.caf"];
    
}

- (void)newStageStarted {
    if (_levelManager.gameState == GameStateDone) {
        [self endScene:YES];
    } else if ([_levelManager boolForProp:@"SpawnLevelIntro"]) {
        [self doLevelIntro];
    }
    if ([_levelManager hasProp:@"SpawnBoss"]) {
        [self spawnBoss];
    }
}

- (void)shootEnemyLaserFromPosition:(CGPoint)position {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *shipLaser = [_enemyLasers nextSprite];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"laser_enemy.caf" pitch:1.0f pan:0.0f gain:0.25f];
    shipLaser.position = position;
    [shipLaser revive];
    [shipLaser stopAllActions];
    [shipLaser runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2.0
                          position:ccp(-winSize.width, 0)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
}

- (void)shootCannonBallAtShipFromPosition:(CGPoint)position {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *cannonBall = [_cannonBalls nextSprite];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"cannon.caf" pitch:1.0f pan:0.0f gain:0.25f];
    
    CGPoint shootVector =
    ccpNormalize(ccpSub(_ship.position, position));
    CGPoint shootTarget = ccpMult(shootVector,
                                  winSize.width*2);
    
    cannonBall.position = position;
    [cannonBall revive];
    [cannonBall runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:5.0 position:shootTarget],
      [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
      nil]];
}

- (void)updateAlienSwarm:(ccTime)dt {
    
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager hasProp:@"SpawnAlienSwarm"])
        return;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    double curTime = CACurrentMediaTime();
    if (curTime > _nextAlienSpawn) {
        
        if (_numAlienSpawns == 0) {
            CGPoint pos1 = ccp(winSize.width*1.3,
                               randomValueBetween(0, winSize.height*0.1));
            CGPoint cp1 =
            ccp(randomValueBetween(winSize.width*0.1,
                                   winSize.width*0.6),
                randomValueBetween(0, winSize.height*0.3));
            CGPoint pos2 = ccp(winSize.width*1.3,
                               randomValueBetween(winSize.height*0.9,
                                                  winSize.height*1.0));
            CGPoint cp2 =
            ccp(randomValueBetween(winSize.width*0.1,
                                   winSize.width*0.6),
                randomValueBetween(winSize.height*0.7,
                                   winSize.height*1.0));
            _numAlienSpawns = arc4random() % 20 + 1;
            if (arc4random() % 2 == 0) {
                _alienSpawnStart = pos1;
                _bezierConfig.controlPoint_1 = cp1;
                _bezierConfig.controlPoint_2 = cp2;
                _bezierConfig.endPosition = pos2;
            } else {
                _alienSpawnStart = pos2;
                _bezierConfig.controlPoint_1 = cp2;
                _bezierConfig.controlPoint_2 = cp1;
                _bezierConfig.endPosition = pos1;
            }
            
            _nextAlienSpawn = curTime + 1.0;
            
        } else {
            
            _nextAlienSpawn = curTime + 0.3;
            
            _numAlienSpawns -= 1;
            
            GameObject *alien = [_alienArray nextSprite];
            alien.position = _alienSpawnStart;
            [alien revive];
            
            [alien runAction:
             [CCBezierTo actionWithDuration:3.0
                                     bezier:_bezierConfig]];
        }
    }
    
    if (curTime > _nextShootChance) {
        _nextShootChance = curTime + 0.1;
        
        for (GameObject *alien in _alienArray.array) {
            if (alien.visible) {
                if (arc4random() % 40 == 0) {
                    [self shootEnemyLaserFromPosition:
                     alien.position];
                }
            }
        }        
    }
}

- (void)updatePowerups:(ccTime)dt {
    
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnPowerups"])
        return;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    double curTime = CACurrentMediaTime();
    if (curTime > _nextPowerupSpawn) {
        _nextPowerupSpawn = curTime +
        [_levelManager floatForProp:@"PSpawnSecs"];
        
        GameObject * powerup = [_powerups nextSprite];
        powerup.position = ccp(winSize.width,
                               randomValueBetween(0, winSize.height));
        [powerup revive];
        [powerup runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:5.0
                              position:ccp(-winSize.width*1.5, 0)],
          [CCCallFuncN actionWithTarget:self
                               selector:@selector(invisNode:)],
          nil]];            
    }
    
}

- (void)updateBoostEffects:(ccTime)dt {
    for (CCParticleSystemQuad * particleSystem in _boostEffects.array) {
        particleSystem.position = _ship.position;
    }
}

- (void)updateBoss:(ccTime)dt {
    
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnBoss"]) return;
    
    if (_boss.visible) {
        [_boss updateWithShipPosition:_ship.position];
    }
}

- (void)update:(ccTime)dt {
    [self updateShipPos:dt];
    [self updateAsteroids:dt];
    //[self updateCollisions:dt];
    [self updateBackground:dt];
    [self updateBox2D:dt];

    //if (CACurrentMediaTime() > _gameWonTime) {
    //    [self endScene:YES];
    //}
    [self updateLevel:dt];
    [self updateAlienSwarm:dt];
    [self updatePowerups:dt];
    [self updateBoostEffects:dt];
    [self updateBoss:dt];
}

- (void)beginContact:(b2Contact *)contact {
    
    b2Fixture *fixtureA = contact->GetFixtureA();
    b2Fixture *fixtureB = contact->GetFixtureB();
    b2Body *bodyA = fixtureA->GetBody();
    b2Body *bodyB = fixtureB->GetBody();
    GameObject *spriteA = (__bridge GameObject *) bodyA->GetUserData();
    GameObject *spriteB = (__bridge GameObject *) bodyB->GetUserData();
    
    if (!spriteA.visible || !spriteB.visible) return;
    
    b2WorldManifold manifold;
    contact->GetWorldManifold(&manifold);
    b2Vec2 b2ContactPoint = manifold.points[0];
    CGPoint contactPoint = ccp(b2ContactPoint.x * PTM_RATIO, b2ContactPoint.y * PTM_RATIO);
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    if ((fixtureA->GetFilterData().categoryBits &
         kCategoryShipLaser &&
         fixtureB->GetFilterData().categoryBits &
         kCategoryEnemy) ||
        (fixtureB->GetFilterData().categoryBits &
         kCategoryShipLaser &&
         fixtureA->GetFilterData().categoryBits &
         kCategoryEnemy))
    {
        
        // Determine enemy ship and laser
        GameObject *enemyShip = (GameObject*) spriteA;
        GameObject *laser = (GameObject *) spriteB;
        if (fixtureB->GetFilterData().categoryBits &
            kCategoryEnemy) {
            enemyShip = (GameObject*) spriteB;
            laser = (GameObject*) spriteA;
        }
        
        // Make sure not already dead
        if (!enemyShip.dead && !laser.dead) {            
            [enemyShip takeHit];
            [laser takeHit];
            if ([enemyShip dead]) {
                
                if (enemyShip == _boss) {
                    _wantNextStage = YES;
                }
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf" pitch:1.0f pan:0.0f gain:0.25f];
                CCParticleSystemQuad *explosion = [_explosions nextParticleSystem];
                
                if (enemyShip.maxHp > 3) {
                    [self shakeScreen:6];
                    explosion.scale *= 1.0;
                } else if (enemyShip.maxHp > 1) {
                    [self shakeScreen:3];
                    explosion.scale *= 0.5;
                } else {
                    [self shakeScreen:1];
                    explosion.scale *= 0.25;
                }                
                explosion.position = contactPoint;

                [explosion resetSystem];
            } else {
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_small.caf" pitch:1.0f pan:0.0f gain:0.25f];
                CCParticleSystemQuad *explosion = [_explosions nextParticleSystem];
                explosion.scale *= 0.25;
                explosion.position = contactPoint;
                [explosion resetSystem];
            }
        }
    }
    
    if ((fixtureA->GetFilterData().categoryBits & kCategoryShip && fixtureB->GetFilterData().categoryBits & kCategoryEnemy) ||
        (fixtureB->GetFilterData().categoryBits & kCategoryShip && fixtureA->GetFilterData().categoryBits & kCategoryEnemy)) {
        
        // Determine enemy ship
        GameObject *enemyShip = (GameObject*) spriteA;
        if (fixtureB->GetFilterData().categoryBits & kCategoryEnemy) {
            enemyShip = spriteB;
        }
        
        if (!enemyShip.dead) {
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf" pitch:1.0f pan:0.0f gain:0.25f];
            
            [self shakeScreen:1];
            CCParticleSystemQuad *explosion = [_explosions nextParticleSystem];
            explosion.scale *= 0.5;
            explosion.position = contactPoint;
            [explosion resetSystem];
            
            [enemyShip destroy];
            if (!_invincible) {
                [_ship takeHit];
            }

            if (_ship.dead) {
                 _levelManager.gameState = GameStateDone;
                [self endScene:NO];
            }
            
        }
        
    }
    
    if ((fixtureA->GetFilterData().categoryBits & kCategoryShip && fixtureB->GetFilterData().categoryBits & kCategoryPowerup) ||
        (fixtureB->GetFilterData().categoryBits & kCategoryShip && fixtureA->GetFilterData().categoryBits & kCategoryPowerup)) {
        
        // Determine power up
        GameObject *powerUp = (GameObject*) spriteA;
        if (fixtureB->GetFilterData().categoryBits & kCategoryPowerup) {
            powerUp = spriteB;
        }
        
        if (!powerUp.dead) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.caf" pitch:1.0 pan:0.0 gain:1.0];
            
            [powerUp destroy];
            
            float scaleDuration = 1.0;
            float waitDuration = 5.0;
            _invincible = YES;
            CCParticleSystemQuad *boostEffect = [_boostEffects nextParticleSystem];
            [boostEffect resetSystem];
            
            [_ship runAction:
             [CCSequence actions:
              [CCMoveBy actionWithDuration:scaleDuration position:ccp(winSize.width * 0.6, 0)],
              [CCDelayTime actionWithDuration:waitDuration],
              [CCMoveBy actionWithDuration:scaleDuration position:ccp(-winSize.width * 0.6, 0)],
              nil]];
            
            [self runAction:
             [CCSequence actions:
              [CCScaleTo actionWithDuration:scaleDuration scale:0.75],
              [CCDelayTime actionWithDuration:waitDuration],
              [CCScaleTo actionWithDuration:scaleDuration scale:1.0],
              [CCCallFunc actionWithTarget:self selector:@selector(boostDone)],
              nil]];

        }                
    }

}

- (void)endContact:(b2Contact *)contact {
    
}

- (void)boostDone {
    _invincible = NO;
    for (CCParticleSystemQuad * boostEffect in _boostEffects.array) {
        [boostEffect stopSystem];
    }
}

- (void)shakeScreen:(int)times {
    
    id shakeLow = [CCMoveBy
                   actionWithDuration:0.025 position:ccp(0, -5)];
    id shakeLowBack = [shakeLow reverse];
    id shakeHigh =  [CCMoveBy
                     actionWithDuration:0.025 position:ccp(0, 5)];
    id shakeHighBack = [shakeHigh reverse];
    id shake = [CCSequence actions:shakeLow, shakeLowBack,
                shakeHigh, shakeHighBack, nil];
    CCRepeat* shakeAction = [CCRepeat
                             actionWithAction:shake times:times];
    
    [self runAction:shakeAction];
}

- (void) draw
{
    [super draw];
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    kmGLPushMatrix();
    //_world->DrawDebugData();
    kmGLPopMatrix();
    
    /* if (_levelManager.gameState == GameStateNormal &&
        [_levelManager boolForProp:@"SpawnAlienSwarm"]) {
        
        ccDrawCubicBezier(_alienSpawnStart,
                          _bezierConfig.controlPoint_1,
                          _bezierConfig.controlPoint_2,
                          _bezierConfig.endPosition, 16);
        ccDrawLine(_alienSpawnStart,
                   _bezierConfig.controlPoint_1);
        ccDrawLine(_bezierConfig.endPosition,
                   _bezierConfig.controlPoint_2);
     
    }*/
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_ship == nil || _ship.dead) return;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    [[SimpleAudioEngine sharedEngine]
     playEffect:@"laser_ship.caf" pitch:1.0f pan:0.0f
     gain:0.25f];
    
    GameObject *shipLaser = [_laserArray nextSprite];
    [shipLaser stopAllActions];
    shipLaser.position = ccpAdd(_ship.position, ccp(shipLaser.contentSize.width/2, 0));
    [shipLaser revive];
    
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
