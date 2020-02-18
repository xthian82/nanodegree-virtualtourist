//
//  TravelLocationMapViewController.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/12/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationMapViewController: UIViewController, MKMapViewDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var photoAlbumViewController: PhotoAlbumViewController!
    var deleteMode = false

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    
    // MARK: Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        enableTopBarButtons(deleteMode)
        mapView.delegate = self
        photoAlbumViewController = (self.storyboard!.instantiateViewController(withIdentifier: Constants.photoAlbumControllerId) as! PhotoAlbumViewController)
    }

    // MARK: - Map Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId, animate: !deleteMode)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // remove selection for later "re-selection"
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        if deleteMode {
            print("delete mode")
            mapView.removeAnnotation(view.annotation!)
        } else {
            photoAlbumViewController.currentLocation = view.annotation! 
            self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
        }
    }
    
    // MARK: - Delegate Actions
    @IBAction func selectedPointTapped(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            navigateToLocation(mapView, to: convertGestureLocationToMapAnnotation(sender, mapView: mapView))
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

