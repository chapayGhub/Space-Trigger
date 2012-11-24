//
//  LevelManager.h
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/24/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GameStateTitle = 0,
    GameStateNormal,
    GameStateDone
} GameState;

@interface LevelManager : NSObject

@property (assign) GameState gameState;

- (int)curLevelIdx;
- (void)nextStage;
- (void)nextLevel;
- (BOOL)update;
- (float)floatForProp:(NSString *)prop;
- (NSString *)stringForProp:(NSString *)prop;
- (BOOL)boolForProp:(NSString *)prop;
- (BOOL)hasProp:(NSString *)prop;

@end
