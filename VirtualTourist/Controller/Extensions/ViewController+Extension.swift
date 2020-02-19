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
            // pinView!.animatesDrop = animate
        }
        else {
            pinView!.annotation = annotation
        }
        pinView!.animatesDrop = animate
        return pinView
    }

    // MARK: - Fetch Controller
    func createFetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<Pin> {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchRequest
    }
    
    /*
    func createFetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<Photo> {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchRequest
    }*/
    
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
}
