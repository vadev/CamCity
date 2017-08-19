//
//  Constants.swift
//  CamCity
//
//  Created by Vartan on 8/7/17.
//  Copyright © 2017 Vartan. All rights reserved.
//

import Foundation

let apiKey = "YOUR_FLICKR_API"

 // Function for our Flickr URL
func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
 
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    
    
    
}
    

