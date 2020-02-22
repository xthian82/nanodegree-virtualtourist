//
//  PhotoAlbumViewController+NSFetchResult.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/20/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import CoreData

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    // MARK: - Add Photo
    func addPhoto(_ image: Data) {
        let photo = Photo(context: PersistentContainer.shared.viewContext)
        photo.image = image
        photo.pin = pin
        
        PersistentContainer.shared.saveContext()
    }
    
    // MARK: - Delete Photo
    func deletePhoto(_ index: IndexPath) {
        let photo = fetchedPhotosController.object(at: index)
        PersistentContainer.shared.deleObject(object: photo)
    }
    
    func clearFetchedPhotos(isFromCollectionButton: Bool) {
        if !isFromCollectionButton {
            return
        }
        
        guard let photos = fetchedPhotosController.fetchedObjects else {
            return
        }
        for photo in photos {
            PersistentContainer.shared.deleObject(object: photo)
        }
    }
    
    // MARK: - Fetch Controller
    func createFetchRequest() -> NSFetchRequest<Photo> {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchRequest
    }

    // MARK: - Core Data didChange Object
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
       default:
            break
       }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
}
