//
//  SimpleContactListener.h
//  Fables
//
//  Created by Ray Wenderlich on 2/1/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "ActionLayer.h"
#import "BigBoss.h"

class SimpleContactListener : public b2ContactListener {
public:
    ActionLayer *_layer;
    BigBoss *_layer2;
    
    
    SimpleContactListener(ActionLayer *layer) : _layer(layer) { 
    }
    SimpleContactListener(BigBoss *layer2) : _layer2(layer2) {
    }
    
    void BeginContact(b2Contact* contact) { 
        [_layer beginContact:contact];
        [_layer2 beginContact:contact];
    }
                        
    void EndContact(b2Contact* contact) { 
        [_layer endContact:contact];
        [_layer2 endContact:contact];
    }

    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold) { 
    }

    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {  
    }

};
