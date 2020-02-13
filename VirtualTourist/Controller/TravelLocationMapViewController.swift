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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("mapView annotation")
        if control == view.rightCalloutAccessoryView {
            print("searching annotation \(control)")
            if let toOpen = view.annotation?.coordinate {
                print("open coordinate on \(toOpen)")
               /* UIApplication.shared.open(URL(string: toOpen)!, options: [:]) { (success) in
                    if !success {
                        ControllersUtil.presentAlert(controller: self, title: Errors.mainTitle, message: Errors.cannotOpenUrl)
                    }
                }*/
            }
        }
    }
    // MARK: - Delegate Actions
    @IBAction func selectedPointTapped(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("searching location")
            navigateToLocation(annotation: MapUtils.convertGestureLocationToMapAnnotation(sender, mapView: mapView))
        }
    }
    
    @IBAction func topBarButtonSelected(_ sender: UIBarButtonItem) {
        deleteEnabled = !deleteEnabled
        enableTopBarButtons(deleteEnabled)
    }
    
    // MARK: - Helpers Methods
    func enableTopBarButtons(_ isDeleteMode: Bool) {
        if deleteEnabled {
            deleteBarButton.image = UIImage(systemName: "trash")
        } else {
            deleteBarButton.image = UIImage(systemName: "checkmark.shield")
        }
    }
    
    func navigateToLocation(annotation: MKPointAnnotation) {
        //activityIndicator.startAnimating()
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        mapView.selectAnnotation(annotation, animated: true)
        //activityIndicator.stopAnimating()
    }
}

