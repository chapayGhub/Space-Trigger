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
}

- (void)setScoreLabel:(NSString *)string;


@end