//
//  MGLMapViewExt.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/22/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import Mapbox

extension MGLMapView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //next?.touchesBegan(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        //next?.touchesMoved(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        //next?.touchesEnded(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        //next?.touchesCancelled(touches, with: event)
    }
    
    open override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        super.touchesEstimatedPropertiesUpdated(touches)
        
        //next?.touchesEstimatedPropertiesUpdated(touches)
    }
}
