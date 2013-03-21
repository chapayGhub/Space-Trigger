//
//  HUDLayer.m
//  SpaceGame
//
//  Created by JRamos on 3/2/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "HUDLayer.h"
#import "ActionLayer.h"

@implementation HUDLayer{
    
}


- (id)init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"SpaceGameFont.fnt"];
            _scoreLabel.scale = .25;
            _scoreLabelScore = [CCLabelBMFont labelWithString:@"" fntFile:@"SpaceGameFont.fnt"];
            _scoreLabelScore.scale = .25;
        } else {
            _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"SpaceGameFont.fnt"];
            _scoreLabel.scale = .25;
            _scoreLabelScore = [CCLabelBMFont labelWithString:@"" fntFile:@"SpaceGameFont.fnt"];
            _scoreLabelScore.scale = .25;
        }
        _scoreLabel.position = ccp(winSize.width/1.88, winSize.height *.95);
        _scoreLabelScore.position = ccp(winSize.width/2.15, winSize.height *.95);
        [self addChild:_scoreLabel z:1];
        [self addChild:_scoreLabelScore z:1];
    }
    return self;
}

- (void)setScoreLabel:(NSString *)string{
    [_scoreLabel runAction:
     [CCSequence actions:
      [CCScaleTo actionWithDuration:.05 scale:0.45],
      [CCScaleTo actionWithDuration:.05 scale:.25], nil]];
    _scoreLabel.string = string;
    
}

- (void)setScoreLabelScore:(NSString *)string{
    
    _scoreLabelScore.string = string;
    
}

- (CCLabelBMFont*)getScoreLabel
{
    return _scoreLabel;
}

@end
