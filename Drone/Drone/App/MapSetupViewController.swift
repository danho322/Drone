//
//  MapSetupViewController.swift
//  Drone
//
//  Created by Daniel on 10/11/16.
//  Copyright © 2016 Worthless Apps. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

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
    var type: BoundaryType = .Field
    
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

class MapSetupViewController: ReactiveViewController<MapSetupViewModel>, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var outputLabel: UILabel!

    let locationManager = CLLocationManager()
    var didUpdateToUserLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        press.minimumPressDuration = 1.0
        view.addGestureRecognizer(press)

        viewModel.mapRegionOutput.producer.startWithNext() { [unowned self] region in
            self.didUpdateToUserLocation = true
            if let region = region {
                self.mapView.setRegion(region, animated: true)
            }
        }
        
        viewModel.annotationArrayOutput.producer.startWithNext() { [unowned self] annotations in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }
        
        viewModel.overlayArrayOutput.producer.startWithNext() { [unowned self] overlays in
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlays(overlays)
        }
        
        viewModel.labelOutput.producer.startWithNext() { [unowned self] text in
            self.outputLabel.text = text
        }
    }
    
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .Began {
            return
        }
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        viewModel.handleMapPress(touchMapCoordinate)
    }
    
    // MARK: - MKMapViewDelegate (objc delegate methods can't be in extensions)
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }

        //var annotationView: FieldMapAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier("FieldMapAnnotationView") as? FieldMapAnnotationView
        //if (annotationView == nil) {
        let annotationView = FieldMapAnnotationView(annotation: annotation, delegate: self)
        //} else {
        //    annotationView!.annotation = annotation
        //}
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
            print("coordinate: \(view.annotation?.coordinate)")
            refreshOverlays()
            /*
            for overlay in mapView.overlays {
//                let renderer = mapView.rendererForOverlay(overlay)
//                renderer?.setNeedsDisplay()
                mapView.removeOverlay(overlay)
                mapView.addOverlay(overlay)
            }
            */
        default: break
        }
    }
    
    func refreshOverlays() {
        viewModel.overlayArrayOutput.value = viewModel.overlayArrayOutput.value
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = FieldOverlayRenderer(overlay: overlay)
        renderer.fillColor = UIColor.purpleColor()
        return renderer
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapRegion = mapView.region
        print("region \(mapRegion)")
        viewModel.mapRegionInput.value = mapRegion
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if didUpdateToUserLocation {
            return
        }
        didUpdateToUserLocation = true
        
        print("\(viewModel.mapRegionOutput.value), \(userLocation.location?.coordinate)")
        if viewModel.mapRegionOutput.value == nil && userLocation.location != nil {
            mapView.region = MKCoordinateRegionMake(userLocation.location!.coordinate,
                                                    MKCoordinateSpanMake(0.1, 0.1))
        }
    }
}


extension MapSetupViewController: LongPressSelectableDelegate {
    func onLongPressConfirm() {
        print("long press happened")
    }
}
