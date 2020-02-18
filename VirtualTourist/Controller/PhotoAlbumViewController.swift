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
    let itemsPerRow: CGFloat = 3
    
    var currentLocation: MKAnnotation?
    var images: [Image]?
    var pages: Int?
    var isEditMode = false
    
    //MARK: - Outlets
    @IBOutlet weak var albumMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    
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
            collectionView.reloadData()
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
    
    @IBAction func collectionButtonTapped(_ sender: UIButton) {
        newCollectionButton.isEnabled = false
        
        if (isEditMode) {
            deleteCellItems()
        } else {
            downloadFlickrImages()
        }
    }
    
    // MARK: - Helpers functions
    // handle action button text
    func changeTextButton() {
        newCollectionButton.setTitle(isEditMode ? "Remove from collection" : "New Collection", for: .normal)
    }
}

//MARK: - MapView
extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId, animate: false)
    }
}
