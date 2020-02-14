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
    
    func navigateToLocation(_ mapView: MKMapView, to annotation: MKPointAnnotation, region: MKCoordinateRegion? = nil) {
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        
        if let region = region {
            mapView.setRegion(region, animated: true)
        }
    }
    
}
