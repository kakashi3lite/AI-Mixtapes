import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AIAudioMixtapes")
        
        // Enable CloudKit integration
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve persistent store description")
        }
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.mixtapes.ai")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        
        // Automatically merge changes from parent context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Saving Context
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Background Operations
    
    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            task(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error saving background context: \(error)")
                }
            }
        }
    }
}
