//
//  PersistentContainer.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//
import CoreData

class PersistentContainer {
    
    let container: NSPersistentContainer
        
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
        
    var backgroundContext: NSManagedObjectContext!
        
    func configureContexts() {
        backgroundContext = container.newBackgroundContext()
            
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
            
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
        
    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
    }
        
    func load(completion: (() -> Void)? = nil) {
        container.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
    
    func autoSaveViewContext(interval: TimeInterval = 30) {
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
