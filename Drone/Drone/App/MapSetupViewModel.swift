//
//  MapSetupViewModel.swift
//  Drone
//
//  Created by Daniel on 10/11/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import UIKit
import ReactiveCocoa

struct SavedMapCoordinates {
    
    let key: String
    let name: String
    let addedByUser: String
    let ref: FIRDatabaseReference?
    var completed: Bool
    
    init(name: String, addedByUser: String, completed: Bool, key: String = "") {
        self.key = key
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
            "addedByUser": addedByUser,
            "completed": completed
        ]
    }
    
}

struct MapData {
    let key: String
    let centerLat: NSNumber
    let centerLng: NSNumber
    let deltaLat: NSNumber
    let deltaLng: NSNumber
    let ref: FIRDatabaseReference?
    
    init(centerLat: NSNumber, centerLng: NSNumber, deltaLat: NSNumber, deltaLng: NSNumber, key: String = "") {
        self.key = key
        self.centerLat = centerLat
        self.centerLng = centerLng
        self.deltaLat = deltaLat
        self.deltaLng = deltaLng
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        centerLat = snapshotValue["centerLat"] as! NSNumber
        centerLng = snapshotValue["centerLng"] as! NSNumber
        deltaLat = snapshotValue["deltaLat"] as! NSNumber
        deltaLng = snapshotValue["deltaLng"] as! NSNumber
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "centerLat": centerLat,
            "centerLng": centerLng,
            "deltaLat": deltaLat,
            "deltaLng": deltaLng
        ]
    }
}

class MapSetupViewModel: ViewModel {

    // Inputs
    // field input
    let mapRegionInput: MutableProperty<MKCoordinateRegion?> = MutableProperty(nil)
    
    // Outputs
    // field type
    let mapRegionOutput: MutableProperty<MKCoordinateRegion?> = MutableProperty(nil)
    let annotationArrayOutput: MutableProperty<[BoundaryAnnotation]> = MutableProperty([])
    let overlayArrayOutput: MutableProperty<[FieldOverlay]> = MutableProperty([])
    let labelOutput: MutableProperty<String> = MutableProperty("")
    
    // Actions
    // change field type
    // save
    
    // Firebase
    var ref: FIRDatabaseReference?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override init(services: ViewModelServicesProtocol) {
        super.init(services: services)
        
        if let user = services.user {
            ref = FIRDatabase.database().referenceWithPath("\(user.uid)-saved-data")
        }

        let mapDataKey = "mapCoords"
        let mapDataRef = self.ref?.child(mapDataKey)
        
        mapDataRef?.observeSingleEventOfType(.Value, withBlock: { [unowned self] snapshot in
            let value = snapshot.value as? NSDictionary
            let centerLat = value?["centerLat"] as? NSNumber
            let centerLng = value?["centerLng"] as? NSNumber
            let deltaLat = value?["deltaLat"] as? NSNumber
            let deltaLng = value?["deltaLng"] as? NSNumber
            
            if let centerLat = centerLat,
                let centerLng = centerLng,
                let deltaLat = deltaLat,
                let deltaLng = deltaLng {
                let data = MapData(centerLat: centerLat, centerLng: centerLng, deltaLat: deltaLat, deltaLng: deltaLng)
//                self.mapRegionOutput.value = MKCoordinateRegionMake(CLLocationCoordinate2DMake(centerLat.doubleValue, centerLng.doubleValue),
//                    MKCoordinateSpanMake(deltaLat.doubleValue, deltaLng.doubleValue))
            } else {
                
            }
        })
        
        setupBindings()
    }
    
    func setupBindings() {
        disposables.append(NSNotificationCenter.defaultCenter().rac_addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil).subscribeNext({ [unowned self] next in
            // save map coords
            print("\(next)")
            if let currentRegion = self.mapRegionInput.value {
                self.saveMapCoords(currentRegion)
            }
        }))
        
        disposables.append(annotationArrayOutput.producer.startWithNext({ [unowned self] annotations in
            let fieldAnnotations = annotations.filter({ $0.type == .Field })
            let flightAnnotations = annotations.filter({ $0.type == .Flight })
            
            var currentOverlays: [FieldOverlay] = []
            if (fieldAnnotations.count == 4) {
                let overlay = FieldOverlay(coordinates: fieldAnnotations.map({ $0.coordinate }), count: 4)
                overlay.type = .Field
                currentOverlays.append(overlay)
            }
            
            if (flightAnnotations.count == 4) {
                let overlay = FieldOverlay(coordinates: flightAnnotations.map({ $0.coordinate }), count: 4)
                overlay.type = .Flight
                currentOverlays.append(overlay)
            }
            
            self.overlayArrayOutput.value = currentOverlays
        }))
    }

    func saveMapCoords(region: MKCoordinateRegion) {
        let mapDataKey = "mapCoords"
        let data = mapDataForRegion(region)
        let mapCorodsRef = self.ref?.child(mapDataKey)
        mapCorodsRef?.setValue(data.toAnyObject())
        
    }
    
    func mapDataForRegion(region: MKCoordinateRegion) -> MapData {
        let lat = NSNumber(double: region.center.latitude)
        let lng = NSNumber(double: region.center.longitude)
        let latDelta = NSNumber(double: region.span.latitudeDelta)
        let lngDelta = NSNumber(double: region.span.longitudeDelta)
        
        let mapData = MapData(centerLat: lat, centerLng: lng, deltaLat: latDelta, deltaLng: lngDelta)
        return mapData
    }
    
    // pragma mark - Annotations
    
    func handleMapPress(coordinate: CLLocationCoordinate2D) {
        var currentAnnotations = annotationArrayOutput.value
        let currentType = currentBoundaryType(currentAnnotations)
        if currentType != .None {
            let annotation = BoundaryAnnotation(coordinate: coordinate)
            annotation.type = currentType
            currentAnnotations.append(annotation)
            annotationArrayOutput.value = currentAnnotations
            
            let nextType = currentBoundaryType(currentAnnotations)
            var labelString = "\(currentAnnotations.count) annotations, place a \(nextType.rawValue) marker"
            if nextType == .None {
                labelString = "Drag markers to adjust boundaries"
            }
            self.labelOutput.value = labelString
        }
    }
    
    func currentBoundaryType(currentAnnotations: [BoundaryAnnotation]) -> BoundaryType {
        if currentAnnotations.count < 4 {
            return .Field
        } else if currentAnnotations.count < 8 {
            return .Flight
        } else {
            return .None
        }
    }
    
    // output: annotation array
    // output: overlay array
}
