//
//  HighScoreScene.m
//  SpaceGame
//
//  Created by JRamos on 3/3/13.
//  Copyright 2013 Razeware LLC. All rights reserved.
//

#import "HighScoreScene.h"
#import "ActionLayer.h"

@implementation HighScoreScene
{
    CCSprite *_background1;
    CCLabelBMFont *_highScore;
    
    ActionLayer * _layer;
}

+ (id)scene {
    CCScene *scene = [CCScene node];
    
    HighScoreScene *highScoreScene = [HighScoreScene node];
    [scene addChild:highScoreScene z:1];
    
    return scene;
}

-(void)setupTitle
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *fontName = @"SpaceGameFont.fnt";
    
    _highScore = [CCLabelBMFont labelWithString:@"High Scores" fntFile:fontName];
    _highScore.scale = 0;
    _highScore.position = ccp(winSize.width/2, winSize.height * .9);
    [self addChild:_highScore z:100];
    
    [_highScore runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:.8] rate:4.0],
      nil]];
    
    CCLabelBMFont *top = [CCLabelBMFont labelWithString:@"Top 10" fntFile:fontName];
    top.scale = 0;
    top.position = ccp(winSize.width/2, winSize.height * .83);
    [self addChild:top z:100];
    
    [top runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:.5] rate:4.0],
      nil]];
    
    [self drawScores];

}

-(void)drawScores
{
    
    // Get window size
    CGSize winSize = [CCDirector sharedDirector].winSize;

    // Get scores array stored in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Get high scores array from "defaults" object
    NSArray *highScores = [defaults arrayForKey:@"scores"];
    
    // Create a mutable string which will be used to store the score list
    NSMutableString *scoresString = [NSMutableString stringWithString:@""];
    
    // Iterate through array and print out high scores
    for (int i = 0; i < [highScores count]; i++)
    {
        [scoresString appendFormat:@"%i. %i\n", i + 1, [[highScores objectAtIndex:i] intValue]];
    }
    
    CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:scoresString fntFile:@"SpaceGameFont.fnt" width:winSize.width alignment:kCCTextAlignmentCenter];
    scoreLabel.scale = .5;
    scoreLabel.position = ccp(winSize.width/2, -300);
    [self addChild:scoreLabel z:100];
    
    [scoreLabel runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2],
      [CCMoveTo actionWithDuration:2 position:ccp(winSize.width/2, winSize.height*.45)],
      nil]];
    
    [self backButton];
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
    backItem.scale = 1;
    backItem.position = ccp(winSize.width*.2,
                               winSize.height/2);
    
    backItem2.scale = .25;
    backItem2.position = ccp(winSize.width*.2,
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
     [CCTransitionFadeBL transitionWithDuration:2
                                          scene:[ActionLayer scene]]];
    
}

- (void)setupBackground {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _background1 = [CCSprite spriteWithFile:@"background2.png"];
    _background1.scale = .6;
    _background1.position = ccp(winSize.width/2, winSize.height/2);;
    [self addChild:_background1 z:-5];
    
   // [_background1 runAction:
   //  [CCSequence actions:
   //   [CCScaleTo actionWithDuration:10 scale:0.8],
   //   nil]];
    
    id a = [CCScaleTo actionWithDuration:30 scale:.8];
    id b = [CCScaleTo actionWithDuration:30 scale:.6];
    id sequence = [CCSequence actions:a, b, nil];
    CCRepeatForever* zoomAction = [CCRepeat actionWithAction:sequence times:-1];
    
    [_background1 runAction:zoomAction];
    
}


- (id)init
{
    if ((self = [super init])) {
        
        [self setupBackground];
        [self setupTitle];
        
    }
    return self;
}

@end
