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
    var mapCamera: MKMapCamera?
    var mapRegion: MKCoordinateRegion?
    var mapCameraZoom: MKMapView.CameraZoomRange?
    var mapCenter: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    
    // MARK: Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        enableTopBarButtons(deleteMode)
        mapView.delegate = self
        fetchedResultController = setupFetchController(createFetchRequest(), delegate: self)
        loadAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchedResultController = setupFetchController(createFetchRequest(), delegate: self)
        loadAnnotations()
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
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mapCamera = mapView.camera
        mapRegion = mapView.region
        mapCameraZoom = mapView.cameraZoomRange
        mapCenter = mapView.centerCoordinate
    }
    
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

    private func loadAnnotations() {
        isTapGesture = false
        
        if let pins = fetchedResultController.fetchedObjects {
            print("pins size [\(pins.count)]")
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                self.mapView.removeAnnotation(annotation)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    //MARK: - Core Data
    func addPin(annotation: MKAnnotation) {
        let pin = Pin(context: PersistentContainer.shared.viewContext)
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        PersistentContainer.shared.saveContext()
    }
    
    func deletePin(annotation: MKAnnotation) {
        if let pin = fetchPinFromMap(annotation) {
            let pinToDelete = PersistentContainer.shared.viewContext.object(with: pin.objectID)
            PersistentContainer.shared.deleObject(object: pinToDelete)
        } else {
            print("pin not found from annotation \(annotation)!!!!!")
        }
    }
    
    func fetchPinFromMap(_ annotation: MKAnnotation) -> Pin? {
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "latitude = %lf", annotation.coordinate.latitude),
            NSPredicate(format: "longitude = %lf", annotation.coordinate.longitude)])
        let filteredFetchRequest: NSFetchRequest<Pin> = createFetchRequest(predicate: compoundPredicate)
        let filtredFetchedResults: NSFetchedResultsController<Pin> = setupFetchController(filteredFetchRequest, delegate: self)
        return filtredFetchedResults.fetchedObjects?.first
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
