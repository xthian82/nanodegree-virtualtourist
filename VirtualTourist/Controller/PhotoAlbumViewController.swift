//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/13/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate {
    
    //MARK: - Properties
    private let coordinateSpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.3), longitudeDelta: CLLocationDegrees(0.3))
    let noOfCellsInRow = 3
    
    var currentLocation: MKAnnotation?
    var pin: Pin!
    var pages: Int?
    var isEditMode = false
    var fetchedPhotosController: NSFetchedResultsController<Photo>!
    var blockOperations: [BlockOperation] = []
    
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
        super.viewWillAppear(animated)
        if let currentLocation = currentLocation {
            fetchedPhotosController = setupFetchController(createFetchRequest(), delegate: self)
            
            let coordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: coordinateSpan)
            navigateToLocation(albumMapView, to: currentLocation, region: coordinateRegion)
            
            if fetchedPhotosController.fetchedObjects?.count == 0 {
                newCollectionButton.isEnabled = false
                downloadFlickrImages(isFromCollectionButton: false)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let currentLocation = currentLocation {
            albumMapView.removeAnnotation(currentLocation)
        }
        fetchedPhotosController = nil
    }
    
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }

        blockOperations.removeAll(keepingCapacity: false)
    }
    
    //MARK: - MapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId, animate: false)
    }
    
    //MARK: - Buttons Actions
    @IBAction func cancelActionTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @IBAction func collectionButtonTapped(_ sender: UIButton) {
        if isEditMode {
            deleteCellItems(cellsToDelete: collectionView.indexPathsForSelectedItems)
        } else {
            downloadFlickrImages(isFromCollectionButton: true)
        }
    }
    
    // MARK: - Helpers functions
    // handle action button text
    func changeTextButton() {
        newCollectionButton.setTitle(isEditMode ? "Remove from collection" : "New Collection", for: .normal)
    }
    
    private func getAllIndexesFromCollection(numberOfItems: Int) -> [IndexPath]? {
        //let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        if numberOfItems <= 0 {
            return nil
        }
        
        var indexPathSet:[IndexPath]? = []
        for row in 0..<numberOfItems {
            indexPathSet!.append(IndexPath(row: row, section: 0))
        }
        return indexPathSet
    }
}
