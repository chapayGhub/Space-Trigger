//
//  Common.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/23/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "Common.h"

float randomValueBetween(float low, float high) {
    return (((float) arc4random() / 0xFFFFFFFFu)
            * (high - low)) + low;
}
