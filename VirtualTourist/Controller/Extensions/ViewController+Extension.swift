//
//  ViewController+Utility.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/13/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit
import CoreData

extension UIViewController {
    
    //MARK: - Navigation Map Utilities
    func navigateToLocation(_ mapView: MKMapView, to annotation: MKAnnotation, region: MKCoordinateRegion? = nil) {
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        
        if let region = region {
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Convertion utilities for map
    func convertGestureLocationToMapCoord(_ gestureRecognizer: UIGestureRecognizer, mapView: MKMapView) -> CLLocationCoordinate2D {
        let locationView = gestureRecognizer.location(in: gestureRecognizer.view)
        return mapView.convert(locationView, toCoordinateFrom: mapView)
    }
    
    func convertGestureLocationToMapAnnotation(_ gestureRecognizer: UIGestureRecognizer, mapView: MKMapView) -> MKPointAnnotation {
        let locationView = gestureRecognizer.location(in: gestureRecognizer.view)
        let locationCoordinate = mapView.convert(locationView, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        return annotation
    }
    
    // MARK: - Pin View Map
    func getPinViewFromMap(_ mapView: MKMapView, annotation: MKAnnotation, identifier: String, animate: Bool) -> MKPinAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .purple
        }
        else {
            pinView!.annotation = annotation
        }

        pinView!.animatesDrop = animate
        return pinView
    }
    
    // MARK: Core Data Fetch
    func performFetchRequest<Type: NSManagedObject>(_ fetchedResultController: NSFetchedResultsController<Type>) {
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("fetch error \(error.localizedDescription)")
        }
    }
    
    func setupFetchController<Type: NSManagedObject>(_ fetchRequest: NSFetchRequest<Type>, delegate: NSFetchedResultsControllerDelegate, cacheName: String? = nil) -> NSFetchedResultsController<Type> {

        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistentContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: cacheName)
        
        fetchedResultController.delegate = delegate

        performFetchRequest(fetchedResultController)
        return fetchedResultController
    }
    
    // MARK: - MapData Load Helpers
    func loadRegion(_ lastMap: LastMapPosition, _ region: MKCoordinateRegion) {
        lastMap.regCenLat = region.center.latitude
        lastMap.regCenLon = region.center.longitude
        lastMap.regSpaLatDelta = region.span.latitudeDelta
        lastMap.regSpaLonDelta = region.span.longitudeDelta
    }
    
    func loadCenter(_ lastMap: LastMapPosition, _ center: CGPoint) {
        lastMap.centerX = Double(center.x)
        lastMap.centerY = Double(center.y)
    }
    
    func loadCamera(_ lastMap: LastMapPosition, _ camera: MKMapCamera) {
        lastMap.camCenterLat = camera.centerCoordinate.latitude
        lastMap.camCenterLon = camera.centerCoordinate.longitude
        lastMap.camDistance = camera.centerCoordinateDistance
        lastMap.camPitch = Double(camera.pitch)
        lastMap.camHeading = camera.heading
    }
    
    func loadCamZoomRange(_ lastMap: LastMapPosition, _ cameraZoomRange: MKMapView.CameraZoomRange) {
        lastMap.camZooMaxDis = cameraZoomRange.maxCenterCoordinateDistance
        lastMap.camZooMinDis = cameraZoomRange.minCenterCoordinateDistance
    }
    
    // MARK: Alerts
    func presentAlert(controller: UIViewController, title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alertVC, animated: true, completion: nil)
    }
    
}
