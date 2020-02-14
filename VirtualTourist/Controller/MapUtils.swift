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
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .purple
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    /*
    class func setRegionMap(_ mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
        var mapRegion = MKCoordinateRegion()
    
        mapRegion.center = coordinate
        mapRegion.span = MKCoordinateSpan(latitudeDelta: <#T##CLLocationDegrees#>, longitudeDelta: <#T##CLLocationDegrees#>)

        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }*/
}
