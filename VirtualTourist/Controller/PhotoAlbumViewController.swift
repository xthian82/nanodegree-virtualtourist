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
    // var currentLocation: MKPointAnnotation?
    var currentLocation = MKPointAnnotation()
    var images: [Image]?
    var pages: Int?
    var selectedItems: Set<Int> = []
    var isDeleteMode = false
    
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
        
        //currentLocation = MKPointAnnotation()
        //,
        currentLocation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(-25.434861),
                                                            longitude: CLLocationDegrees(-49.2688997))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //if let currentLocation = currentLocation {
            let coordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: coordinateSpan)
            navigateToLocation(albumMapView, to: currentLocation, region: coordinateRegion)
        //}
    }

    override func viewWillDisappear(_ animated: Bool) {
        //if let currentLocation = currentLocation {
            albumMapView.removeAnnotation(currentLocation)
        //}
    }
    
    //MARK: - Buttons Actions
    @IBAction func cancelActionTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @IBAction func getImagesFromLocation() {
        newCollectionButton.isEnabled = false
        var pageNumber = 1
        if let pages = pages {
            pageNumber = Int.random(in: 1 ... pages)
        }
        FlickrClient.getPhotoFromsLocation(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude, page: pageNumber) { (response, error) in
            self.newCollectionButton.isEnabled = true
            guard let photoAlbum = response else {
                return
            }
            self.pages = photoAlbum.photos.pages
            self.images = photoAlbum.photos.photo
            self.collectionView.reloadData()
        }
    }
}

//MARK: - MapView
extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId)
    }
}
