//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/13/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UINavigationControllerDelegate {
    
    //MARK: - Properties
    var currentLocation: MKPointAnnotation?
    @IBOutlet weak var albumMapView: MKMapView!
    
    //MARK: - Navigation Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        albumMapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentLocation = currentLocation {
            let coordinateSpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.3), longitudeDelta: CLLocationDegrees(0.3))
            let coordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: coordinateSpan)
            
            //let regionRadius: CLLocationDistance = 500
            //let coordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate,
            //                                          latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            navigateToLocation(albumMapView, to: currentLocation, region: coordinateRegion)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let currentLocation = currentLocation {
            albumMapView.removeAnnotation(currentLocation)
        }
    }
    
    //MARK: - Map Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return MapUtils.getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId)
    }
    
    //MARK: - Buttons Actions
    @IBAction func cancelActionTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}
