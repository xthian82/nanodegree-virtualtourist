//
//  TravelLocationMapViewController.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/12/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit

@IBDesignable class TravelLocationMapViewController: UIViewController, MKMapViewDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    var deleteEnabled = true
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    
    // MARK: Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        enableTopBarButtons(deleteEnabled)
        mapView.delegate = self
    }

    // MARK: - Map Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return MapUtils.getPinViewFromMap(mapView, annotation: annotation, identifier: Constants.pinId)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // remove selection for later "reSelection"
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let photoAlbumViewController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        photoAlbumViewController.currentLocation = MapUtils.getAnnotationFromMapCoord(view.annotation!.coordinate)
        self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
    }
    
    // MARK: - Delegate Actions
    @IBAction func selectedPointTapped(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            navigateToLocation(mapView, to: MapUtils.convertGestureLocationToMapAnnotation(sender, mapView: mapView))
        }
    }
    
    @IBAction func topBarButtonSelected(_ sender: UIBarButtonItem) {
        deleteEnabled = !deleteEnabled
        enableTopBarButtons(deleteEnabled)
    }
    
    // MARK: - Helpers Methods
    func enableTopBarButtons(_ isDeleteMode: Bool) {
        deleteBarButton.image = UIImage(systemName: deleteEnabled ? "pencil.tip.crop.circle.badge.minus" : "pencil.tip.crop.circle")
    }
}

