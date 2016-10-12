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

class FieldMapOverlayView: MKOverlayRenderer {
    
//    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext!) {
//        let imageReference = overlayImage.CGImage
//        
//        let theMapRect = overlay.boundingMapRect
//        let theRect = self.rectForMapRect(theMapRect)
//        
//        CGContextScaleCTM(context, 1.0, -1.0)
//        CGContextTranslateCTM(context, 0.0, -theRect.size.height)
//        CGContextDrawImage(context, theRect, imageReference)
//    }
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
//            let topLeft = MKMapPointForCoordinate(annotations[0].coordinate)
//            let topRight = MKMapPointForCoordinate(annotations[1].coordinate)
//            let bottomLeft = MKMapPointForCoordinate(annotations[2].coordinate)
//            let bottomRight = MKMapPointForCoordinate(annotations[3].coordinate)
//            
//            let rect = MKMapRectMake(topLeft.x,
//                                     topLeft.y,
//                                     fabs(topLeft.x-topRight.x),
//                                     fabs(topLeft.y - bottomLeft.y))
            let overlay = MKPolygon(coordinates: annotations.map({ $0.coordinate }), count: 4)
            mapView.addOverlay(overlay)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(overlay: overlay)
        renderer.fillColor = UIColor.purpleColor()
        return renderer
    }
}
