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
    let noOfCellsInRow:CGFloat = 3.0
    let spacingBetweenCells:CGFloat = 1.0
    let spacing:CGFloat = 1.0
    
    var currentLocation: MKAnnotation?
    var pin: Pin!
    var pages: Int?
    var isEditMode = false
    var fetchedPhotosController: NSFetchedResultsController<Photo>!
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var movedIndexPaths: [IndexPath:IndexPath]!
    
    //MARK: - Outlets
    @IBOutlet weak var albumMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    //MARK: - Navigation Functions
    fileprivate func setupLayout() {
        flowLayout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = spacing
    }
    
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setupLayout()
        flowLayout.invalidateLayout()
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
    
    // MARK: - Helpers
    func downloadFlickrImages(isFromCollectionButton: Bool) {
        // try to test different pages
        var pageNumber = 1
        if let pages = pages, pages > 0 {
            pageNumber = Int.random(in: 1 ... pages)
        }
        
        guard let currentLocation = currentLocation else {
            print("no location selected! ... quitting")
            return
        }

        FlickrClient.getPhotoFromsLocation(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude, page: pageNumber) { (response, error) in
            if let error = error {
                self.presentAlert(controller: self, title: "Downloading Images", message: error.localizedDescription)
                 self.newCollectionButton.isEnabled = true
                return
            }
            
            guard let photoAlbum = response, let photos = photoAlbum.photos.photo, photos.count > 0 else {
                self.presentAlert(controller: self, title: "Alert!", message: "No image found")
                self.newCollectionButton.isEnabled = true
                return
            }
            
            self.newCollectionButton.isEnabled = false
            self.pages = photoAlbum.photos.pages
            self.asyncDowload(photoAlbum.photos.photo, isFromCollectionButton: isFromCollectionButton, completionHandler: { hasData in
                if hasData {
                    self.collectionView.reloadData()
                }
                self.newCollectionButton.isEnabled = true
            })
        }
    }
    
    func deleteCellItems(cellsToDelete: [IndexPath]?) {
        self.newCollectionButton.isEnabled = false
        asyncDelete(indexCells: cellsToDelete) { hasData in
            DispatchQueue.main.async {
                if hasData {
                    self.collectionView.reloadData()
                }
                self.newCollectionButton.isEnabled = true
                self.setEditing(false, animated: true)
            }
        }
    }
    
    /// utility to enable/disable edit mode
    func areAnyItemSelected() -> Bool {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else {
            return false
        }
        
        return selectedItems.count > 0
    }

    /// download image from collection cell in the background
    private func asyncDowload(_ images: [Image]?, isFromCollectionButton: Bool, completionHandler: @escaping (_ disFinish: Bool) -> Void) {
        guard let images = images else {
            completionHandler(false)
            return
        }
        //userInitiated
        DispatchQueue.global(qos: .background).async { () -> Void in
            // first we delete any pic if any
            self.clearFetchedPhotos(isFromCollectionButton: isFromCollectionButton)
            
            for image in images {
                if let url = image.imageLocation(), let imgData = try? Data(contentsOf: url) {
                    
                    self.addPhoto(imgData)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(true)
                    })
                }
            }
        }
    }
    
    /// delete all cells in the background
    private func asyncDelete(indexCells: [IndexPath]?, completionHandler: @escaping (_ disFinish: Bool) -> Void) {
        guard let indexPaths = indexCells else {
            // no index to download, we skip
            completionHandler(false)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            for indexPath in indexPaths {
                self.deletePhoto(indexPath)
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                completionHandler(true)
            })
        }
    }
}
