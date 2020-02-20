//
//  TravelLocationMapViewController.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/12/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapViewController: UIViewController, MKMapViewDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    var deleteMode = false
    var fetchedResultController: NSFetchedResultsController<Pin>!
    var isTapGesture = false

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    
    // MARK: Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        enableTopBarButtons(deleteMode)
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchedResultController = setupFetchController(createFetchRequest(), delegate: self)
        loadAnnotations(mapView: self.mapView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateMapPosition(mapView: mapView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultController = nil
    }

    // MARK: - Map Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let map = getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId, animate: isTapGesture)
        isTapGesture = false
        return map
    }
    
    /*
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mapCamera = mapView.camera
        mapRegion = mapView.region
        mapCameraZoom = mapView.cameraZoomRange
        mapCenter = mapView.centerCoordinate
    } */
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // remove selection for later "re-selection"
        
        if deleteMode {
            deletePin(annotation: view.annotation!)
            DispatchQueue.main.async {
                self.mapView.removeAnnotations([view.annotation!])
                self.performFetchRequest(self.fetchedResultController)
            }
        } else {
            mapView.deselectAnnotation(view.annotation, animated: false)
            let photoAlbumViewController = self.storyboard!.instantiateViewController(withIdentifier: Constants.photoAlbumControllerId) as! PhotoAlbumViewController
            photoAlbumViewController.currentLocation = view.annotation!
            photoAlbumViewController.pin = fetchPinFromMap(view.annotation!)
            self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
        }
    }

    // MARK: - Delegate Actions
    @IBAction func selectedPointTapped(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            isTapGesture = true
            let annotation = convertGestureLocationToMapAnnotation(sender, mapView: mapView)
            addPin(annotation: annotation)
            navigateToLocation(mapView, to: annotation)
        }
    }
    
    @IBAction func topBarButtonSelected(_ sender: UIBarButtonItem) {
        deleteMode = !deleteMode
        enableTopBarButtons(deleteMode)
    }
    
    // MARK: - Helpers Methods
    func enableTopBarButtons(_ isDeleteMode: Bool) {
        deleteBarButton.image = UIImage(systemName: !deleteMode ? "trash" : "trash.slash")
        view.frame.origin.y = !deleteMode ? 0 : -60
    }
}
