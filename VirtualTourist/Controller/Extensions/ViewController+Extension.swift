//
//  ViewController+Utility.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/13/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit

extension UIViewController {
    
    //MARK: - Navigation Map Utilities
    func navigateToLocation(_ mapView: MKMapView, to annotation: MKPointAnnotation, region: MKCoordinateRegion? = nil) {
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        
        if let region = region {
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getAnnotationFromMapCoord(_ locationCoordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        return annotation
    }
    
    // MARK: - Convertion utilities for map
    func convertGestureLocationToMapCoord(_ gestureRecognizer: UIGestureRecognizer, mapView: MKMapView) -> CLLocationCoordinate2D {
        let locationView = gestureRecognizer.location(in: gestureRecognizer.view)
        return mapView.convert(locationView, toCoordinateFrom: mapView)
    }
    
    func convertGestureLocationToMapAnnotation(_ gestureRecognizer: UIGestureRecognizer, mapView: MKMapView) -> MKPointAnnotation {
        let locationView = gestureRecognizer.location(in: gestureRecognizer.view)
        let locationCoordinate = mapView.convert(locationView, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        return annotation
    }
    
    // MARK: - Pin View Map
    func getPinViewFromMap(_ mapView: MKMapView, annotation: MKAnnotation, identifier: String) -> MKPinAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .purple
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
}
