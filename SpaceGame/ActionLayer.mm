//
//  ActionLayer.mm
//  SpaceBlaster
//
//  Created by JRamos on 2/22/13.
//  Copyright 2013 JRamos. All rights reserved.
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
#import "BigTurret.h"

//Constants to make referring to shape categories easier in code.
#define kCategoryShip       0x1
#define kCategoryShipLaser  0x2
#define kCategoryEnemy      0x4
#define kCategoryPowerup    0x8
#define kCategoryPowerupMultiple    0x10

//Creates an enumeration to keep track of the two different game stages-
//the enemy spawning stage, and the game over stage.
enum GameStage {
    GameStageTitle = 0,
    GameStageEnemys,
    GameStageDone
};


@implementation ActionLayer
{
    /*******************************************************************************
     Private intance variables
     *******************************************************************************/
    
    //Declare two private instance variables for the two CCLabelBMFont labels to display the game’s title.
    //CCLabelBMFont requires pre-rendered font images
    CCLabelBMFont * _titleLabel1;
    CCLabelBMFont * _titleLabel2;
    
    //Play button
    CCMenuItemLabel * _playItem;
    
    //Tutorial button
    CCMenuItemLabel * _tutorialItem;
    
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
    
    
    CCLabelBMFont *_levelIntroLabel1;
    CCLabelBMFont *_levelIntroLabel2;
    CCLabelBMFont *_tutorialLabel;
    
    //Variables for alien ships
    SpriteArray * _alienArray;
    double _nextAlienSpawn;
    double _numAlienSpawns;
    CGPoint _alienSpawnStart;
    ccBezierConfig _bezierConfig;
    
    //Enemy lasers
    double _nextShootChance;
    SpriteArray * _enemyLasers;
    
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
    
}




/*******************************************************************************
 * @method      scene
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 Declares the static scene method. This creates a default CCScene, and adds
 ActionLayer as a child of the scene. When Cocos2D scene run on startup, this
 method is called.
 *******************************************************************************/
+ (id)scene
{
    
    CCScene *scene = [CCScene node];
    ActionLayer *layer = [ActionLayer node];
    [scene addChild:layer];
    return scene;
    
}


/*******************************************************************************
 * @method      setupTitle
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 The setupTitle is called by the ActionLayer’s init. It first needs to get the
 size of the window, to place the text in the right spot. This is simple to get
 with Cocos2D—the CCDirector singleton class has a property called winSize.
 *******************************************************************************/
- (void)setupTitle
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    NSLog(@"Window size (in points): %@", NSStringFromCGSize(winSize));
    
    NSString *fontName = @"SpaceGameFont.fnt";
    
    
    /*******************************************************************************
     Start out each label with a scale of 0, and use Cocos2D actions to make them
     zoom in onto the screen.
     CCallBlock is an action to run an arbitrary block of code when the action
     fires. In this case, when the block runs you simply play the sound effect.
     *******************************************************************************/
    _titleLabel1 = [CCLabelBMFont labelWithString:@"Game By: Jonny Ramos" fntFile:fontName];
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
       [CCScaleTo actionWithDuration:1.0 scale:0.5] rate:2.0],
      nil]];
    
    
    _titleLabel2 = [CCLabelBMFont labelWithString:@"Space Blaster!" fntFile:fontName];
    _titleLabel2.scale = 0;
    _titleLabel2.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:_titleLabel2 z:100];
    [_titleLabel2 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:1.0 scale:1.25] rate:2.0],
      
      nil]];
    /*******************************************************************************
     Cocos2D actions - Create an action based on what the object does (jump, rotate,
     or scale. Must pass the appropriate parameters.
     *******************************************************************************/
    
    
    
    /*******************************************************************************
     This creates a CCLabelBMFont that reads “Play”, and creates a CCMenuItemLabel
     based on this label. The CCMenuItemLabel is set up to call a method called
     playTapped: on the current object (ActionLayer) when it is tapped.
     *******************************************************************************/
    CCLabelBMFont *playLabel = [CCLabelBMFont labelWithString:@"Play" fntFile:fontName];
    _playItem = [CCMenuItemLabel itemWithLabel:playLabel target:self
                                      selector:@selector(playTapped:)];
    _playItem.scale = 0;
    _playItem.position = ccp(winSize.width/2, winSize.height * 0.35);
    
    CCMenu *menu = [CCMenu menuWithItems:_playItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [_playItem runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:0.5] rate:4.0],
      nil]];
    
    /*******************************************************************************
     This positions the menu item to be in the middle of the screen along the x-axis,
     and slightly below the title text along the y-axis. It also sets the scale to 0,
     because at the bottom of the method it runs an action to make it zoom in. It
     then makes a CCMenu with the single menu item you just created. It sets the menu
     at CGPointZero so that the coordinates of menu items are with respect to the
     bottom left of the screen.
     *******************************************************************************/
    
    /*******************************************************************************
     This creates a CCLabelBMFont that reads "Tutorial"
     *******************************************************************************/
    CCLabelBMFont *tutorialLabel = [CCLabelBMFont labelWithString:@"Tutorial" fntFile:fontName];
    _tutorialItem = [CCMenuItemLabel itemWithLabel:tutorialLabel target:self
                                      selector:@selector(tutorialTapped:)];
    _tutorialItem.scale = 0;
    _tutorialItem.position = ccp(winSize.width/2, winSize.height * 0.2);
    
    menu = [CCMenu menuWithItems:_tutorialItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [_tutorialItem runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:0.5] rate:4.0],
      nil]];
    
    
}

/*******************************************************************************
 * @method      endScene
 * @abstract    Display Game over label, and restart game buttons
 * @description
 -------------------------------------------------------------------------------
 •	Checks if the game over menu has already appeared, and bails if so.
 •	Creates a label saying “You win!” or “You lose!” depending on what’s passed
 in to the method.
 •	Creates a label and menu item saying “Restart” and display it in a menu on
 the screen.
 •	Zooms in the label and menu item from 0 to 0.5 scale to make a neat zoom
 in effect.
 *******************************************************************************/
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

/*******************************************************************************
 * @method      restartTapped
 * @abstract
 * @description
 -------------------------------------------------------------------------------
 This creates a fresh copy of the ActionLayer’s scene (hence re-initializing
 everything) and replaces the current scene with this new scene. It also wrap
 things in a cool transition animation for style.
 *******************************************************************************/
- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    CCScene *scene = [ActionLayer scene];
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionZoomFlipX transitionWithDuration:0.5
                                             scene:scene]];
    
}



/*******************************************************************************
 * @method      removeNode
 * @abstract
 * @description This removes the passed-in Cocos2D node from the layer so it’s
 no longer consuming resources, since it’s no longer needed
 *******************************************************************************/
- (void)removeNode:(CCNode *)sender
{
    [sender removeFromParent];
}


/*******************************************************************************
 * @method      spawnShip
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 Creates the ship sprite, adds it to the batch node. Runs a sequence of actions
 to move the ship into the scene by moving it forward, and then back a bit.
 *******************************************************************************/
- (void)spawnShip {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    //Creates the ship as a GameObject instead of CCSprite, so a Box2D body
    //associated with it—and set hit points for the ship
    _ship = [[GameObject alloc] initWithSpriteFrameName:@"fighter1.png"
                                                  world:_world
                                              shapeName:@"fighter1"
                                                  maxHp:10
                                          healthBarType:HealthBarTypeGreen];
    _ship.position = ccp(-_ship.contentSize.width/2,
                         winSize.height * 0.5);
    
    //It is important to call revive after setting the position, because revive
    //sets the initial position of the Box2D body based on the sprite’s position.
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
    
    /*******************************************************************************
     Animating a sprite in Cocos2D. There are just two steps:
     1.	Create a CCAnimation, specifying the images that make up the animation.
     2.	Create a CCAnimate action and run it on the sprite, specifying the
     CCAnimation created earlier.
     Note that the CCAnimate action runs the animation only once, so a lot of times
     you want to wrap it in a CCRepeatForever action so it keeps going until you
     tell it to stop.
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


/*******************************************************************************
 * @method      playTapped
 * @abstract
 * @description When the play button is tapped, play a sound effect (powerup.caf)
 and make the title and menu item zoom out.
 *******************************************************************************/
- (void)playTapped:(id)sender {
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.caf"];
    
    NSArray * nodes = @[_titleLabel1, _titleLabel2, _playItem, _tutorialItem];
    for (CCNode *node in nodes) {
        [node runAction:
         [CCSequence actions:
          [CCEaseOut actionWithAction:
           [CCScaleTo actionWithDuration:0.5 scale:0] rate:4.0],
          [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
          nil]];
    }
    
    [self spawnShip];
    //_gameStage = GameStageenemys;
    [_levelManager nextStage];
    [self newStageStarted];
    //start with singleshot
    _single = YES;
    
}

- (void)tutorialTapped:(id)sender {
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.caf"];
    
    NSArray * nodes = @[_titleLabel1, _titleLabel2, _playItem, _tutorialItem];
    for (CCNode *node in nodes) {
        [node runAction:
         [CCSequence actions:
          [CCEaseOut actionWithAction:
           [CCScaleTo actionWithDuration:0.5 scale:0] rate:4.0],
          [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
          nil]];
    }
    
    [self spawnShip];
    [_levelManager nextStage];
    //_gameStage = GameStageenemys;
    //start with singleshot
    _single = YES;
    
}

/*******************************************************************************
 * @method      setupSound
 * @abstract    preloads sounds
 * @description
 *******************************************************************************/
- (void)setupSound
{
    
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

/*******************************************************************************
 * @method      setupStars
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This method first creates an array with the three files defining the particle
 systems. Then it iterates through the array, and for each file it creates a
 CCParticleSystemQuad with that file.
 *******************************************************************************/
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

/*******************************************************************************
 * @method      setupBatchNode
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 These lines create the CCSpriteBatchNode and add it to the layer and load the
 plist into the CCSpriteFrameCache.
 *******************************************************************************/
- (void)setupBatchNode {
    _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites.pvr.ccz"];
    [self addChild:_batchNode z:-1];
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     addSpriteFramesWithFile:@"Sprites.plist"];
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
    float accelZ = rollingZ;
    
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

- (void)updateShipPos:(ccTime)dt {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float maxY = winSize.height - _ship.contentSize.height/2;
    float minY = _ship.contentSize.height/2;
    float maxX = winSize.width - _ship.contentSize.width/2;
    float minX = _ship.contentSize.width/2;
    
    float newY = _ship.position.y + (_shipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    float newX = _ship.position.x + (_shipPointsPerSecX * dt);
    newX = MIN(MAX(newX, minX), maxX);
    
    _ship.position = ccp(newX, newY);
    //NSLog(@"newX %f, newY %f",newX, newY);
}

/*******************************************************************************
 * @method      UpdateEnemy
 * @abstract    Spanws enemies randomly
 * @description
 *******************************************************************************/
- (void)updateEnemy:(ccTime)dt {
    
    //This makes it so that enemys don’t spawn before Play. (old)
    //We don’t want to spawn enemys if not in the normal game state, or if the
    //current stage doesn’t have the SpawnEnemy property.
    //if (_gameStage != GameStageEnemys) return;
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnEnemys"]) return;
    
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // time to spawn enemy
    double curTime = CACurrentMediaTime();
    if (curTime > _nextEnemySpawn) {
        
        // Figure out the next time to spawn an enemy
        float spawnSecsLow = [_levelManager floatForProp:@"ASpawnSecsLow"];
        float spawnSecsHigh = [_levelManager floatForProp:@"ASpawnSecsHigh"];
        float randSecs = randomValueBetween(spawnSecsLow, spawnSecsHigh);
        _nextEnemySpawn = randSecs + curTime;
        
        // Figure out a random Y value to spawn at
        float randY = randomValueBetween(50.0, winSize.height-50.0);
        
        // Figure out a random amount of time to move
        // from right to left (old)
        //Instead of having these values hardcoded, they come from Levels.plist
        //float randDuration = randomValueBetween(2.0, 10.0);
        float moveDurationLow = [_levelManager floatForProp:@"AMoveDurationLow"];
        float moveDurationHigh = [_levelManager floatForProp:@"AMoveDurationHigh"];
        float randDuration = randomValueBetween(moveDurationLow, moveDurationHigh);
        
        // Create a new enemy sprite
        //Here we use the helper method to get the next available sprite from the
        //array, stop any actions that may be currently running on it, and set it
        //to visible.
        GameObject *enemy = [_enemysArray nextSprite];
        [enemy stopAllActions];
        enemy.visible = YES;
        
        GameObject *enemy2 = [_enemysArray nextSprite];
        [enemy2 stopAllActions];
        enemy2.visible = YES;
        
        GameObject *enemy3 = [_enemysArray nextSprite];
        [enemy3 stopAllActions];
        enemy3.visible = YES;
        
        GameObject *enemy4 = [_enemysArray nextSprite];
        [enemy4 stopAllActions];
        enemy4.visible = YES;
        
        GameObject *enemy5 = [_enemysArray nextSprite];
        [enemy5 stopAllActions];
        enemy5.visible = YES;
        
        // Set its position to be offscreen to the right
        enemy.position = ccp(winSize.width+enemy.contentSize.width/2, randY);
        enemy2.position = ccp(winSize.width+enemy.contentSize.width+80/2, randY);
        enemy3.position = ccp(winSize.width+enemy.contentSize.width+80+80/2, randY);
        enemy4.position = ccp(winSize.width+enemy.contentSize.width+80+80+80/2, randY);
        enemy5.position = ccp(winSize.width+enemy.contentSize.width+80+80+80+80/2, randY);
        
        // Set it's size to be one of X random sizes
        int randNum = arc4random() % 1;
        if (randNum == 0) {
            enemy.scale = 1.2;
            enemy.maxHp = 2;
            enemy2.scale = 1.2;
            enemy2.maxHp = 2;
            enemy3.scale = 1.2;
            enemy3.maxHp = 2;
            enemy4.scale = 1.2;
            enemy4.maxHp = 2;
            enemy5.scale = 1.2;
            enemy5.maxHp = 2;
        }
        [enemy revive];
        [enemy2 revive];
        [enemy3 revive];
        [enemy4 revive];
        [enemy5 revive];
        
        // Move it offscreen to the left, and when it's
        // When done set the sprite from the batch node to invisible
        //(using invisiNode method)
        [enemy runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-enemy.contentSize.width-500, 0)],
          [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
          nil]];
        [enemy2 runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-enemy.contentSize.width-500, 0)],
          [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
          nil]];
        [enemy3 runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-enemy.contentSize.width-500, 0)],
          [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
          nil]];
        [enemy4 runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-enemy.contentSize.width-500, 0)],
          [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
          nil]];
        [enemy5 runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-enemy.contentSize.width-500, 0)],
          [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
          nil]];
        
        
        
        //Animate this enemy ship
        CCSpriteFrameCache * cache =
        [CCSpriteFrameCache sharedSpriteFrameCache];
        
        CCAnimation *animation = [CCAnimation animation];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"foe1.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"foe2.png"]];
        animation.delayPerUnit = 0.2;
        
        [enemy runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [enemy2 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [enemy3 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [enemy4 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [enemy5 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];

        
        //Enemies shoot
        for (GameObject *enemy in _enemysArray.array) {
            if (enemy.visible) {
                if (arc4random() % 50 == 0) {
                    [self shootEnemyLaserFromPosition:
                     enemy.position];
                }
            }
        }
        
    }
}


- (void)updateEnemyFlyer:(ccTime)dt {
    
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnEnemyFlyer"]) return;
    
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    double curTime = CACurrentMediaTime();
    if (curTime > _nextEnemyFlyerSpawn) {
        
        // Figure out the next time to spawn an enemy
        _nextEnemyFlyerSpawn = INFINITY;

        
        // Figure out a random Y value to spawn at
        float randY = randomValueBetween(50.0, winSize.height-50.0);
    
        
        // Create a new enemyflyer sprite
        //Here we use the helper method to get the next available sprite from the
        //array, stop any actions that may be currently running on it, and set it
        //to visible.
        _enemyFlyer = [_enemyFlyerArray nextSprite];
        [_enemyFlyer stopAllActions];
        _enemyFlyer.visible = YES;
        _enemyFlyer2 = [_enemyFlyerArray nextSprite];
        [_enemyFlyer2 stopAllActions];
        _enemyFlyer2.visible = YES;
        _enemyFlyer3 = [_enemyFlyerArray nextSprite];
        [_enemyFlyer3 stopAllActions];
        _enemyFlyer3.visible = YES;
        _enemyFlyer4 = [_enemyFlyerArray nextSprite];
        [_enemyFlyer4 stopAllActions];
        _enemyFlyer4.visible = YES;
        
        _enemyFlyer5 = [_enemyFlyerArray nextSprite];
        [_enemyFlyer5 stopAllActions];
        _enemyFlyer5.visible = YES;
        _enemyFlyer6 = [_enemyFlyerArray nextSprite];
        [_enemyFlyer6 stopAllActions];
        _enemyFlyer6.visible = YES;
        _enemyFlyer7 = [_enemyFlyerArray nextSprite];
        [_enemyFlyer7 stopAllActions];
        _enemyFlyer7.visible = YES;
        _enemyFlyer8 = [_enemyFlyerArray nextSprite];
        [_enemyFlyer8 stopAllActions];
        _enemyFlyer8.visible = YES;
        
        
        // Set its position to be offscreen to the right
        _enemyFlyer.position = ccp(winSize.width+_enemyFlyer.contentSize.width/2, randY);
        _enemyFlyer2.position = ccp(winSize.width+_enemyFlyer.contentSize.width/2, randY);
        _enemyFlyer3.position = ccp(winSize.width+_enemyFlyer.contentSize.width/2, randY);
        _enemyFlyer4.position = ccp(winSize.width+_enemyFlyer.contentSize.width/2, randY);
        
        _enemyFlyer5.position = ccp(winSize.width+_enemyFlyer.contentSize.width/2, winSize.height - randY);
        _enemyFlyer6.position = ccp(winSize.width+_enemyFlyer.contentSize.width/2, winSize.height - randY);
        _enemyFlyer7.position = ccp(winSize.width+_enemyFlyer.contentSize.width/2, winSize.height - randY);
        _enemyFlyer8.position = ccp(winSize.width+_enemyFlyer.contentSize.width/2, winSize.height - randY);
        
        
        _enemyFlyer.scale = 1.2;
        _enemyFlyer.maxHp = 10;
        _enemyFlyer2.scale = 1.2;
        _enemyFlyer2.maxHp = 10;
        _enemyFlyer3.scale = 1.2;
        _enemyFlyer3.maxHp = 10;
        _enemyFlyer4.scale = 1.2;
        _enemyFlyer4.maxHp = 10;
        
        _enemyFlyer5.scale = 1.2;
        _enemyFlyer5.maxHp = 10;
        _enemyFlyer6.scale = 1.2;
        _enemyFlyer6.maxHp = 10;
        _enemyFlyer7.scale = 1.2;
        _enemyFlyer7.maxHp = 10;
        _enemyFlyer8.scale = 1.2;
        _enemyFlyer8.maxHp = 10;
        
        [_enemyFlyer revive];
        [_enemyFlyer2 revive];
        [_enemyFlyer3 revive];
        [_enemyFlyer4 revive];
        
        [_enemyFlyer5 revive];
        [_enemyFlyer6 revive];
        [_enemyFlyer7 revive];
        [_enemyFlyer8 revive];
        
        
        [_enemyFlyer runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration:2
                              position:ccp(winSize.width*.7, winSize.height * .2)],
        nil]];
        [_enemyFlyer2 runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration:2
                              position:ccp((winSize.width+100)*.7 , (winSize.height+375) * .2)],
          nil]];
        [_enemyFlyer3 runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration:2
                              position:ccp((winSize.width+100)*.7, (winSize.height-375) * .2)],
          nil]];
        [_enemyFlyer4 runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration:2
                              position:ccp((winSize.width+200)*.7, winSize.height * .2)],
          nil]];
        
        [_enemyFlyer5 runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration:2
                              position:ccp((winSize.width)*.7, winSize.height * .8)],
          nil]];
        [_enemyFlyer6 runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration:2
                              position:ccp((winSize.width+100)*.7, (winSize.height+100)* .8)],
          nil]];
        [_enemyFlyer7 runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration:2
                              position:ccp((winSize.width+100)*.7, (winSize.height-100) * .8)],
          nil]];
        [_enemyFlyer8 runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration:2
                              position:ccp((winSize.width+200)*.7, winSize.height * .8)],
          nil]];
        
        
        //Animate this enemy ship
        CCSpriteFrameCache * cache =
        [CCSpriteFrameCache sharedSpriteFrameCache];
        
        CCAnimation *animation = [CCAnimation animation];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"foe3.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"foe4.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"foe5.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"foe6.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"foe5.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"foe4.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"foe3.png"]];
        animation.delayPerUnit = 0.2;
        
        [_enemyFlyer runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [_enemyFlyer2 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [_enemyFlyer3 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [_enemyFlyer4 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        
        [_enemyFlyer5 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [_enemyFlyer6 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [_enemyFlyer7 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        [_enemyFlyer8 runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        
        //Enemies shoot
        [self schedule:@selector(handleTimer) interval:2.5];
        
    }
}

- (void)handleTimer {
    [self shootEnemyLaserFromPosition:_enemyFlyer.position];
    [self shootEnemyLaserFromPosition:_enemyFlyer2.position];
    [self shootEnemyLaserFromPosition:_enemyFlyer3.position];
    [self shootEnemyLaserFromPosition:_enemyFlyer4.position];
    [self shootEnemyLaserFromPosition:_enemyFlyer5.position];
    [self shootEnemyLaserFromPosition:_enemyFlyer6.position];
    [self shootEnemyLaserFromPosition:_enemyFlyer7.position];
    [self shootEnemyLaserFromPosition:_enemyFlyer8.position];
    
}

-(void)handleTimerOff
{
    _timerLasers++;
    if(_timerLasers == 8){
        [self unschedule:@selector(handleTimer)];
        _timerLasers = 0;
        _wantNextStage = YES;
    }
}

- (void)invisNode:(GameObject *)sender {
    [sender destroy];
}

/*******************************************************************************
 * @method      updateCollisions
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This loops through each laser, and each enemy, and checks if their bounding
 boxes collide (and both are visible).
 If so, it plays an explosion sound effect, and makes both of them invisible to
 “destroy” them.
 *******************************************************************************/
- (void)updateCollisions:(ccTime)dt {
    
    /* OLD CODE
    
    for (CCSprite *laser in _laserArray.array) {
        if (!laser.visible) continue;
        
        for (CCSprite *enemy in _enemysArray.array) {
            if (!enemy.visible) continue;
            if (CGRectIntersectsRect(enemy.boundingBox, laser.boundingBox)) {
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf" pitch:1.0f pan:0.0f gain:0.25f];
                enemy.visible = NO;
                laser.visible = NO;
                break;
            }
        }
        for (CCSprite *enemyFlyer in _enemyFlyerArray.array) {
            if (!enemyFlyer.visible) continue;
            if (CGRectIntersectsRect(enemyFlyer.boundingBox, laser.boundingBox)) {
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf" pitch:1.0f pan:0.0f gain:0.25f];
                enemyFlyer.visible = NO;
                laser.visible = NO;
                break;
                [self handleTimerOff];
            }
        }
    }
     */
    
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

//updateLevel calls update each frame, and if it returns TRUE (which means a new stage
//has started) it calls newStageStarted.
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

/*******************************************************************************
 * @method      spawnBoss
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This creates the boss offscreen to the upper right, calls revive on the boss,
 shakes the screen a good bit, and plays a sound effect.
 *******************************************************************************/
- (void)spawnBoss {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _boss.position = ccp(winSize.width*1.2,
                         winSize.height*1.2);
    
    [_boss revive];
    
    [self shakeScreen:30];
    [[SimpleAudioEngine sharedEngine]
     playEffect:@"boss.caf"];
}

-(void)spawnBigTurret
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _bigTurret.position = ccp(winSize.width*1.2,
                         winSize.height*1.2);
    
    [_bigTurret revive];
    
    [self shakeScreen:30];
    [[SimpleAudioEngine sharedEngine]
     playEffect:@"boss.caf"];
}

//newStageStarted checks to see if the game has advanced to the GameStateDone state,
//and if so calls the endScene method to display the Game Over text and Restart menu.
- (void)newStageStarted {
    if (_levelManager.gameState == GameStateDone) {
        [self endScene:YES];
    }
    else if ([_levelManager boolForProp:@"SpawnLevelIntro"]) {
        [self doLevelIntro];
    }
    if ([_levelManager boolForProp:@"SpawnBoss"]) {
        [self spawnBoss];
    }
    if ([_levelManager boolForProp:@"SpawnBigTurret"]){
        [self spawnBigTurret];
    }
    
    
}

- (void)doLevelIntro {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message1 = [NSString stringWithFormat:@"Level %d",
                          _levelManager.curLevelIdx+1];
    NSString *message2 = [_levelManager stringForProp:@"LText"];
    
    NSString *message3 = [_levelManager stringForProp:@"LText"];
    
    _levelIntroLabel1 = [CCLabelBMFont labelWithString:message1
                                               fntFile:@"SpaceGameFont.fnt"];
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
    
    _levelIntroLabel2 = [CCLabelBMFont labelWithString:message2
                                               fntFile:@"SpaceGameFont.fnt"];
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
    
    
    _tutorialItem = [CCLabelBMFont labelWithString:message3
                                               fntFile:@"SpaceGameFont.fnt"];
    _tutorialItem.position = ccp(winSize.width/2, winSize.height * 0.8);
    _tutorialItem.scale = 0;
    [self addChild:_tutorialItem z:100];
    
    [_tutorialItem runAction:
     [CCSequence actions:
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:0.5] rate:4.0],
      [CCDelayTime actionWithDuration:3.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:0] rate:4.0],
      [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
      nil]];
}

- (void)shootEnemyLaserFromPosition:(CGPoint)position {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *shipLaser = [_enemyLasers nextSprite];
    
    
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"laser_enemy.caf" pitch:1.0f pan:0.0f gain:0.25f];
    shipLaser.position = position;
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
}

- (void)shootEnemyVerticalDownLaserFromPosition:(CGPoint)position {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *shipLaser = [_enemyLasers nextSprite];
    
    
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"laser_enemy.caf" pitch:1.0f pan:0.0f gain:0.25f];
    shipLaser.position = position;
    shipLaser.rotation = 90;
    [shipLaser revive];
    [shipLaser stopAllActions];
    [shipLaser runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2.2
                          position:ccp(0, -winSize.height)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
}

- (void)shootEnemyVerticalUpLaserFromPosition:(CGPoint)position {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    GameObject *shipLaser = [_enemyLasers nextSprite];
    
    
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"laser_enemy.caf" pitch:1.0f pan:0.0f gain:0.25f];
    shipLaser.position = position;
    shipLaser.rotation = 90;
    [shipLaser revive];
    [shipLaser stopAllActions];
    [shipLaser runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:2.2
                          position:ccp(0, winSize.height)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
}


/*******************************************************************************
 * @method      updateAlienSwarm
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This code takes the following strategy:
 •  Each “wave” of aliens, you’ll choose a random number of aliens to spawn in
 the wave between 1 and 20 and will figure out their path they should move in by
 choosing four random points:
 -pos1: Create a point offscreen (x-axis) in the top half of the screen
 (y-axis).
 -cp1: Create a point on the left side of the screen (x-axis), in the top
 fourth (y-axis).
 -pos2: Create a point offscreen (x-axis) in the bottom half of the screen
 (y-axis).
 -cp2: Create a point on the left side of the screen (x-axis), in the
 bottom fourth (y-axis).
 •	These points construct a bezier curve. Sets the start to pos1, the end to pos2,
 and the two control points to cp1 and cp2, the aliens will spawn offscreen to
 the top right, curve toward the middle of the screen, and go back out to the
 right. Reversed pos1/pos2 and the control points, they’ll go bottom to
 top instead.
 •	Choose a random number so half the time the aliens spawn bottom to top,
 and half the time top to bottom.
 •	Every time an alien wave spawns, it gets the next available alien sprite and
 run an action to move it along the pre-created Bezier curve.
 *******************************************************************************/
- (void)updateAlienSwarm:(ccTime)dt
{
    
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnAlienSwarm"])
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

/*******************************************************************************
 * @method      updatePowerupBolt
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This checks to see when it’s time to spawn a power up, and when it’s time it
 grabs the next available power up and moves it offscreen to the left.
 *******************************************************************************/
- (void)updatePowerupBolt:(ccTime)dt {
    
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnPowerupBolt"])
        return;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    double curTime = CACurrentMediaTime();
    if (curTime > _nextPowerupBoltSpawn) {
        _nextPowerupBoltSpawn = curTime +
        [_levelManager floatForProp:@"PBoltSpawnSecs"];
        
        GameObject * powerup = [_powerupBolt nextSprite];
        powerup.position = ccp(winSize.width + 200,
                               randomValueBetween(0, winSize.height));
                               //winSize.height/2);
        [powerup revive];
        [powerup runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:20],
          [CCCallFuncN actionWithTarget:self
                               selector:@selector(invisNode:)],
          nil]];
        
        CCSpriteFrameCache * cache =
        [CCSpriteFrameCache sharedSpriteFrameCache];
        
        CCAnimation *animation = [CCAnimation animation];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"powerup.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"powerup2.png"]];
        animation.delayPerUnit = 0.2;
        
        [powerup runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        
        id move1 = [CCMoveBy
                    actionWithDuration:.5 position:ccp(-50, -8)];
        id move2 = [CCMoveBy
                    actionWithDuration:.5 position:ccp(-50, 8)];
        id move3 =  [CCMoveBy
                     actionWithDuration:.5 position:ccp(-50, 8)];
        id move4 =  [CCMoveBy
                     actionWithDuration:.5 position:ccp(-50, -8)];
        id shake = [CCSequence actions:move1, move2, move3, move4, nil];
        CCRepeat* shakeAction = [CCRepeat
                                 actionWithAction:shake times:-1];
        
        [powerup runAction:shakeAction];

        
    }
    
}

- (void)updateBoostEffects:(ccTime)dt {
    for (CCParticleSystemQuad * particleSystem in _boostEffects.array) {
        particleSystem.position = _ship.position;
    }
}

/*******************************************************************************
 * @method      updatePowerupMultiple
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This checks to see when it’s time to spawn a power up, and when it’s time it
 grabs the next available power up and moves it offscreen to the left.
 *******************************************************************************/
- (void)updatePowerupMultiple:(ccTime)dt {
    
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnPowerupMultiple"])
        return;
    if (_multiple) return;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    double curTime = CACurrentMediaTime();
    if (curTime > _nextPowerupMultipleSpawn) {
        _nextPowerupMultipleSpawn = curTime +
        [_levelManager floatForProp:@"PMultipleSpawnSecs"];
        
        GameObject * powerup = [_powerupMultiple nextSprite];
        powerup.position = ccp(winSize.width + 200,
                               randomValueBetween(0, winSize.height));
        //winSize.height/2);
        [powerup revive];
        [powerup runAction:
         [CCSequence actions:
          [CCMoveBy actionWithDuration:20],
          [CCCallFuncN actionWithTarget:self
                               selector:@selector(invisNode:)],
          nil]];
        
        CCSpriteFrameCache * cache =
        [CCSpriteFrameCache sharedSpriteFrameCache];
        
        CCAnimation *animation = [CCAnimation animation];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"multiple1.png"]];
        [animation addSpriteFrame:
         [cache spriteFrameByName:@"multiple2.png"]];
        animation.delayPerUnit = 0.2;
        
        [powerup runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:animation]]];
        
        id move1 = [CCMoveBy
                    actionWithDuration:.5 position:ccp(-50, -8)];
        id move2 = [CCMoveBy
                    actionWithDuration:.5 position:ccp(-50, 8)];
        id move3 =  [CCMoveBy
                     actionWithDuration:.5 position:ccp(-50, 8)];
        id move4 =  [CCMoveBy
                     actionWithDuration:.5 position:ccp(-50, -8)];
        id shake = [CCSequence actions:move1, move2, move3, move4, nil];
        CCRepeat* shakeAction = [CCRepeat
                                 actionWithAction:shake times:-1];
        
        [powerup runAction:shakeAction];
        
        
    }
    
}

/*******************************************************************************
 * @method      updateBoss
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This method bails if it’s not in a normal stage with the spawn boss flag—but if
 it is (and the boss is visible) it calls the boss’s update method.
 *******************************************************************************/
- (void)updateBoss:(ccTime)dt {
    
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnBoss"]) return;
    
    if (_boss.visible) {
        [_boss updateWithShipPosition:_ship.position];
    }
}

- (void)updateBigTurret:(ccTime)dt {
    
    if (_levelManager.gameState != GameStateNormal) return;
    if (![_levelManager boolForProp:@"SpawnBigTurret"]) return;
    
    if (_bigTurret.visible) {
        [_bigTurret updateWithShipPosition:_ship.position];
    }
}



- (void)update:(ccTime)dt
{
    //sets ships possition
    [self updateShipPos:dt];
    //sets enemy possition
    [self updateEnemy:dt];
    [self updateEnemyFlyer:dt];
    //checks for collisions
    //[self updateCollisions:dt];
    //move the background
    [self updateBackground:dt];
    [self updateBox2D:dt];
    //Checks to see if you won by timer (old)
    //if (CACurrentMediaTime() > _gameWonTime) {
    //    [self endScene:YES];
    //}
    [self updateLevel:dt];
    [self updateAlienSwarm:dt];
    [self updatePowerupBolt:dt];
    [self updatePowerupMultiple:dt];
    [self updateBoostEffects:dt];
    [self updateBoss:dt];
    
}


/*******************************************************************************
 * @method      setupArrays
 * @abstract    <# abstract #>
 * @description  This creates an array of X number of enemies.
 *******************************************************************************/
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
                                        spriteFrameName:@"enemy_spaceship.png"
                                              batchNode:_batchNode
                                                  world:_world
                                              shapeName:@"enemy_spaceship"
                                                  maxHp:1
                                          healthBarType:HealthBarTypeNone];
    
    //sets up array of enemy lasers
    _enemyLasers = [[SpriteArray alloc] initWithCapacity:100
                                         spriteFrameName:@"laserbeam_red.png"
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
    _cannonBalls = [[SpriteArray alloc] initWithCapacity:5
                                         spriteFrameName:@"Boss_cannon_ball.png"
                                               batchNode:_batchNode
                                                   world:_world
                                               shapeName:@"Boss_cannon_ball"
                                                   maxHp:1
                                           healthBarType:HealthBarTypeNone];
    
    //sets up enemy Flyer
    _enemyFlyerArray = [[SpriteArray alloc] initWithCapacity:8
                                             spriteFrameName:@"foe1.png"
                                                   batchNode:_batchNode
                                                       world:_world
                                                   shapeName:@"enemy_spaceship"
                                                       maxHp:10
                                               healthBarType:HealthBarTypeRed];
    
}

/*******************************************************************************
 * @method      shootCannonBallAtShipFromPosition
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This method takes the position where the cannon is shooting from, but this method
 needs to figure out where to shoot the cannon ball to—and how fast to move it.
 It first figures out the vector between the ship position and the cannon’s
 position by subtracting the two. It also makes the vector’s length 1.
 In the next line we make the vector two times the width of the window, so were
 sure the cannon ball moves far enough to be offscreen.
 Since the cannon ball moves the same distance each time this method is called
 (just in different directions), it moves at a set number of seconds each time
 and it will always move at the same speed.
 *******************************************************************************/
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

/*******************************************************************************
 * @method      touchesBegan & weapon methods
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 1)This plays a laser sound effect when the user taps, gets the next available
 laser sprite, stops any running actions, and sets it to visible.
 2)Sets its position to be to the right of the space ship, and runs an
 action to move it the entire width of the screen to the right. This means it
 will overshoot the edge of the screen.
 3)When the laser is done moving, it calls invisNode passing itself as a parameter
 so it will be set to invisible.
 *******************************************************************************/
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Prevent the laser from shooting before Play.
    if (_ship == nil || _ship.dead) return;
    
    
    [self beginFire];
    _firing = YES;
    
    
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

-(void)shootSingle
{
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


/*******************************************************************************
 * @method     setupBackground
 * @abstract    Uses parallax scrolling!
 * @description
 -------------------------------------------------------------------------------
 Parallax Scrolling:
 1.	Create a CCParallaxNode, and add it to the layer.
 2.	Create items to scroll, and add them to the CCParallaxNode with
 addChild:parallaxRatio:positionOffset.
 3.	Move the CCParallaxNode to scroll the background. It will scroll the children
 of the CCParallaxNode more quickly or slowly based on the parallaxRatio to.
 *******************************************************************************/
- (void)setupBackground {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // 1) Create the CCParallaxNode
    _backgroundNode = [CCParallaxNode node];
    [self addChild:_backgroundNode z:-2];
    
    // 2) Create the sprites to add to the CCParallaxNode
    //_spacedust1 = [CCSprite spriteWithFile:@""];
    //_spacedust2 = [CCSprite spriteWithFile:@""];
    //_planetsunrise = [CCSprite spriteWithFile:@"bg_planetsunrise.png"];
    //_galaxy = [CCSprite spriteWithFile:@"bg_galaxy.png"];
    //_spacialanomaly = [CCSprite spriteWithFile:@"bg_spacialanomaly.png"];
    //_spacialanomaly2 = [CCSprite spriteWithFile:@"bg_spacialanomaly2.png"];
    
    // 3) Determine relative movement speeds for space dust and background
    CGPoint dustSpeed = ccp(0.009, 0.009);
    CGPoint bgSpeed = ccp(0.05, 0.05);
    
    // 4) Add children to CCParallaxNode
    //[_backgroundNode addChild:_spacedust1 z:0
    //            parallaxRatio:dustSpeed
    //           positionOffset:ccp(0,winSize.height/2)];
    //[_backgroundNode addChild:_spacedust2 z:0
    //            parallaxRatio:dustSpeed
    //           positionOffset:ccp(_spacedust1.contentSize.width*
    //                              _spacedust1.scale, winSize.height/2)];
    //[_backgroundNode addChild:_galaxy z:-1
    //            parallaxRatio:bgSpeed
    //           positionOffset:ccp(0,winSize.height * 0.7)];
    //[_backgroundNode addChild:_planetsunrise z:-1
    //            parallaxRatio:bgSpeed
    //           positionOffset:ccp(600,winSize.height * 0)];
    //[_backgroundNode addChild:_spacialanomaly z:-1
    //            parallaxRatio:bgSpeed
    //           positionOffset:ccp(900,winSize.height * 0.3)];
    //[_backgroundNode addChild:_spacialanomaly2 z:-1
    //            parallaxRatio:bgSpeed
    //           positionOffset:ccp(1500,winSize.height * 0.9)];
}

- (void)updateBackground:(ccTime)dt {
    //CGPoint backgroundScrollVel = ccp(-1000, 0);
    //_backgroundNode.position =
    //ccpAdd(_backgroundNode.position,
    //       ccpMult(backgroundScrollVel, dt));
}

/*******************************************************************************
 * @method     setupWorld
 * @abstract    Uses parallax scrolling!
 * @description
 -------------------------------------------------------------------------------
 Sets up the Box2D world to have no gravity. This is the physics engine.
 *******************************************************************************/
- (void)setupWorld {
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    _world = new b2World(gravity);
    //initialize and register the collision handler
    _contactListener = new SimpleContactListener(self);
    _world->SetContactListener(_contactListener);
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
                if (enemyShip == _boss || enemyShip == _bigTurret) {
                    _wantNextStage = YES;
                    if(enemyShip == _bigTurret){
                        [_bigTurret turretDead];
                    }
                    
                }
                if(enemyShip == _enemyFlyer || enemyShip == _enemyFlyer2 || enemyShip == _enemyFlyer3 ||
                   enemyShip == _enemyFlyer4 || enemyShip == _enemyFlyer5 || enemyShip == _enemyFlyer6 ||
                   enemyShip == _enemyFlyer7 || enemyShip == _enemyFlyer8){
                    [self handleTimerOff];
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
            
            if(enemyShip == _enemyFlyer || enemyShip == _enemyFlyer2 || enemyShip == _enemyFlyer3 ||
               enemyShip == _enemyFlyer4 || enemyShip == _enemyFlyer5 || enemyShip == _enemyFlyer6 ||
               enemyShip == _enemyFlyer7 || enemyShip == _enemyFlyer8){
                [self handleTimerOff];
            }
            
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
            _powerupSingle++;
            
            /*******************************************************************************
             This marks the ship as invincible and starts up a particle system. It then moves
             the ship forward by 60% of the screen width, waits 5 seconds, then moves back.
             *******************************************************************************/
            float scaleDuration = 1.0;
            float waitDuration = 5.0;
            _invincible = YES;
            CCParticleSystemQuad *boostEffect = [_boostEffects nextParticleSystem];
            [boostEffect resetSystem];
            
            [_ship runAction:
             [CCSequence actions:
              [CCMoveBy actionWithDuration:scaleDuration position:ccp(winSize.width * 0.5, 0)],
              [CCDelayTime actionWithDuration:waitDuration],
              [CCMoveBy actionWithDuration:scaleDuration position:ccp(-winSize.width * 0.5, 0)],
              nil]];
            
            [self runAction:
             [CCSequence actions:
              [CCScaleTo actionWithDuration:scaleDuration scale:0.6],
              [CCDelayTime actionWithDuration:waitDuration],
              [CCScaleTo actionWithDuration:scaleDuration scale:.8],
              [CCCallFunc actionWithTarget:self selector:@selector(boostDone)],
              nil]];
        }
    }
    
    /*******************************************************************************
     Collision between ship and multiplelaser powerup
     *******************************************************************************/

    if ((fixtureA->GetFilterData().categoryBits & kCategoryShip && fixtureB->GetFilterData().categoryBits & kCategoryPowerupMultiple) ||
        (fixtureB->GetFilterData().categoryBits & kCategoryShip && fixtureA->GetFilterData().categoryBits & kCategoryPowerupMultiple)) {
        
        // Determine power up
        GameObject *powerUp = (GameObject*) spriteA;
        if (fixtureB->GetFilterData().categoryBits & kCategoryPowerupMultiple) {
            powerUp = spriteB;
        }
        
        if (!powerUp.dead) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.caf" pitch:1.0 pan:0.0 gain:1.0];
            
            [powerUp destroy];
            // TODO: Make the powerup do something!
            _single = NO;
            _multiple = YES;
            if(_firing){
            [self  beginFire];
            }
        }
    }
    
    
    
}

- (void)boostDone
{
    _invincible = NO;
    for (CCParticleSystemQuad * boostEffect in _boostEffects.array) {
        [boostEffect stopSystem];
    }
}

- (void)endContact:(b2Contact *)contact {
    
}

/*******************************************************************************
 * @method     shakeScreen
 * @abstract
 * @description
 -------------------------------------------------------------------------------
 This is a simple method that quickly moves the entire layer down 5 pixels,
 then up 10 pixels, then back down 5 pixels to the original position. It also
 repeats this as many times as is specified in the input parameter.
 *******************************************************************************/
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

/*******************************************************************************
 * @method     setupDebugDraw
 * @abstract    Uses parallax scrolling!
 * @description
 -------------------------------------------------------------------------------
 This creates the class to perform Box2D debug drawing to see a representation
 in the Cocos2D world of what’s in the Box2D world.
 *******************************************************************************/
- (void)setupDebugDraw {
    _debugDraw = new GLESDebugDraw(PTM_RATIO);
    //_world->SetDebugDraw(_debugDraw);
    _debugDraw->SetFlags(b2Draw::e_shapeBit | b2Draw::e_jointBit);
}

/*******************************************************************************
 * @method     testBox2D
 * @abstract    Uses parallax scrolling!
 * @description
 -------------------------------------------------------------------------------
 This code performs the basic steps to take to add an object to the Box2D world:
 1.	Create a body definition, specifying the type of the body and its position.
 2.	Tell the Box2D world to create a body, passing in the body definition.
 3.	Create a shape, specifying its size or vertices. In this case, a simple
 circle shape, set its radius to a fixed size in Box2D units.
 4.	Create a fixture definition, specifying parameters on the shape such as
 density (the higher the density the harder an object is to move), friction,
 or restitution (how bouncy an object is).
 5.	Tell the Box2D body to create a fixture, passing in the fixture definition.
 
 *******************************************************************************/
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

-(void)setupBigTurret
{
    _bigTurret = [[BigTurret alloc] initWithWorld:_world layer:self];
    _bigTurret.visible = NO;
    [_batchNode addChild:_bigTurret];
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
        
        //This sets the _gameWonTime variable to 30 seconds in the future. (old style)
        //Sets up LevelManager to keep track of the levels (new)
        //double curTime = CACurrentMediaTime();
        //_gameWonTime = curTime + 30.0;
        [self setupLevelManager];
        [self setupBoss];
        [self setupBigTurret];
        
        [self runAction:
         [CCSequence actions:
          [CCScaleTo actionWithDuration:1 scale:0.8],
          nil]];
        
    }
    return self;
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