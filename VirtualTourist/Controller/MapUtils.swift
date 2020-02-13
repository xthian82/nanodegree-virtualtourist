//
//  MapUtils.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/13/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit

class MapUtils {
    
    public class func convertGestureLocationToMapCoord(_ gestureRecognizer: UIGestureRecognizer, mapView: MKMapView) -> CLLocationCoordinate2D {
        let locationView = gestureRecognizer.location(in: gestureRecognizer.view)
        return mapView.convert(locationView, toCoordinateFrom: mapView)
    }
    
    class func getAnnotationFromMapCoord(_ locationCoordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        return annotation
    }
    
    public class func convertGestureLocationToMapAnnotation(_ gestureRecognizer: UIGestureRecognizer, mapView: MKMapView) -> MKPointAnnotation {
        let locationView = gestureRecognizer.location(in: gestureRecognizer.view)
        let locationCoordinate = mapView.convert(locationView, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        return annotation
    }
    
    class func getPinViewFromMap(_ mapView: MKMapView, annotation: MKAnnotation, identifier: String) -> MKPinAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
