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
    var photoAlbumViewController: PhotoAlbumViewController!
    var deleteMode = false
    var fetchedResultController: NSFetchedResultsController<Pin>!

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
        setUpFetchedPinsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpFetchedPinsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultController = nil
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
            photoAlbumViewController.images = nil
            self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
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
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "@pin.latitude == @ AND @pin.longitude == @", annotation.coordinate.latitude, annotation.coordinate.longitude)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let filterResult = setupFetchController(fetchRequest, cache: Constants.pinId)
        let pin = filterResult.fetchedObjects![0]
        
        let pinToDelete = PersistentContainer.shared.viewContext.object(with: pin.objectID)
        PersistentContainer.shared.viewContext.delete(pinToDelete)
        PersistentContainer.shared.saveContext()
        fetchedResultController = nil
    }
    
    fileprivate func setUpFetchedPinsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchedResultController = setupFetchController(fetchRequest, cache: Constants.pins)
    }
    
    private func setupFetchController(_ fetchRequest: NSFetchRequest<Pin>, cache: String) -> NSFetchedResultsController<Pin> {
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistentContainer.shared.viewContext, sectionNameKeyPath: nil, cacheName: cache)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("fetch error \(error.localizedDescription)")
        }
        return fetchedResultController
    }
    
    // MARK: - Update Core Date
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
           let indexSet = IndexSet(integer: sectionIndex)
           print("didChange \(indexSet), type = \(type)")
        /*switch type {
           case .insert: tableView.insertSections(indexSet, with: .fade)
           case .delete: tableView.deleteSections(indexSet, with: .fade)
           default:
               fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
           }*/
    }
       
   func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
           print("didChange newINde\(newIndexPath), type = \(type), index = \(indexPath)")
    /*switch type {
           case .insert:
               tableView.insertRows(at: [newIndexPath!], with: .fade)
           case .delete:
               tableView.deleteRows(at: [indexPath!], with: .fade)
           case .update:
               tableView.reloadRows(at: [indexPath!], with: .fade)
           case .move:
               tableView.moveRow(at: indexPath!, to: newIndexPath!)
           default:
               break
           }*/
   }
    
    // MARK: - Delegate Actions
    @IBAction func selectedPointTapped(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
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

