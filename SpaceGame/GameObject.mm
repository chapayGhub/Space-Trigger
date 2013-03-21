//
//  GameObject.mm
//  SpaceBlaster2
//
//  Created by JRamos on 2/22/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "GameObject.h"
#import "ShapeCache.h"

@implementation GameObject
{
    float _hp;
    b2World* _world;
    b2Body* _body;
    NSString *_shapeName;
    
    
    /*******************************************************************************
     _healthBarType keeps track of the type of health bar to display. The health bar
     is made of two sprites—a background sprite (_healthBarBg), and a sprite that
     lies on top, that fills up a portion of the health bar to show how much health
     remains (_healthBarProgress).
     _healthBarProgressFrame is a reference to the sprite frame for the progress
     bar, and finally it also keeps track of the full width of the health bar, and
     the currently displayed portion of the progress (_displayedWidth).
     *******************************************************************************/
    HealthBarType _healthBarType;
    CCSprite * _healthBarBg;
    CCSprite * _healthBarProgress;
    CCSpriteFrame * _healthBarProgressFrame;
    float _fullWidth;
    float _displayedWidth;
}

/*******************************************************************************
 * @method      setupHealthBar
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 This method:
 •	The health bar background is added as a child of the game object. That means
 that as the game object moves, the health bar background will move with it.
 •	The position of the health bar background is with respect to the bottom left
 of the game object. So it centers it along the game object on the x-axis (by
 setting its x-coordinate to half the size of the game object) , and set it
 to show up slightly below the game object on the y-axis.
 •	The health bar progress is added as a child of the health bar background. So
 now it’s position is relative to the background (not the game object)
 •	It also stores away the full width of the texture for later usage and the
 sprite frame of the progress bar.
 *******************************************************************************/
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
    _healthBarProgressFrame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                               spriteFrameByName:progressSpriteName];
    _healthBarProgress = [CCSprite spriteWithSpriteFrameName:progressSpriteName];
    _healthBarProgress.position =
    ccp(_healthBarProgress.contentSize.width/2,
        _healthBarProgress.contentSize.height/2);
    _fullWidth = _healthBarProgress.textureRect.size.width;
    [_healthBarBg addChild:_healthBarProgress];
    
}

/*******************************************************************************
 * @method      update
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 •  The update method first bails if there’s no progress bar to display.
 •  It then figures out the ship’s health percentage by dividing the hp by the
 max hp. It restricts this to at least 0% and at most 100%.
 •  It then figures out the desired width of the health bar by multiplying the
 full width of the health bar by the current health percentage.
 •  If the current displayed width is less than or greater than the desired
 width, it incremements or decrements the displayedWidth at a certain rate –
 POINTS_PER_SEC. It uses dt (the delta time elapsed since the last frame) to
 determine the exact number of pixels to increment for this frame.
 *******************************************************************************/
- (void)update:(ccTime)dt {
    
    if (_healthBarType == HealthBarTypeNone) return;
    
    
    float POINTS_PER_SEC = 10;
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
    CGRect newTextureRect = CGRectMake(oldTextureRect.origin.x,
                                       oldTextureRect.origin.y,
                                       _displayedWidth, oldTextureRect.size.height);
    
    [_healthBarProgress setTextureRect:newTextureRect
                               rotated:_healthBarProgressFrame.rotated
                         untrimmedSize:_healthBarProgressFrame.originalSize];
    
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



/*******************************************************************************
 * @method      init
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 initWithSpriteFrameName:world:shapeName:maxHp starts by calling the superclass’s
 (CCSprite) initWithSpriteFrameName method, to initialize the sprite with a
 particular image. It then saves off the parameters for use later.
 *******************************************************************************/
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName world:(b2World *)world shapeName:(NSString *)shapeName maxHp:(float)maxHp healthBarType:(HealthBarType)healthBarType
{
    
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

/*******************************************************************************
 * @method      deatroyBody
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 destroyBody destroys any existing Box2D body. It will destroy the Box2D body
 whenever it isn’t needed, to conserve resources.
 *******************************************************************************/
- (void) destroyBody
{
    if (_body != NULL) {
        _world->DestroyBody(_body);
        _body = NULL;
    }
}

/*******************************************************************************
 * @method      createBody
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 createBody creates a new Box2D body to associate to the sprite. It sets its
 position to the sprites current position, and sets the spite as the user data
 of the Box2D body (so that we can easily get access to the sprite). To create
 the shapes, it uses some helper code called the ShapeCache, which reads the file
 exported by Physics Editor to add the appropriate shapes to the Box2D body along
 with their parameters set up in the tool. It is needed to add the line to set
 the anchor point of the sprite based on the values set up in Physics Editor.
 Otherwise, sprites may not match up right to the shapes.
 *******************************************************************************/
- (void) createBody
{
    
    [self destroyBody];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(self.position.x/PTM_RATIO,
                         self.position.y/PTM_RATIO);
    bodyDef.userData = (__bridge void *) self;
    _body = _world->CreateBody(&bodyDef);
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [[ShapeCache sharedShapeCache] addFixturesToBody:_body forShapeName:_shapeName scale:self.scale];
    } else {
        [[ShapeCache sharedShapeCache] addFixturesToBody:_body forShapeName:_shapeName scale:self.scale *.5];
    }
    
    [self setAnchorPoint:[[ShapeCache sharedShapeCache] anchorPointForShape:_shapeName]];
    
}

/*******************************************************************************
 * @method      setNodeInvisible
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 setNodeInvisible will be called whenever an object is destroyed (such as an
 enemy exploding). It simply sets the node to invisible and calls the method
 to destroy the Box2D body.
 *******************************************************************************/
- (void)setNodeInvisible:(CCNode *)sender
{
    sender.position = CGPointZero;
    sender.visible = NO;
    [self destroyBody];
}

/*******************************************************************************
 * @method      revive
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 revive will be called whenever we want to reuse a sprite from the sprite array.
 It basically resets everything. It sets the hp back to the max, stops any
 actions, sets it as fully opaque, and creates a fresh Box2D body.
 *******************************************************************************/
- (void)revive
{
    _hp = _maxHp;
    [self stopAllActions];
    self.visible = YES;
    self.opacity = 255;
    [self createBody];
    _displayedWidth = _fullWidth;
    _healthBarBg.visible = NO;
}

/*******************************************************************************
 * @method      dead
 * @abstract    checks for HP = 0
 * @description
 *******************************************************************************/
- (BOOL)dead
{
    return _hp == 0;
}

/*******************************************************************************
 * @method      revive
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 takeHit is another helper method that subtracts an hp. When the hp reaches 0,
 it calls the destroy method to destroy the shape.
 *******************************************************************************/
- (void)takeHit
{
    if (_hp > 0) {
        _hp--;
    }
    if (_hp == 0) {
        [self destroy];
    }
}

/*******************************************************************************
 * @method      revive
 * @abstract    <# abstract #>
 * @description
 -------------------------------------------------------------------------------
 destroy is a method that instead of just immediately removing the object when
 it’s destroyed, this method makes it fade out first. When the fade out is
 complete, it calls the setNodeInvisible method.
 *******************************************************************************/
- (void)destroy
{
    
    _hp = 0;
    [self stopAllActions];
    [self runAction:
     [CCSequence actions:
      [CCFadeOut actionWithDuration:0.1],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(setNodeInvisible:)],
      nil]];
    
}

-(float)whatHP
{
    return _hp;
}

@end
