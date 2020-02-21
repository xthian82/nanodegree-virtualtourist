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
            print("loading from view, no need to delete")
            return
        }
        
        guard let photos = fetchedPhotosController.fetchedObjects else {
            print("no photos to delete")
            return
        }
        print("deleting all galley pics")
        for photo in photos {
            PersistentContainer.shared.deleObject(object: photo, save: false)
        }
        PersistentContainer.shared.saveContext()
        print("we leave now")
    }
    
    // MARK: - Fetch Controller
    func createFetchRequest() -> NSFetchRequest<Photo> {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchRequest
    }
    
    // MARK: - Core Data didChangeSection
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
           
        switch type {
        case .insert:
            print("Insert Section: \(sectionIndex)")
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.collectionView.insertSections(indexSet)
                }})
            )

        case .update:
            print("Update Section: \(sectionIndex)")
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.collectionView.reloadSections(indexSet)
                }
            }))

        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.collectionView.deleteSections(indexSet)
                }
            }))

        default:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
       }
    }
           

    // MARK: - Core Data didChange Object
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            print("Insert Object: newIndex= \(newIndexPath), index = \(indexPath)")
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.collectionView.insertItems(at: [newIndexPath!])
                }
            }))

        case .delete:
            print("delete Object: \(indexPath!)")
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.collectionView.deleteItems(at: [indexPath!])
                }
            }))

        case .update:
            print("Update Object: \(indexPath!)")
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.collectionView.reloadItems(at: [indexPath!])
                }
            }))

        case .move:
            print("Move Object: \(indexPath!)")
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
                }
            }))

       default:
            break
       }
    }
    /*
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }*/
}
