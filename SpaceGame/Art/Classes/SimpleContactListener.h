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

class SimpleContactListener : public b2ContactListener {
public:
    ActionLayer *_layer;
    
    SimpleContactListener(ActionLayer *layer) : _layer(layer) { 
    }
    
    void BeginContact(b2Contact* contact) { 
        [_layer beginContact:contact];
    }
                        
    void EndContact(b2Contact* contact) { 
        [_layer endContact:contact];
    }

    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold) { 
    }

    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {  
    }

};
