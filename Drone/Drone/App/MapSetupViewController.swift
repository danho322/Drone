//
//  MapSetupViewController.swift
//  Drone
//
//  Created by Daniel on 10/11/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import UIKit
import MapKit

class FieldBoundaryAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

protocol LongPressSelectableDelegate {
    func onLongPressConfirm()
}

protocol LongPressSelectable {
    func addPressGesture()
    func handleLongPress(gestureRecognizer: UIGestureRecognizer)
    var delegate: LongPressSelectableDelegate { get }
}

extension LongPressSelectable {
    
    
}

class FieldMapAnnotationView: MKAnnotationView, LongPressSelectable {
    var delegate: LongPressSelectableDelegate
    
    init(annotation: MKAnnotation, delegate: LongPressSelectableDelegate) {
        self.delegate = delegate
        super.init(annotation: annotation, reuseIdentifier: "FieldMapAnnotationView")
        self.annotation = annotation
        self.image = UIImage(named: "cone")
        draggable = true
//        canShowCallout = true
        
        // button as callout accessory
//        let deleteButton = UIButton(type: UIButtonType.Custom) as UIButton
//        deleteButton.frame.size.width = 44
//        deleteButton.frame.size.height = 44
//        deleteButton.backgroundColor = UIColor.redColor()
//        deleteButton.setImage(UIImage(named: "trash"), forState: .Normal)

//        let callout = UIView(frame: CGRectMake(0, 0, 30, 30))
//        callout.backgroundColor = UIColor.redColor()
//        
//        leftCalloutAccessoryView = callout

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func addPressGesture() {
        let press = UILongPressGestureRecognizer(target: self, action: #selector(FieldMapAnnotationView.handleLongPress))
        press.minimumPressDuration = 1.0
        self.addGestureRecognizer(press)
    }
    
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .Began {
            return
        }
        
        delegate.onLongPressConfirm()
    }
}

class FieldOverlay: MKPolygon {
//    override var coordinate: CLLocationCoordinate2D {
//        return self.coordinate
//    }
    override var boundingMapRect: MKMapRect {
        return MKMapRectWorld
    }
}

class FieldOverlayRenderer: MKPolygonRenderer {
    var boundingMapRect: MKMapRect {
        return MKMapRectWorld
    }
}

class MapSetupViewController: ReactiveViewController<MapSetupViewModel>, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        press.minimumPressDuration = 1.0
        view.addGestureRecognizer(press)
        
    }
    
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .Began {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annot = FieldBoundaryAnnotation(coordinate: touchMapCoordinate)
        addAnnotation(annot)
    }
    
    func addAnnotation(annotation: FieldBoundaryAnnotation) {
        mapView.addAnnotation(annotation)
        
        let annotations = mapView.annotations
        if (annotations.count == 4) {
            let overlay = FieldOverlay(coordinates: annotations.map({ $0.coordinate }), count: 4)
            mapView.addOverlay(overlay)
        }
    }
    
    // MARK: - MKMapViewDelegate (objc delegate methods can't be in extensions)
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: FieldMapAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier("FieldMapAnnotationView") as? FieldMapAnnotationView
        if (annotationView == nil) {
            annotationView = FieldMapAnnotationView(annotation: annotation, delegate: self)
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("selected")
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .Starting:
            view.dragState = .Dragging
        case .Ending, .Canceling:
            view.dragState = .None
            for overlay in mapView.overlays {
//                let renderer = mapView.rendererForOverlay(overlay)
//                renderer?.setNeedsDisplay()
                mapView.removeOverlay(overlay)
                mapView.addOverlay(overlay)
            }
        default: break
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = FieldOverlayRenderer(overlay: overlay)
        renderer.fillColor = UIColor.purpleColor()
        return renderer
    }
    
    
}

extension MapSetupViewController: LongPressSelectableDelegate {
    func onLongPressConfirm() {
        print("long press happened")
    }
}
