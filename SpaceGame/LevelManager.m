//
//  LevelManager.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/24/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "LevelManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation LevelManager {
    double _stageStart;
    double _stageDuration;
    
    NSDictionary * _data;
    NSArray * _levels;
    int _curLevelIdx;
    NSArray * _curStages;
    int _curStageIdx;
    NSDictionary * _curStage;
}

- (id)init {
    if ((self = [super init])) {
        
        NSString *levelDefsFile = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
        _data = [NSDictionary dictionaryWithContentsOfFile:levelDefsFile];
        NSAssert(_data != nil, @"Couldn't open Levels file");
        
        _levels = (NSArray *) _data[@"Levels"];
        NSAssert(_levels != nil, @"Couldn't find Levels entry");
        
        _curLevelIdx = -1;
        _curStageIdx = -1;
        _gameState = GameStateTitle;
        
    }
    return self;
}

- (int)curLevelIdx {
    return _curLevelIdx;
}

- (BOOL)hasProp:(NSString *)prop {
    NSString * retval =  (NSString *) _curStage[prop];
    return retval != nil;
}

- (NSString *)stringForProp:(NSString *)prop {
    NSString * retval =  (NSString *) _curStage[prop];
    NSAssert(retval != nil, @"Couldn't find prop %@", prop);
    return retval;
}

- (float)floatForProp:(NSString *)prop {
    NSNumber * retval = (NSNumber *) _curStage[prop];
    NSAssert(retval != nil, @"Couldn't find prop %@", prop);
    return retval.floatValue;
}

- (BOOL)boolForProp:(NSString *)prop {
    NSNumber * retval =  (NSNumber *) _curStage[prop];
    if (!retval) return FALSE;
    return [retval boolValue];
}

- (void)nextLevel {
    _curLevelIdx++;
    if (_curLevelIdx >= _levels.count) {
        _gameState = GameStateDone;
        return;
    }
    _curStages = (NSArray *) _levels[_curLevelIdx];
    [self nextStage];
}

- (void)nextStage {
    _curStageIdx++;
    if (_curStageIdx >= _curStages.count) {
        _curStageIdx = -1;
        [self nextLevel];
        return;
    }
    
    _gameState = GameStateNormal;
    _curStage = _curStages[_curStageIdx];
    
    _stageDuration = [self floatForProp:@"Duration"];
    _stageStart = CACurrentMediaTime();
    
    NSLog(@"Stage ending in: %f", _stageDuration);
    
}

- (BOOL)update {
    if (_gameState == GameStateTitle ||
        _gameState == GameStateDone) return FALSE;
    if (_stageDuration == -1) return FALSE;
    
    double curTime = CACurrentMediaTime();
    if (curTime > _stageStart + _stageDuration) {
        [self nextStage];
        return TRUE;
    }
    
    return FALSE;
}

@end
