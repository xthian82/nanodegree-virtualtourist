//
//  TravelLocationMapViewController+Extension.swift
//  VirtualTourist
//
//  Created by Cristhian Jesus Recalde Franco on 19/02/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import Foundation
import CoreData
import MapKit

extension TravelLocationMapViewController {
    
    // MARK: - Fetch Controller
    func createFetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<Pin> {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchRequest
    }
    
    // MARK: - Load locations
    func loadAnnotations() {
        isTapGesture = false
        
        if let pins = fetchedResultController.fetchedObjects {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapView.removeAnnotation(annotation)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    // MARK: - Add Pin
    func addPin(annotation: MKAnnotation) {
        let pin = Pin(context: PersistentContainer.shared.viewContext)
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        PersistentContainer.shared.saveContext()
    }
    
    // MARK: - Remove Pin
    func deletePin(annotation: MKAnnotation, completion: @escaping (Bool) -> Void) {
        if let pin = fetchPinFromMap(annotation) {
            let pinToDelete = PersistentContainer.shared.viewContext.object(with: pin.objectID)
            PersistentContainer.shared.deleObject(object: pinToDelete)
        } else {
            print("pin not found from annotation \(annotation)!!!!!")
        }
        try? self.fetchedResultController.performFetch()
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
    
    // MARK: Search Pin
    func fetchPinFromMap(_ annotation: MKAnnotation) -> Pin? {
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "latitude = %lf", annotation.coordinate.latitude),
            NSPredicate(format: "longitude = %lf", annotation.coordinate.longitude)])
        let filteredFetchRequest: NSFetchRequest<Pin> = createFetchRequest(predicate: compoundPredicate)
        let filtredFetchedResults: NSFetchedResultsController<Pin> = setupFetchController(filteredFetchRequest, delegate: self)
        return filtredFetchedResults.fetchedObjects?.first
    }
    
    // MARK: - Update Map Position
    func updateMapPosition(mapView: MKMapView) {
        let fetchRequest: NSFetchRequest<LastMapPosition> = LastMapPosition.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let lastMap: LastMapPosition
        let lastMapPositionControler = setupFetchController(fetchRequest, delegate: self)
        
        if let fetchedObjects = lastMapPositionControler.fetchedObjects, fetchedObjects.count > 0 {
            // found we update
            lastMap = fetchedObjects.first!
        } else {
            // not found, we insert
            lastMap = LastMapPosition(context: PersistentContainer.shared.viewContext)
        }
        
        loadCamera(lastMap, mapView.camera)
        loadCamZoomRange(lastMap, mapView.cameraZoomRange)
        loadCenter(lastMap, mapView.center)
        loadRegion(lastMap, mapView.region)
        PersistentContainer.shared.saveContext()
    }
}
