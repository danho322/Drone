//
//  BoundaryAnnotation.swift
//  Drone
//
//  Created by Daniel on 11/19/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum BoundaryType: String {
    case Field = "Field"
    case Flight = "Flight"
    case None = "None"
}

class BoundaryAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: BoundaryType = .Field
    let key: String
    let ref: FIRDatabaseReference?
    
    init(coordinate: CLLocationCoordinate2D, key: String = "") {
        self.coordinate = coordinate
        self.key = key
        self.ref = nil
        super.init()
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        let lat = snapshotValue["lat"] as! NSNumber
        let lng = snapshotValue["lng"] as! NSNumber
        coordinate = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lng.doubleValue)
        type = BoundaryType(rawValue: snapshotValue["type"] as! String) ?? .Field
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        let lat = NSNumber(double: coordinate.latitude)
        let lng = NSNumber(double: coordinate.longitude)
        return [
            "lat": lat,
            "lng": lng,
            //"title": title,
            //"subtitle": subtitle,
            "type": type.rawValue
        ]
    }
}
