//
//  HUDLayer.h
//  SpaceGame
//
//  Created by JRamos on 3/2/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HUDLayer : CCLayer
{
    CCLabelBMFont * _scoreLabel;
    CCLabelBMFont *_scoreLabelScore;
}

- (void)setScoreLabel:(NSString *)string;
- (void)setScoreLabelScore:(NSString *)string;
- (CCLabelBMFont*)getScoreLabel;


@end