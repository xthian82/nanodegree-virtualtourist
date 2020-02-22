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
        positionLastLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchedResultController = setupFetchController(createFetchRequest(), delegate: self)
        loadAnnotations()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultController = nil
        updateMapPosition(mapView: mapView)
    }
    
    // MARK: - Map Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let map = getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId, animate: isTapGesture)
        isTapGesture = false
        return map
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // remove selection for later "re-selection"
        mapView.deselectAnnotation(view.annotation, animated: false)
        if deleteMode {
            deletePin(annotation: view.annotation!) { didFinish in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.loadAnnotations()
            }
        } else {
            let photoAlbumViewController = self.storyboard!.instantiateViewController(withIdentifier: Constants.photoAlbumControllerId) as! PhotoAlbumViewController
            photoAlbumViewController.currentLocation = view.annotation!
            photoAlbumViewController.pin = fetchPinFromMap(view.annotation!)
            self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
        }
    }

    // MARK: - Delegate Actions
    @IBAction func selectedPointTapped(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began && !deleteMode {
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
    
    private func positionLastLocation() {
        let fetchRequest: NSFetchRequest<LastMapPosition> = LastMapPosition.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
              
        let lastMapPositionControler = setupFetchController(fetchRequest, delegate: self)
        guard let fetched = lastMapPositionControler.fetchedObjects, let current = fetched.first else {
            return
        }

        // center location
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(current.regCenLat),
                                                                       longitude: CLLocationDegrees(current.regCenLon)),
                                        span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(current.regSpaLatDelta),
                                                               longitudeDelta: CLLocationDegrees(current.regSpaLonDelta))
                    )
        
        // zoome range
        let camZoomRange = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: CLLocationDistance(current.camZooMinDis),
            maxCenterCoordinateDistance: CLLocationDistance(current.camZooMaxDis)
        )
        
        // camera
        let cameraCenter = CLLocationCoordinate2DMake(CLLocationDegrees(current.camCenterLat),
                                                      CLLocationDegrees(current.camCenterLon))
        
        let camera = MKMapCamera(lookingAtCenter: cameraCenter,
                                 fromDistance: CLLocationDistance(current.camDistance),
                                 pitch: CGFloat(current.camPitch),
                                 heading: CLLocationDirection(current.camHeading))

        mapView.center = CGPoint(x: current.centerX, y: current.centerY)
        mapView.setRegion(region, animated: false)
        mapView.setCamera(camera, animated: false)
        mapView.setCameraZoomRange(camZoomRange, animated: false)
    }
}
