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
    let deltaSpan = CLLocationDegrees(0.3)
    var currentLocation: MKPointAnnotation?
    @IBOutlet weak var albumMapView: MKMapView!
    
    //MARK: - Navigation Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        albumMapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentLocation = currentLocation {
            let coordinateSpan = MKCoordinateSpan(latitudeDelta: deltaSpan, longitudeDelta: deltaSpan)
            let coordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: coordinateSpan)
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
        return getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId)
    }
    
    //MARK: - Buttons Actions
    @IBAction func cancelActionTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}
