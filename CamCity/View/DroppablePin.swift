//
//  DroppablePin.swift
//  CamCity
//
//  Created by Vartan on 8/7/17.
//  Copyright © 2017 Vartan. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    
    //dynamic variables are there to modified the way we need too.
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        
        self.coordinate = coordinate
        self.identifier  = identifier
        super.init()
        
        
    }
    
    
    
    
}
