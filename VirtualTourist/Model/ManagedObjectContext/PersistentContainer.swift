//
//  PersistentContainer.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//
import CoreData

class PersistentContainer {
    
    static let shared = PersistentContainer(modelName: "VirtualTourist")
    private let lockQueue = DispatchQueue(label: "PersistentContainer.lockQueue")
    
    let container: NSPersistentContainer
        
    var viewContext: NSManagedObjectContext {
        get {
            return lockQueue.sync {
                return container.viewContext
            }
        }
    }
        
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
        
    private init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
        load()
    }
        
    private func load(completion: (() -> Void)? = nil) {
        container.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            //self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
    
    func saveContext () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                // TODO: Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleObject(object: NSManagedObject, save: Bool = true) {
        //print("deleting \(object)")
        viewContext.delete(object)
        if save {
            saveContext()
        }
    }
    
    private func autoSaveViewContext(interval: TimeInterval = 30) {
        guard interval > 0 else {
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
