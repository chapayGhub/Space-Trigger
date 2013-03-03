//
//  HUDLayer.m
//  SpaceGame
//
//  Created by JRamos on 3/2/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "HUDLayer.h"
#import "ActionLayer.h"

@implementation HUDLayer


- (id)init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"SpaceGameFont.fnt"];
            _scoreLabel.scale = .2;
        } else {
            _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"SpaceGameFont.fnt"];
            _scoreLabel.scale = .2;
        }
        _scoreLabel.position = ccp(winSize.width *.9, winSize.height *.95);
        [self addChild:_scoreLabel z:1];
    }
    return self;
}

- (void)setScoreLabel:(NSString *)string{
    _scoreLabel.string = string;
}

- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    //CCScene *scene = [ActionLayer scene];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:scene]];
    
}

- (void)showRestartMenu:(BOOL)won {
    
  /*
   CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    if (won) {
        message = @"You win!";
    } else {
        message = @"You lose!";
    }
    
    CCLabelBMFont *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial-hd.fnt"];
    } else {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial.fnt"];
    }
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial-hd.fnt"];
    } else {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial.fnt"];
    }
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:10];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
   */
    
}

@end
