//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/13/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: - Properties
    private let coordinateSpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.3), longitudeDelta: CLLocationDegrees(0.3))
    var currentLocation: MKPointAnnotation?
    
    //MARK: - Outlets
    @IBOutlet weak var albumMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    //MARK: - Navigation Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        albumMapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentLocation = currentLocation {
            let coordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: coordinateSpan)
            navigateToLocation(albumMapView, to: currentLocation, region: coordinateRegion)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let currentLocation = currentLocation {
            albumMapView.removeAnnotation(currentLocation)
        }
    }
    
    //MARK: - Buttons Actions
    @IBAction func cancelActionTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}

//MARK: - MapView
extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId)
    }
}
