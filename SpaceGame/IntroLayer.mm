//
//  IntroLayer.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 11/22/12.
//  Copyright Razeware LLC 2012. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
//#import "HelloWorldLayer.h"
#import "ActionLayer.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    IntroLayer *layer = [IntroLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

//
-(id) init
{
    if( (self=[super init])) {
        
        // ask director for the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background;
        
        /*
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            background = [CCSprite spriteWithFile:@"Default.png"];
            background.rotation = 90;
        } else {
            background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
        }*/
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
                background = [CCSprite spriteWithFile:@"Default-Landscape@2x.png"];
            }
            else {
                background = [CCSprite spriteWithFile:@"Default-Landscape.png"];
            }
        }
        else
        {
            if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
                if ([[UIScreen mainScreen ] bounds].size.height >= 568.0f) {
                    background = [CCSprite spriteWithFile:@"Default-568h@2x.png"];
                } else {
                    background = [CCSprite spriteWithFile:@"Default@2x.png"];
                }
            }
            else {
                background = [CCSprite spriteWithFile:@"Default.png"];
            }
            background.rotation = 90;
        }
        
        background.position = ccp(size.width/2, size.height/2);
        
        // add the label as a child to this Layer
        [self addChild: background];
    }
    
    return self;
}

-(void) onEnter
{
    [super onEnter];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene] ]];
    [[CCDirector sharedDirector] replaceScene:[ActionLayer scene]];
}
@end
