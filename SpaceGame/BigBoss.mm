//
//  TestScene.m
//  SpaceGame
//
//  Created by JRamos on 3/4/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "BigBoss.h"
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
#import "BigTurret.h"
#import "HighScoreScene.h"
#import "BigBoss.h"

//Constants to make referring to shape categories easier in code.
#define kCategoryShip       0x1
#define kCategoryShipLaser  0x2
#define kCategoryEnemy      0x4
#define kCategoryPowerup    0x8
#define kCategoryPowerupMultiple    0x10


enum GameStage {
    GameStageTitle = 0,
    GameStageEnemys,
    GameStageDone
};


@implementation BigBoss
{
    
    //Variables for loading sprite sheet
    CCSpriteBatchNode * _batchNode;
    GameObject * _ship;
    
    //Variable to keep track of how fast the ship should move up or down
    float _shipPointsPerSecY;
    float _shipPointsPerSecX;
    
    //Variable to keep track of the next enemy should spawn
    double _nextEnemySpawn;
    double _nextEnemyFlyerSpawn;
    
    //Variable for the array of enemys
    SpriteArray * _enemysArray;
    
    //Variable for the array of lasers
    SpriteArray * _laserArray;
    
    //Determines if you are in the act of firing weapons
    BOOL _firing;
    int _timerLasers;
    
    //Parallax scrolling variables
    CCParallaxNode * _backgroundNode;
    CCSprite * _spacedust1;
    CCSprite * _spacedust2;
    CCSprite * _planetsunrise;
    CCSprite * _galaxy;
    CCSprite * _spacialanomaly;
    CCSprite * _spacialanomaly2;
    
    //This declares the variables to keep track of the Box2D world, and the
    //class to perform Box2D debug drawing.
    b2World * _world;
    GLESDebugDraw * _debugDraw;
    
    //Detect collision with Box2d
    b2ContactListener * _contactListener;
    
    //Variable for explosions
    ParticleSystemArray * _explosions;
    
    //Keeps track of the game stage, and one to keep track of whether the
    //game over menu has appeared
    GameStage _gameStage;
    BOOL _gameOver;
    
    //Winning/ Clearing stage
    //double _gameWonTime;
    LevelManager * _levelManager;
    
    //Variables for alien ships
    SpriteArray * _alienArray;
    double _nextAlienSpawn;
    double _numAlienSpawns;
    CGPoint _alienSpawnStart;
    ccBezierConfig _bezierConfig;
    
    //Enemy lasers
    double _nextShootChance;
    SpriteArray * _enemyLasers;
    SpriteArray * _enemyLaserGreen;
    
    //Power-ups
    SpriteArray * _powerupBolt;
    double _nextPowerupBoltSpawn;
    int _powerupSingle;
    SpriteArray * _powerupMultiple;
    double _nextPowerupMultipleSpawn;
    
    
    //Invinsibility/Boost effect
    BOOL _invincible;
    ParticleSystemArray * _boostEffects;
    
    //Boss
    BossShip * _boss;
    BOOL _wantNextStage;
    
    //Big Turret ships
    BigTurret * _bigTurret;
    
    //Boss cannons
    SpriteArray * _cannonBalls;
    
    //Enemy Flyer
    SpriteArray * _enemyFlyerArray;
    GameObject * _enemyFlyer;
    GameObject * _enemyFlyer2;
    GameObject * _enemyFlyer3;
    GameObject * _enemyFlyer4;
    GameObject * _enemyFlyer5;
    GameObject * _enemyFlyer6;
    GameObject * _enemyFlyer7;
    GameObject * _enemyFlyer8;
    
    //Variables for ship weapons
    BOOL _single;
    BOOL _multiple;
    
    //Background stuff
    //CCLabelBMFont requires pre-rendered font images
    CCLabelBMFont * _titleLabel1;
    CCLabelBMFont * _titleLabel2;
    CCLabelBMFont * _titleLabel3;
    CCLabelBMFont *_levelIntroLabel1;
    CCLabelBMFont *_levelIntroLabel2;
    CCSprite *_fighterMain;
    CCSprite *_fighterMain2;
    CCSprite *_lenseFlare;
    CCSprite *_rectangle;
    CCSprite *_rectangle2;
    CCSprite *_rectangle3;
    CCSprite *_rectangle4;
    //Background Images
    CCSprite * _background1;
    //Play button
    CCMenuItemLabel * _playItem;
    //Tutorial button
    CCMenuItemLabel * _tutorialItem;
    //High Scores button
    CCMenuItemLabel * _highScoreItem;
    //Test button
    CCMenuItemLabel * _testItem;
    
    //Keeps track if playing or not
    BOOL _isPlaying;
    BOOL _isPaused;
    
    //Score
    int _score;
    
    CCSprite *_boss1;
    CCSprite *_boss2;
    CCSprite *_boss3;
    
    SpriteArray *_bossTopArmArray;
    SpriteArray *_bossBottomArmArray;
    SpriteArray *_bossArmSideArray;
    SpriteArray *_bossMainArray;
    SpriteArray *_fireballArray;
    
    GameObject *_bossarmtop;
    GameObject *_bossarmbottom;
    GameObject *_bossarmsidetop;
    GameObject *_bossarmsidebottom;
    GameObject *_bossmain;
    
    
    //Boss booleans
    BOOL _topArmDead;
    BOOL _bottomArmDead;
    BOOL _topMiddleArmDead;
    BOOL _bottomMiddleArmDead;
    
    BOOL _stageArms;
    BOOL _stageMiddle;
    BOOL _stageHead;
    
    BOOL _stopLooping;
    

    
}

+ (id)scene {
    CCScene *scene = [CCScene node];
    
    BigBoss *testScene = [BigBoss node];
    [scene addChild:testScene z:1];
    
    
    
    return scene;
}

-(void)setupTitle
{
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    
    //NSString *fontName = @"SpaceGameFont.fnt";
    [self backButton];
    
}

- (void)setupBatchNode {
    _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites.pvr.ccz"];
    [self addChild:_batchNode z:-1];
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     addSpriteFramesWithFile:@"Sprites.plist"];
}


- (void)backButton
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCLabelBMFont *backLabel = [CCLabelBMFont labelWithString:@"<"
                                                      fntFile:@"SpaceGameFont.fnt"];
    CCLabelBMFont *backLabel2 = [CCLabelBMFont labelWithString:@"Back"
                                                       fntFile:@"SpaceGameFont.fnt"];
    
    CCMenuItemLabel *backItem = [CCMenuItemLabel
                                 itemWithLabel:backLabel target:self
                                 selector:@selector(backTapped)];
    
    CCMenuItemLabel *backItem2 = [CCMenuItemLabel
                                  itemWithLabel:backLabel2 target:self
                                  selector:@selector(backTapped)];
    backItem.scale = .6;
    backItem.position = ccp(winSize.width*.1,
                            winSize.height/2);
    
    backItem2.scale = .1;
    backItem2.position = ccp(winSize.width*.1,
                             winSize.height*.45);
    
    CCMenu *menu = [CCMenu menuWithItems:backItem, nil];
    menu.position = CGPointZero;
    CCMenu *menu2 = [CCMenu menuWithItems:backItem2, nil];
    menu2.position = CGPointZero;
    [self addChild:menu z:100];
    [self addChild:menu2 z:100];
    
    [backItem runAction:
     [CCRepeatForever actionWithAction:
      [CCFadeOut actionWithDuration:1]]];
    
}

-(void)backTapped
{
    
    // Reload the current scene
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:2
                                          scene:[ActionLayer scene]]];
    
}

- (void)setupBackground {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _background1 = [CCSprite spriteWithFile:@"background4.png"];
    //bg.scale = 2;
    _background1.position = ccp(winSize.width/2, winSize.height/2);;
    [self addChild:_background1 z:-5];
    
    [_background1 runAction:
     [CCSequence actions:
      [CCScaleTo actionWithDuration:10 scale:0.8],
      nil]];
    
    id a = [CCScaleTo actionWithDuration:10 scale:1];
    id b = [CCScaleTo actionWithDuration:10 scale:1.2];
    id sequence = [CCSequence actions:a, b, nil];
    CCRepeatForever* zoomAction = [CCRepeat actionWithAction:sequence times:-1];
    
    [_background1 runAction:zoomAction];
    

}

-(void)spawnBossIntro
{
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"ff7.mp3" loop:YES];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *boss = [CCSprite spriteWithFile:@"boss.png"];
    boss.scale = .001;
    boss.position = ccp(winSize.width*.1, winSize.height/2);
    
    [self addChild:boss z:-5];
    
    [boss runAction:
     [CCSequence actions:
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:15 scale:.3] rate:.5],
      [CCMoveTo actionWithDuration:1 position:ccp(winSize.width * 2, winSize.height/2)],
      [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
      nil]];
    
    [boss runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:1],
      [CCCallFunc actionWithTarget:self selector:@selector(startMusic)],
      [CCDelayTime actionWithDuration:15],
      [CCScaleTo actionWithDuration:1 scale:1], nil]];
    
    [self schedule:@selector(spawnBoss) interval:15];
    
    
    
}

-(void)startMusic
{
    //for some reason, if the next track is called right after, cocos2d fails
    //to play it. I gave it at least 1 second to buffer.
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"ff7.mp3" loop:YES];
}

-(void)spawnBoss
{
    
    
    [self unschedule:@selector(spawnBoss)];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _bossarmsidetop = [_bossArmSideArray nextSprite];
    [_bossarmsidetop stopAllActions];
    _bossarmsidetop.position = ccp(winSize.width * 1.5, winSize.height*.8);
    _bossarmsidetop.scale = 1;
    [_bossarmsidetop revive];
    
    _bossarmsidebottom = [_bossArmSideArray nextSprite];
    [_bossarmsidebottom stopAllActions];
    _bossarmsidebottom.flipY = 180;
    _bossarmsidebottom.position = ccp(winSize.width * 1.5, winSize.height * .2);
    _bossarmsidebottom.scale = 1;
    [_bossarmsidebottom revive];
    
    _bossarmtop = [_bossBottomArmArray nextSprite];
    [_bossarmtop stopAllActions];
    _bossarmtop.position = ccp(winSize.width * 1.5, winSize.height*.95 );
    _bossarmtop.scale = 1;

    [_bossarmtop revive];
    
    _bossarmbottom = [_bossTopArmArray nextSprite];
    [_bossarmbottom stopAllActions];
    _bossarmbottom.flipY = 180;
    _bossarmbottom.position = ccp(winSize.width * 1.5, winSize.height * .1);
    _bossarmbottom.scale = 1;

    [_bossarmbottom revive];
    
    _bossmain = [_bossMainArray nextSprite];
    [_bossmain stopAllActions];
    _bossmain.position = ccp(winSize.width * 1.5, winSize.height/2);
    _bossmain.scale = 1;

    [_bossmain revive];
    
    [self animateBoss];
    
    [self moveBoss];

}

-(void)animateBoss
{
    CCSpriteFrameCache * cache =
    [CCSpriteFrameCache sharedSpriteFrameCache];
    
    CCAnimation *animation = [CCAnimation animation];
    [animation addSpriteFrame:
     [cache spriteFrameByName:@"bossarmtop.png"]];
    [animation addSpriteFrame:
     [cache spriteFrameByName:@"bossarmtop2.png"]];
    animation.delayPerUnit = 1;
    
    CCAnimation *animation2 = [CCAnimation animation];
    [animation2 addSpriteFrame:
     [cache spriteFrameByName:@"bossarmside2.png"]];
    [animation2 addSpriteFrame:
     [cache spriteFrameByName:@"bossarmside.png"]];
    animation2.delayPerUnit = 1;
    
    CCAnimation *animation3 = [CCAnimation animation];
    [animation3 addSpriteFrame:
     [cache spriteFrameByName:@"bossmain.png"]];
    [animation3 addSpriteFrame:
     [cache spriteFrameByName:@"bossmain2.png"]];
    animation3.delayPerUnit = 1;
    
    [_bossarmtop runAction:
     [CCRepeatForever actionWithAction:
      [CCAnimate actionWithAnimation:animation]]];
    [_bossarmbottom runAction:
     [CCRepeatForever actionWithAction:
      [CCAnimate actionWithAnimation:animation]]];
    
    [_bossarmsidetop runAction:
     [CCRepeatForever actionWithAction:
      [CCAnimate actionWithAnimation:animation2]]];
    [_bossarmsidebottom runAction:
     [CCRepeatForever actionWithAction:
      [CCAnimate actionWithAnimation:animation2]]];
    
    [_bossmain runAction:
     [CCRepeatForever actionWithAction:
      [CCAnimate actionWithAnimation:animation3]]];
}

-(void)hintLabel
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    NSString *fontName = @"SpaceGameFont.fnt";
    CCLabelBMFont *hintLable = [CCLabelBMFont labelWithString:@"DESTROY THE ARMS!" fntFile:fontName];
    hintLable.scale = 0;
    hintLable.position = ccp(winSize.width/2, winSize.height*.75);
    [self addChild:hintLable z:100];
    [hintLable runAction:
     [CCSequence actions:
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:.5 scale:.5] rate:2.0],
      
      nil]];
    [hintLable runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:5],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:.5 scale:0] rate:2.0],
      
      nil]];

}

-(void)moveBoss
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [_bossarmtop runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:5 position:ccp(winSize.width * .7, winSize.height )],
      nil]];
    [_bossarmbottom runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:5 position:ccp(winSize.width * .7, winSize.height * .05)],
      nil]];
    [_bossarmsidetop runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:5 position:ccp(winSize.width, winSize.height*.8)],
      nil]];
    [_bossarmsidebottom runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:5 position:ccp(winSize.width, winSize.height * .2)],
      nil]];
    [_bossmain runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:5 position:ccp(winSize.width*.87, winSize.height/2)],
      nil]];
    
    
    //[self scheduleOnce:@selector(moveUpDownLeftRight) delay:5];
    
    ///*
    [self schedule:@selector(shootBigLaser) interval:.05 repeat:440 delay:5];
    [self schedule:@selector(bigLaserSound) interval:.5 repeat:2 delay:5];
    [self schedule:@selector(enemyShoot) interval:.05 repeat:75 delay:5];
    [self schedule:@selector(laserSound) interval:7 repeat:2 delay:5];
    [self schedule:@selector(enemyShoot2) interval:.05 repeat:75 delay:12];
    [self schedule:@selector(enemyShoot3) interval:.05 repeat:75 delay:19];
    //[self schedule:@selector(enemyShoot4) interval:.05 repeat:75 delay:35];
    [self schedule:@selector(shootCannon) interval:1];
    [self scheduleOnce:@selector(shootTimer) delay:32];
    [self scheduleOnce:@selector(hintLabel) delay:2];
    
     //*/
    
    /*
    [self schedule:@selector(shootCannon) interval:1];
    [self scheduleOnce:@selector(shootTimer) delay:5];
    [self scheduleOnce:@selector(hintLabel) delay:2];
    */
    

}

- (void)shootTimer {
    
    CCCallFunc *call = [CCCallFunc actionWithTarget:self selector:@selector(shootStraight)];
    CCCallFunc *call2 = [CCCallFunc actionWithTarget:self selector:@selector(shootAngle)];
    CCCallFunc *move = [CCCallFunc actionWithTarget:self selector:@selector(moveUpDownLeftRight)];
    CCCallFunc *call3 = [CCCallFunc actionWithTarget:self selector:@selector(shootFireball)];
    CCDelayTime *delay1 = [CCDelayTime actionWithDuration:3];
    CCDelayTime *delay2 = [CCDelayTime actionWithDuration:8];
    //CCDelayTime *delay3 = [CCDelayTime actionWithDuration:];
    CCSequence *shootStraight = [CCSequence actions:call, delay1, call, delay1, call, delay1, call, delay1, call, delay1, nil];
    CCSequence *shootAngle = [CCSequence actions:call2, delay1, call2, delay1, call2, delay1, call2, delay1, call2, delay1, nil];
    CCSequence *shootBoth = [CCSequence actions:call, call2, delay1, call, call2, delay1, call, call2, delay1, call, call2, delay1, call, call2, delay1, nil];
    CCSequence *shootFireball = [CCSequence actions:call3, delay1, nil];
    
    
    //CCSequence *actionToRun = [CCSequence actions:shootFireball, nil];
    CCSequence *actionToRun = [CCSequence actions:shootStraight, shootAngle, move, shootAngle, shootBoth, delay1, shootFireball, delay1, shootFireball, delay2, nil];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:actionToRun];
    [self runAction:repeat];
    
}

- (void)shootTimerLastPhase {
    
    CCCallFunc *call = [CCCallFunc actionWithTarget:self selector:@selector(shootStraight)];
    CCCallFunc *call2 = [CCCallFunc actionWithTarget:self selector:@selector(shootAngle)];
    CCDelayTime *delay1 = [CCDelayTime actionWithDuration:1];
    CCDelayTime *delay2 = [CCDelayTime actionWithDuration:8];
    //CCDelayTime *delay3 = [CCDelayTime actionWithDuration:];
    CCSequence *shootBoth = [CCSequence actions:call, call2, delay1, call, call2, delay1, call, call2, delay1, call, call2, delay1, call, call2, delay1, nil];
    
    
    //CCSequence *actionToRun = [CCSequence actions:shootFireball, nil];
    CCSequence *actionToRun = [CCSequence actions:shootBoth, delay1, shootBoth, delay1, shootBoth, delay2, nil];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:actionToRun];
    [self runAction:repeat];
    
}

-(void)beginLastPhase
{
    [self schedule:@selector(randomAction) interval:2 repeat:-1 delay:2];
    [self shootTimerLastPhase];
}

- (void)randomAction {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int randomAction = arc4random() % 3;
    
    CCFiniteTimeAction *action;
    if (randomAction <= 1 || !_stopLooping) {
        
        _stopLooping = YES;
        
        float randWidth = winSize.width *
        randomValueBetween(0.5, 1.1);
        float randHeight = winSize.height *
        randomValueBetween(0, 1.1);
        CGPoint randDest = ccp(randWidth, randHeight);
        
        float randVel =
        randomValueBetween(winSize.height/4,
                           winSize.height/2);
        float randLength =
        ccpLength(ccpSub(_bossmain.position, randDest));
        float randDuration = randLength / randVel;
        randDuration = MAX(randDuration, 1);
        
        action = [CCMoveTo actionWithDuration:1
                                     position:ccp(randWidth, randHeight)];
        [_bossmain runAction:
         [CCSequence actions:action,
          nil]];

        
        
    }   else {
              
        [self shootFireball];
        
    }
    
    

    
}


-(void)bigLaserSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"laser2.wav" pitch:2.0f pan:1.0f gain:2.0f];
}
-(void)laserSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"laser4.mp3" pitch:1.0f pan:1.0f gain:2.0f];
}

-(void)moveUpDownLeftRight
{
    [self unschedule:@selector(moveUpDownLeftRight)];
    [self moveBoss:1.8 :40 :150 :2];
}

-(void)moveBoss:(float)duration :(float)x :(float)y :(float)t
{ 
    
    //CGSize winSize = [CCDirector sharedDirector].winSize;

    id shakeLow = [CCMoveBy
                   actionWithDuration:duration position:ccp(x, -y)];
    id shakeLowBack = [CCMoveBy
                       actionWithDuration:duration position:ccp(x, y)];
    id shakeHigh =  [CCMoveBy
                     actionWithDuration:duration position:ccp(-x, y)];
    id shakeHighBack = [CCMoveBy
                        actionWithDuration:duration position:ccp(-x, -y)];
    id shake = [CCSequence actions:shakeLow, shakeLowBack,
                shakeHigh, shakeHighBack, nil];
    CCRepeat* shakeAction = [CCRepeat actionWithAction:shake times:t];
    
    id shakeLow2 = [CCMoveBy
                    actionWithDuration:duration position:ccp(x, -y)];
    id shakeLowBack2 = [CCMoveBy
                        actionWithDuration:duration position:ccp(x, y)];
    id shakeHigh2 =  [CCMoveBy
                      actionWithDuration:duration position:ccp(-x, y)];
    id shakeHighBack2 = [CCMoveBy
                         actionWithDuration:duration position:ccp(-x, -y)];
    id shake2 = [CCSequence actions:shakeLow2, shakeLowBack2,
                shakeHigh2, shakeHighBack2, nil];
    CCRepeat* shakeAction2 = [CCRepeat actionWithAction:shake2 times:t];
    
    id shakeLow3 = [CCMoveBy
                    actionWithDuration:duration position:ccp(+x, -y)];
    id shakeLowBack3 = [CCMoveBy
                        actionWithDuration:duration position:ccp(+x, y)];
    id shakeHigh3 =  [CCMoveBy
                      actionWithDuration:duration position:ccp(-x, y)];
    id shakeHighBack3 = [CCMoveBy
                         actionWithDuration:duration position:ccp(-x, -y)];
    id shake3 = [CCSequence actions:shakeLow3, shakeLowBack3,
                 shakeHigh3, shakeHighBack3, nil];
    CCRepeat* shakeAction3 = [CCRepeat actionWithAction:shake3 times:t];
    
    id shakeLow4 = [CCMoveBy
                    actionWithDuration:duration position:ccp(+x, -y)];
    id shakeLowBack4 = [CCMoveBy
                        actionWithDuration:duration position:ccp(+x, y)];
    id shakeHigh4 =  [CCMoveBy
                      actionWithDuration:duration position:ccp(-x, y)];
    id shakeHighBack4 = [CCMoveBy
                         actionWithDuration:duration position:ccp(-x, -y)];
    id shake4 = [CCSequence actions:shakeLow4, shakeLowBack4,
                 shakeHigh4, shakeHighBack4, nil];
    CCRepeat* shakeAction4 = [CCRepeat actionWithAction:shake4 times:t];
    
    id shakeLow5 = [CCMoveBy
                    actionWithDuration:duration position:ccp(+x, -y)];
    id shakeLowBack5 = [CCMoveBy
                        actionWithDuration:duration position:ccp(+x, y)];
    id shakeHigh5 =  [CCMoveBy
                       actionWithDuration:duration position:ccp(-x, y)];
    id shakeHighBack5 = [CCMoveBy
                         actionWithDuration:duration position:ccp(-x, -y)];
    id shake5 = [CCSequence actions:shakeLow5, shakeLowBack5,
                 shakeHigh5, shakeHighBack5, nil];
    CCRepeat* shakeAction5 = [CCRepeat actionWithAction:shake5 times:t];
    
    [_bossarmtop runAction:shakeAction2];
    [_bossarmbottom runAction:shakeAction3];
    [_bossarmsidetop runAction:shakeAction4];
    [_bossarmsidebottom runAction:shakeAction5];
    [_bossmain runAction:shakeAction];

}

-(void)shootStraight
{
    if(!_topArmDead){
        [self shootStraightFromPosition:_bossarmtop.position];
    }
    if(!_bottomArmDead){
        [self shootStraightFromPosition:_bossarmbottom.position];
    }
    if(!_bottomMiddleArmDead){
        [self shootStraightFromPosition:_bossarmsidebottom.position];
    }
    if(!_topMiddleArmDead){
        [self shootStraightFromPosition:_bossarmsidetop.position];
    }
    
    [self shootStraightFromPosition:_bossmain.position];
    [[SimpleAudioEngine sharedEngine] playEffect:@"multilaser.mp3" pitch:1.0f pan:0.0f gain:1.5f];
    
}

-(void)shootAngle
{
    if(!_topArmDead){
        [self shootAngleFromPosition:_bossarmtop.position];
    }
    if(!_bottomArmDead){
        [self shootAngleFromPosition:_bossarmbottom.position];
    }
    if(!_bottomMiddleArmDead){
        [self shootAngleFromPosition:_bossarmsidebottom.position];
    }
    if(!_topMiddleArmDead){
        [self shootAngleFromPosition:_bossarmsidetop.position];
    }
    
    [self shootAngleFromPosition:_bossmain.position];
    [[SimpleAudioEngine sharedEngine] playEffect:@"multilaser.mp3" pitch:2.0f pan:0.0f gain:1.5f];
    
}


-(void)shootCannon
{
    if(!_topMiddleArmDead){
        [self shootCannonBallAtShipFromPosition:_bossarmsidetop.position];
    }
    if(!_bottomMiddleArmDead){
        [self shootCannonBallAtShipFromPosition:_bossarmsidebottom.position];
    }
    
    if(_topArmDead && _topMiddleArmDead
       && _bottomArmDead && _bottomMiddleArmDead){
        [self stopAllActions];
        [self beginLastPhase];
        [self unschedule:@selector(shootCannon)];
    }
}

-(void)shootBigLaser
{
    [self shootEnemyLaserFromPosition:_bossarmtop.position];
    
}



-(void)enemyShoot2
{
    [self shootEnemyLaserGreenFromPosition:_bossmain.position];
}

-(void)enemyShoot3
{
    [self shootEnemyLaserGreenFromPosition:_bossmain.position];
}

-(void)enemyShoot4
{
    [self shootEnemyLaserGreenFromPosition:_bossmain.position];}

-(void)shootFireball
{
    [self shootFireballFromPosition:_bossmain.position];
    [[SimpleAudioEngine sharedEngine] playEffect:@"lasercharge.mp3" pitch:2.1f pan:0.0f gain:.4f];
}

-(void)enemyShoot
{
    [self shootEnemyLaserGreenFromPosition:_bossmain.position];
}

- (void)removeNode:(CCNode *)sender
{
    [sender removeFromParent];
}

- (void)shootEnemyLaserFromPosition:(CGPoint)position
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *shipLaser = [_enemyLasers nextSprite];
    GameObject *shipLaser2 = [_enemyLasers nextSprite];
    
    
    
    //[[SimpleAudioEngine sharedEngine] playEffect:@"laser_enemy.caf" pitch:1.0f pan:0.0f gain:0.25f];
    shipLaser.position = ccp(winSize.width/2, winSize.height *.935);
    shipLaser.rotation = 0;
    [shipLaser revive];
    [shipLaser stopAllActions];
    [shipLaser runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2.2
                          position:ccp(-winSize.width, 0)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
    
    shipLaser2.position = ccp(winSize.width/2, winSize.height *.062);
    shipLaser2.rotation = 0;
    [shipLaser2 revive];
    [shipLaser2 stopAllActions];
    [shipLaser2 runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2.2
                          position:ccp(-winSize.width, 0)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
}

- (void)shootEnemyLaserGreenFromPosition:(CGPoint)position
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *shipLaser = [_enemyLaserGreen nextSprite];
    GameObject *shipLaser2 = [_enemyLaserGreen nextSprite];
    GameObject *shipLaser3 = [_enemyLaserGreen nextSprite];
    GameObject *shipLaser4 = [_enemyLaserGreen nextSprite];
    GameObject *shipLaser5 = [_enemyLaserGreen nextSprite];
    GameObject *shipLaser6 = [_enemyLaserGreen nextSprite];
    
    
    
    
    //[[SimpleAudioEngine sharedEngine] playEffect:@"laser_enemy.caf" pitch:1.0f pan:0.0f gain:0.25f];
    shipLaser.position = position;
    shipLaser.rotation = 42;
    [shipLaser revive];
    [shipLaser stopAllActions];
    [shipLaser runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2
                          position:ccp(-winSize.width/3, winSize.height*.4)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
    
    shipLaser2.position = position;
    shipLaser2.rotation = -42;
    [shipLaser2 revive];
    [shipLaser2 stopAllActions];
    [shipLaser2 runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2
                          position:ccp(-winSize.width/3, -winSize.height*.4)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
    
    shipLaser3.position = ccp(winSize.width/2, winSize.height *.9);
    shipLaser3.rotation = -50;
    [shipLaser3 revive];
    [shipLaser3 stopAllActions];
    [shipLaser3 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2],
      [CCMoveBy actionWithDuration:4.5
                          position:ccp(-winSize.width/2, -winSize.height*.805)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
    
    shipLaser4.position = ccp(winSize.width/2, winSize.height *.1);
    shipLaser4.rotation = 50;
    [shipLaser4 revive];
    [shipLaser4 stopAllActions];
    [shipLaser4 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2],
      [CCMoveBy actionWithDuration:4.5
                          position:ccp(-winSize.width/2, winSize.height*.805)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
    
    shipLaser5.position = ccp(winSize.width*2, winSize.height *.9);
    shipLaser5.rotation = -50;
    [shipLaser5 revive];
    [shipLaser5 stopAllActions];
    [shipLaser5 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:6.5],
      [CCMoveTo actionWithDuration:0 position:ccp(-23, winSize.height *.91)],
      [CCMoveBy actionWithDuration:4.5
                          position:ccp(-winSize.width/2, -winSize.height*.805)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
    
    shipLaser6.position = ccp(winSize.width*2, winSize.height *.1);
    shipLaser6.rotation = 50;
    [shipLaser6 revive];
    [shipLaser6 stopAllActions];
    [shipLaser6 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:6.5],
      [CCMoveTo actionWithDuration:0 position:ccp(-23, winSize.height *.09)],
      [CCMoveBy actionWithDuration:4.5
                          position:ccp(-winSize.width/2, winSize.height*.805)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
    
}

- (void)shootStraightFromPosition:(CGPoint)position
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *shipLaser = [_enemyLasers nextSprite];
    
    
    
    //[[SimpleAudioEngine sharedEngine] playEffect:@"laser_enemy.caf" pitch:1.0f pan:0.0f gain:0.25f];
    shipLaser.position = position;
    shipLaser.rotation = 0;
    [shipLaser revive];
    [shipLaser stopAllActions];
    [shipLaser runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2.5
                          position:ccp(-winSize.width-200, 0)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
}

- (void)shootAngleFromPosition:(CGPoint)position
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *shipLaser = [_enemyLasers nextSprite];
    GameObject *shipLaser2 = [_enemyLasers nextSprite];
    
    
    
    //[[SimpleAudioEngine sharedEngine] playEffect:@"laser_enemy.caf" pitch:1.0f pan:0.0f gain:0.25f];
    shipLaser.position = position;
    shipLaser.rotation = 20;
    [shipLaser revive];
    [shipLaser stopAllActions];
    [shipLaser runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2.5
                          position:ccp(-winSize.width-200, winSize.height)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
    
    //[[SimpleAudioEngine sharedEngine] playEffect:@"laser_enemy.caf" pitch:1.0f pan:0.0f gain:0.25f];
    shipLaser2.position = position;
    shipLaser2.rotation = -20;
    [shipLaser2 revive];
    [shipLaser2 stopAllActions];
    [shipLaser2 runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2.5
                          position:ccp(-winSize.width-200, -winSize.height)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
}


- (void)shootCannonBallAtShipFromPosition:(CGPoint)position {
    
    int a = randomValueBetween(8,12);
    
    if(a == 10)
    {
    
        CGSize winSize = [CCDirector sharedDirector].winSize;
        GameObject *cannonBall = [_cannonBalls nextSprite];
    
        [[SimpleAudioEngine sharedEngine] playEffect:@"cannon.mp3" pitch:2.0f pan:0.3f gain:0.5f];
    
        CGPoint shootVector =
        ccpNormalize(ccpSub(_ship.position, position));
        CGPoint shootTarget = ccpMult(shootVector,
                                  winSize.width*2);
    
        cannonBall.position = position;
        [cannonBall revive];
        [cannonBall runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:10 position:shootTarget],
          [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
          nil]];
    }
}

- (void)shootFireballFromPosition:(CGPoint)position {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *fireball = [_fireballArray nextSprite];
    
    
    
    emitter4 = [CCParticleSystemQuad particleWithFile:@"charge.plist"];
    emitter4.position = position;
    
    emitter5 = [CCParticleSystemQuad particleWithFile:@"fireball4.plist"];
    emitter5.position = ccp(-position.x, position.y);
    fireball.position = ccp(-position.x, position.y);
    
    CGPoint shootVector =
    ccpNormalize(ccpSub(_ship.position, position));
    CGPoint shootTarget = ccpMult(shootVector,
                                  winSize.width*2);
    
    [emitter5 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2],
      [CCMoveTo actionWithDuration:0 position:position],
      [CCMoveTo actionWithDuration:5 position:shootTarget],
      nil]];
    
    
    [self addChild:emitter4 z:-1];
    [self addChild:emitter5 z:-1];
    
    
    [fireball revive];
    [fireball runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2],
      [CCMoveTo actionWithDuration:0 position:ccp(position.x - 80, position.y)],
      [CCMoveTo actionWithDuration:5 position:shootTarget],
      [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
      nil]];

    
}

- (void)beginContact:(b2Contact *)contact
{
    
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
    
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    
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
            if(enemyShip == _bossarmbottom || enemyShip == _bossarmtop){
                [enemyShip takeHit];
                [laser takeHit];
                [self explosionSmall:contactPoint];
            }
            if(enemyShip == _bossarmsidetop || enemyShip == _bossarmsidebottom){
                if(_topArmDead && _bottomArmDead){
                    [enemyShip takeHit];
                    [laser takeHit];
                    [self explosionSmall:contactPoint];
                }
            }
            if(enemyShip == _bossmain){
                if(_topMiddleArmDead && _bottomMiddleArmDead){
                    [enemyShip takeHit];
                    [laser takeHit];
                    [self explosionSmall:contactPoint];
                }
            }
            
            
        if ([enemyShip dead]) {
            _score += 100000;
            [self explosionLarge:contactPoint];
            if(enemyShip == _bossarmtop){
                _topArmDead = YES;
            }
            if(enemyShip == _bossarmbottom){
                _bottomArmDead = YES;
            }
            if(enemyShip == _bossarmsidetop){
                _topMiddleArmDead = YES;
            }
            if(enemyShip == _bossarmsidebottom){
                _bottomMiddleArmDead = YES;
            }
            if(enemyShip == _bossmain){
                [self bigExplosion:contactPoint];
            }
            
            }
            
        }
    }
    
    
    
    /*******************************************************************************
     This checks to see if an enemy collides with the ship, and if so plays an
     explosion, shakes the screen, destroys the enemy, and makes the ship take a hit.
     If the ship is dead after this, it displays the Game Over menu.
     *******************************************************************************/
    if ((fixtureA->GetFilterData().categoryBits & kCategoryShip && fixtureB->GetFilterData().categoryBits & kCategoryEnemy) ||
        (fixtureB->GetFilterData().categoryBits & kCategoryShip && fixtureA->GetFilterData().categoryBits & kCategoryEnemy)) {
        
        // Determine enemy ship
        GameObject *enemyShip = (GameObject*) spriteA;
        if (fixtureB->GetFilterData().categoryBits & kCategoryEnemy) {
            enemyShip = spriteB;
        }
        
        if (!enemyShip.dead) {
            
            if(enemyShip == _bossarmtop){
                [_ship destroy];
            }
            if(enemyShip == _bossarmbottom){
                [_ship destroy];
            }
            if(enemyShip == _bossarmsidetop){
                [_ship destroy];            }
            if(enemyShip == _bossarmsidebottom){
                [_ship destroy];
            }
            if(enemyShip == _bossmain){
                [_ship destroy];
            }
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf" pitch:1.0f pan:0.0f gain:0.25f];
            
            [self shakeScreen:1];
            CCParticleSystemQuad *explosion = [_explosions nextParticleSystem];
            explosion.scale *= 0.5;
            explosion.position = contactPoint;
            
            [explosion resetSystem];
            
            [enemyShip takeHit];
            _score += 100;
            if (!_invincible) {
                [_ship takeHit];
            }
            
            if (_ship.dead) {
                [self endScene:NO];
                _isPlaying = NO;
                [self stopAllActions];
                [self unscheduleAllSelectors];
            }
            
        }
        
    }
    
    
}

-(void)bigExplosion:(CGPoint)contactPoint
{
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    emitter6 = [CCParticleSystemQuad particleWithFile:@"bigexplosion2.plist"];
        
    emitter6.position = contactPoint;
    
    [self addChild:emitter6 z:100];
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self scheduleUpdate];
    [self scheduleOnce:@selector(bossCleared) delay:1];
    
    
    
    


}

-(void)explosionLarge:(CGPoint)contactPoint
{
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf" pitch:1.0f pan:0.0f gain:1.0f];
    CCParticleSystemQuad *explosion = [_explosions nextParticleSystem];
    
    explosion.position = contactPoint;
    
    [explosion resetSystem];
    _score += 100;
}
-(void)explosionSmall:(CGPoint)contactPoint
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.mp3" pitch:1.0f pan:0.0f gain:.75f];
    CCParticleSystemQuad *explosion = [_explosions nextParticleSystem];
    explosion.scale *= 0.25;
    explosion.position = contactPoint;
    [explosion resetSystem];

}


- (void)endContact:(b2Contact *)contact {
    
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
    
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:message
                                                  fntFile:@"SpaceGameFont.fnt"];
    label.scale = 0.1;
    label.position = ccp(winSize.width/2,
                         winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel = [CCLabelBMFont labelWithString:@"Restart"
                                                         fntFile:@"SpaceGameFont.fnt"];
    
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

-(void)bossCleared
{
    
    [self stopAllActions];
    
        
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
            message = @"Boss Destroyed!";
        
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:message
                                                  fntFile:@"SpaceGameFont.fnt"];
    label.scale = 0.1;
    label.position = ccp(winSize.width/2,
                         winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel = [CCLabelBMFont labelWithString:@"View High Scores"
                                                         fntFile:@"SpaceGameFont.fnt"];
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel
                                    itemWithLabel:restartLabel target:self
                                    selector:@selector(highScores:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2,
                               winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [restartItem runAction:[CCScaleTo
                            actionWithDuration:0.5 scale:0.5]];
    [label runAction:[CCScaleTo actionWithDuration:0.5
                                             scale:0.8]];
    
    
}

- (void)highScores:(id)sender {
    
    // Reload the current scene
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFadeBL transitionWithDuration:2
                                          scene:[HighScoreScene node]]];
    
    _isPlaying = NO;
    
}

- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    CCScene *scene = [ActionLayer scene];
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionZoomFlipX transitionWithDuration:1
                                             scene:scene]];
    
    _isPlaying = NO;
    
}



- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Prevent the laser from shooting before Play.
    
    NSLog(@"Fire begins");
    _multiple =YES;
    
    [self beginFire];
    _firing = YES;
    
    UITouch *urtouch = [touches anyObject];
    
    NSUInteger urtapCount = [urtouch tapCount];
    
    switch (urtapCount) {
            
        case 1:
            break;
            
        case 2:
            break;
            
        case 3:
            [self gamePause];
            break;
            
        default :
            break;
            
    }
    
    
}

-(void)gamePause
{
    if(!_isPaused)
    {
        [[CCDirector sharedDirector] stopAnimation];
        [[CCDirector sharedDirector] pause];
        _isPaused = YES;
    }
    else{
        [[CCDirector sharedDirector] stopAnimation];
        [[CCDirector sharedDirector] resume];
        [[CCDirector sharedDirector] startAnimation];
        _isPaused = NO;
    }
}

-(void)beginFire
{
    //OLD
    //_timer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(shootSingle) userInfo:nil repeats:YES];
    //_timer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(shootMultiple) userInfo:nil repeats:YES];
    
    //Cocos2d scheduler
    if(_single){
        [self schedule:@selector(shootSingle) interval:.2];
    }
    if(_multiple){
        [self schedule:@selector(shootMultiple) interval:.18];
    }
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_single){
        [self unschedule:@selector(shootSingle)];
    }
    if(_multiple){
        [self unschedule:@selector(shootMultiple)];
    }
    _firing = NO;
    
}


-(void)shootMultiple
{
    if(_isPlaying){
    if(_multiple){
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        [[SimpleAudioEngine sharedEngine]
         playEffect:@"laser_ship.caf" pitch:1.0f pan:0.0f
         gain:0.25f];
        
        GameObject *shipLaser = [_laserArray nextSprite];
        [shipLaser stopAllActions];
        shipLaser.position = ccpAdd(_ship.position, ccp(shipLaser.contentSize.width/2, 0));
        [shipLaser revive];
        
        GameObject *shipLaser2 = [_laserArray nextSprite];
        [shipLaser2 stopAllActions];
        shipLaser2.position = ccpAdd(_ship.position, ccp(shipLaser2.contentSize.width/2, 15));
        [shipLaser2 revive];
        
        GameObject *shipLaser3 = [_laserArray nextSprite];
        [shipLaser3 stopAllActions];
        shipLaser3.position = ccpAdd(_ship.position, ccp(shipLaser3.contentSize.width/2, -15));
        [shipLaser3 revive];
        
        [shipLaser runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:.9
                              position:ccp(winSize.width, 0)],
          [CCCallFuncN actionWithTarget:self
                               selector:@selector(invisNode:)],
          nil]];
        
        [shipLaser2 runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:.9
                              position:ccp(winSize.width, 100)],
          [CCCallFuncN actionWithTarget:self
                               selector:@selector(invisNode:)],
          nil]];
        
        [shipLaser3 runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:.9
                              position:ccp(winSize.width, -100)],
          [CCCallFuncN actionWithTarget:self
                               selector:@selector(invisNode:)],
          nil]];
    }
    }
    
    
}

-(void)shootSingle
{
    
    if(_isPlaying){
    if(_single){
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
          [CCMoveBy actionWithDuration:.8
                              position:ccp(winSize.width, 0)],
          [CCCallFuncN actionWithTarget:self
                               selector:@selector(invisNode:)],
          nil]];
    }
    }
}

- (void)invisNode:(GameObject *)sender {
    [sender destroy];
}


- (void)setupShapeCache {
    [[ShapeCache sharedShapeCache] addShapesWithFile:@"Shapes.plist"];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
#define kFilteringFactorX 0.75
#define kFilteringFactorY 0.9
    
    static UIAccelerationValue rollingX = 0, rollingY = 0, rollingZ = 0;
    
    rollingX = (acceleration.x * kFilteringFactorX) + (rollingX * (1.0 - kFilteringFactorX));
    rollingY = (acceleration.y * kFilteringFactorY) + (rollingY * (1.0 - kFilteringFactorY));
    rollingZ = (acceleration.z * kFilteringFactorX) + (rollingZ * (1.0 - kFilteringFactorX));
    
    float accelX = rollingX;
    float accelY = rollingY;
   // float accelZ = rollingZ;
    
    //NSLog(@"accelX: %f, accelY: %f, accelZ: %f", accelX, accelY, accelZ);
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    /*******************************************************************************
     This first figures out the difference between accelX and X (accelDiffX). It
     then divides the difference by X to compute an acceleration fraction
     (accelFractionX).
     Sets the points per second to move equal to the maximum speed to move (half
     the height of the screen per second) times the acceleration fraction.
     *******************************************************************************/
    
#define kRestAccelX 0.6
#define kShipMaxPointsPerSec (winSize.height*0.5)
#define kMaxDiffX 0.2
    
#define kRestAccelY 0.01
#define kShipMaxPointsPerSecY (winSize.width*0.5)
#define kMaxDiffY 0.2
    
    
    float accelDiffX = kRestAccelX - ABS(accelX);
    float accelFractionX = accelDiffX / kMaxDiffX;
    float pointsPerSecX = kShipMaxPointsPerSec * accelFractionX;
    
    float accelDiffY = kRestAccelY - (accelY);
    float accelFractionY = accelDiffY / kMaxDiffY;
    float pointsPerSecY = kShipMaxPointsPerSecY * accelFractionY;
    
    
    _shipPointsPerSecY = pointsPerSecX;
    
    
    //NSLog(@"xpoints %f, ypoints %f", pointsPerSecX, pointsPerSecY);
    
    
    _shipPointsPerSecX = pointsPerSecY;
    /*******************************************************************************
     
     *******************************************************************************/
    
    
}

- (void)setupArrays {
    
    //setup the array of enemies
    _enemysArray = [[SpriteArray alloc] initWithCapacity:75
                                         spriteFrameName:@"foe1.png"
                                               batchNode:_batchNode
                                                   world:_world
                                               shapeName:@"foe1"
                                                   maxHp:1
                                           healthBarType:HealthBarTypeNone];
    
    //setup the array of lasers
    _laserArray = [[SpriteArray alloc] initWithCapacity:60
                                        spriteFrameName:@"laserbeam_blue.png"
                                              batchNode:_batchNode
                                                  world:_world
                                              shapeName:@"laserbeam_blue"
                                                  maxHp:1
                                          healthBarType:HealthBarTypeNone];
    
    //sets up array of explosions
    _explosions = [[ParticleSystemArray alloc] initWithFile:@"Explosion.plist"
                                                   capacity:3
                                                     parent:self];
    
    //sets up array of alien ships
    _alienArray = [[SpriteArray alloc] initWithCapacity:15
                                        spriteFrameName:@"wasp1.png"
                                              batchNode:_batchNode
                                                  world:_world
                                              shapeName:@"enemy_spaceship"
                                                  maxHp:1
                                          healthBarType:HealthBarTypeNone];
    
    //sets up array of enemy lasers
    _enemyLasers = [[SpriteArray alloc] initWithCapacity:500
                                         spriteFrameName:@"laserbeam_big.png"
                                               batchNode:_batchNode
                                                   world:_world shapeName:@"laserbeam_red"
                                                   maxHp:1
                                           healthBarType:HealthBarTypeNone];
    
    _enemyLaserGreen = [[SpriteArray alloc] initWithCapacity:500
                                         spriteFrameName:@"laserbeam_green.png"
                                               batchNode:_batchNode
                                                   world:_world shapeName:@"laserbeam_red"
                                                   maxHp:1
                                           healthBarType:HealthBarTypeNone];
    
    //sets up array of powerupBolt
    _powerupBolt = [[SpriteArray alloc] initWithCapacity:5
                                         spriteFrameName:@"powerup.png"
                                               batchNode:_batchNode
                                                   world:_world
                                               shapeName:@"powerup"
                                                   maxHp:1
                                           healthBarType:HealthBarTypeNone];
    
    _powerupMultiple = [[SpriteArray alloc] initWithCapacity:5
                                             spriteFrameName:@"multiple1.png"
                                                   batchNode:_batchNode
                                                       world:_world
                                                   shapeName:@"multiple1"
                                                       maxHp:1
                                               healthBarType:HealthBarTypeNone];
    
    //sets up array of particle effect (booster)
    _boostEffects = [[ParticleSystemArray alloc] initWithFile:@"Boost.plist"
                                                     capacity:1
                                                       parent:self];
    
    //sets up array of boss cannon
    _cannonBalls = [[SpriteArray alloc] initWithCapacity:25
                                         spriteFrameName:@"Boss_cannon_ball.png"
                                               batchNode:_batchNode
                                                   world:_world
                                               shapeName:@"Boss_cannon_ball"
                                                   maxHp:1
                                           healthBarType:HealthBarTypeNone];
    
    //sets up enemy Flyer
    _enemyFlyerArray = [[SpriteArray alloc] initWithCapacity:10
                                             spriteFrameName:@"foe1.png"
                                                   batchNode:_batchNode
                                                       world:_world
                                                   shapeName:@"enemy_spaceship"
                                                       maxHp:10
                                               healthBarType:HealthBarTypeRed];
    
    _bossMainArray = [[SpriteArray alloc] initWithCapacity:2
                                           spriteFrameName:@"bossmain.png"
                                                 batchNode:_batchNode
                                                     world:_world
                                                 shapeName:@"bossmain"
                                                     maxHp:500
                                             healthBarType:HealthBarTypeRed];
    
    _bossArmSideArray = [[SpriteArray alloc] initWithCapacity:2
                                              spriteFrameName:@"bossarmside.png"
                                                    batchNode:_batchNode
                                                        world:_world
                                                    shapeName:@"bossarmside"
                                                        maxHp:150
                                                healthBarType:HealthBarTypeRed];
    

    _bossTopArmArray = [[SpriteArray alloc] initWithCapacity:1
                                         spriteFrameName:@"bossarmtop.png"
                                               batchNode:_batchNode
                                                   world:_world
                                               shapeName:@"bossarmbottom"
                                                   maxHp:300
                                           healthBarType:HealthBarTypeRed];
    
    _bossBottomArmArray = [[SpriteArray alloc] initWithCapacity:1
                                             spriteFrameName:@"bossarmtop.png"
                                                   batchNode:_batchNode
                                                       world:_world
                                                   shapeName:@"bossarmtop"
                                                       maxHp:300
                                               healthBarType:HealthBarTypeRed];
    
    _fireballArray = [[SpriteArray alloc] initWithCapacity:10
                                                spriteFrameName:@"transparent.png"
                                                      batchNode:_batchNode
                                                          world:_world
                                                      shapeName:@"transparent"
                                                          maxHp:1
                                                  healthBarType:HealthBarTypeNone];

}

- (void)spawnShip {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    //Creates the ship as a GameObject instead of CCSprite, so a Box2D body
    //associated with it—and set hit points for the ship
    _ship = [[GameObject alloc] initWithSpriteFrameName:@"fighter1.png"
                                                  world:_world
                                              shapeName:@"fighter1"
                                                  maxHp:20
                                          healthBarType:HealthBarTypeGreen];
    _ship.position = ccp(-_ship.contentSize.width/2,
                         winSize.height * 0.5);
    NSLog(@"Updated ship and ship POS");
    
    //It is important to call revive after setting the position, because revive
    //sets the initial position of the Box2D body based on the sprite’s position.
    [_ship revive];
    NSLog(@"Ship revive done");
    [_batchNode addChild:_ship z:1];
    NSLog(@"added ship to batchnode");
    
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
    
    /*******************************************************************************
     Animating a sprite in Cocos2D. There are just two steps:
     1.	Create a CCAnimation, specifying the images that make up the animation.
     2.	Create a CCAnimate action and run it on the sprite, specifying the
     CCAnimation created earlier.
     CCAnimate action runs the animation only once, CCRepeatForever action so it
     keeps going until we tell it to stop.
     *******************************************************************************/
    CCSpriteFrameCache * cache =
    [CCSpriteFrameCache sharedSpriteFrameCache];
    
    CCAnimation *animation = [CCAnimation animation];
    [animation addSpriteFrame:
     [cache spriteFrameByName:@"fighter1.png"]];
    [animation addSpriteFrame:
     [cache spriteFrameByName:@"fighter2.png"]];
    animation.delayPerUnit = 0.2;
    
    [_ship runAction:
     [CCRepeatForever actionWithAction:
      [CCAnimate actionWithAnimation:animation]]];
    /*******************************************************************************
     This creates a new animation and adds both sprite frames to it. Then it runs a
     new CCAnimate action on the ship, wrapped in a CCRepeatForeverAction
     *******************************************************************************/
    
    
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

- (void)updateShipPos:(ccTime)dt {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float maxY = winSize.height - _ship.contentSize.height/2;
    float minY = _ship.contentSize.height/2;
    float maxX = winSize.width + 100 - _ship.contentSize.width/2;
    float minX = _ship.contentSize.width -300/2;
    
    float newY = _ship.position.y + (_shipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    float newX = _ship.position.x + (_shipPointsPerSecX * dt);
    newX = MIN(MAX(newX, minX), maxX);
    
    _ship.position = ccp(newX, newY);
}

- (void)update:(ccTime)dt
{
    //sets ships possition
    [self updateShipPos:dt];
    [self updateBox2D:dt];
    
}

- (void)setupWorld {
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    _world = new b2World(gravity);
    //initialize and register the collision handler
    _contactListener = new SimpleContactListener(self);
    _world->SetContactListener(_contactListener);
}

- (void)setupStars {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    NSArray *starsArray = @[@"Stars1.plist", @"Stars2.plist", @"Stars3.plist"];
    for(NSString *stars in starsArray) {
        CCParticleSystemQuad *starsEffect =
        [CCParticleSystemQuad particleWithFile:stars];
        starsEffect.position = ccp(winSize.width*1.5, winSize.height/2);
        starsEffect.posVar = ccp(starsEffect.posVar.x, (winSize.height/2) * 1.5);
        [self addChild:starsEffect];
    }
}

- (void)shakeScreen:(int)times {
    
    id shakeLow = [CCMoveBy
                   actionWithDuration:0.025 position:ccp(0, -15)];
    id shakeLowBack = [shakeLow reverse];
    id shakeHigh =  [CCMoveBy
                     actionWithDuration:0.025 position:ccp(0, 15)];
    id shakeHighBack = [shakeHigh reverse];
    id shake = [CCSequence actions:shakeLow, shakeLowBack,
                shakeHigh, shakeHighBack, nil];
    CCRepeat* shakeAction = [CCRepeat
                             actionWithAction:shake times:times];
    
    [self runAction:shakeAction];
}

-(void)displayParticle
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    emitter = [CCParticleSystemQuad particleWithFile:@"firetop.plist"];
    emitter2 = [CCParticleSystemQuad particleWithFile:@"blackhole.plist"];
    emitter2.scale = .2;
    emitter3 = [CCParticleSystemQuad particleWithFile:@"firebott.plist"];
    emitter2.position = ccp(winSize.width * .1, winSize.height/2);
    emitter.position = ccp(winSize.width/2, winSize.height + 100);
    emitter3.position = ccp(winSize.width/2, -100);
    
    emitter4 = [CCParticleSystemQuad particleWithFile:@"charge.plist"];
    emitter4.position = ccp(winSize.width/2, winSize.height/2);
    
    emitter5 = [CCParticleSystemQuad particleWithFile:@"fireball4.plist"];
    emitter5.position = ccp(winSize.width*.8, winSize.height/2);
    
    [emitter2 runAction:
     [CCSequence actions:
      [CCScaleTo actionWithDuration:10 scale:1.5],
      nil]];
    [emitter5 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:5],
      [CCMoveTo actionWithDuration:10 position:ccp(-winSize.width*2, winSize.height/2)],
      nil]];
    
    
    [self addChild:emitter z:100];
    [self addChild:emitter2 z:-1];
    [self addChild:emitter3 z:-1];
    //[self addChild:emitter4 z:-1];
    //[self addChild:emitter5 z:-1];
}


- (id)init
{
    if ((self = [super init])) {
        
        
        [self setupWorld];
        [self setupShapeCache];
        [self setupStars];
        [self setupBatchNode];
        self.accelerometerEnabled = YES;
        [self scheduleUpdate];
        [self setupArrays];
        self.touchEnabled = YES;
        [self setupBackground];
        //[self setupTitle];
        [self displayParticle];
        [self spawnShip];
        [self spawnBossIntro];
        //[self spawnBoss];
        [self setupDebugDraw];
        
        [self runAction:
         [CCSequence actions:
          [CCScaleTo actionWithDuration:3 scale:0.8],
          nil]];
        
        [self shakeScreen:10];
        
    }
    
    _topArmDead = NO;
    _bottomArmDead = NO;
    _topMiddleArmDead = NO;
    _bottomMiddleArmDead = NO;
    _stopLooping = NO;
    _isPlaying = YES;
    return self;
}

- (void)setupDebugDraw {
    _debugDraw = new GLESDebugDraw(PTM_RATIO);
    _world->SetDebugDraw(_debugDraw);
    _debugDraw->SetFlags(b2Draw::e_shapeBit | b2Draw::e_jointBit);
}

- (void) draw
{
    [super draw];
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    kmGLPushMatrix();
    //Uncomment this if you want to see the Box2d rendering of the detection vector
    //_world->DrawDebugData();
    kmGLPopMatrix();
    
    //Debugs draw the Bezier paths to the screen to modify them visually.
    //if (_levelManager.gameState == GameStateNormal &&
    //   [_levelManager boolForProp:@"SpawnAlienSwarm"]) {
    
    //   ccDrawCubicBezier(_alienSpawnStart,
    //                    _bezierConfig.controlPoint_1,
    //                    _bezierConfig.controlPoint_2,
    //                    _bezierConfig.endPosition, 16);
    // ccDrawLine(_alienSpawnStart,
    //            _bezierConfig.controlPoint_1);
    // ccDrawLine(_bezierConfig.endPosition,
    //            _bezierConfig.controlPoint_2);
    
    // }
}
@end
