import CoreData
import Combine

class MixTapeStore: ObservableObject {
    private let manager: CoreDataManager
    
    init(manager: CoreDataManager = .shared) {
        self.manager = manager
    }
    
    // MARK: - Fetch Operations
    
    func fetchMixTapes() -> [MixTape] {
        let request: NSFetchRequest<MixTape> = MixTape.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MixTape.createdAt, ascending: false)]
        
        do {
            return try manager.viewContext.fetch(request)
        } catch {
            print("Error fetching mixtapes: \(error)")
            return []
        }
    }
    
    func fetchSongs(for mixtape: MixTape) -> [Song] {
        return Array(mixtape.songs ?? [])
    }
    
    // MARK: - Create Operations
    
    func createMixTape(title: String, moodLabel: String? = nil) -> MixTape {
        let mixtape = MixTape(context: manager.viewContext)
        mixtape.id = UUID()
        mixtape.title = title
        mixtape.moodLabel = moodLabel
        mixtape.createdAt = Date()
        
        manager.saveContext()
        return mixtape
    }
    
    func addSong(title: String, artist: String?, duration: Double, url: URL, to mixtape: MixTape) -> Song {
        let song = Song(context: manager.viewContext)
        song.id = UUID()
        song.title = title
        song.artist = artist
        song.duration = duration
        song.url = url
        song.mixtape = mixtape
        
        manager.saveContext()
        return song
    }
    
    // MARK: - Update Operations
    
    func update(mixtape: MixTape) {
        manager.saveContext()
    }
    
    func update(song: Song) {
        manager.saveContext()
    }
    
    // MARK: - Delete Operations
    
    func delete(mixtape: MixTape) {
        manager.viewContext.delete(mixtape)
        manager.saveContext()
    }
    
    func delete(song: Song) {
        manager.viewContext.delete(song)
        manager.saveContext()
    }
}
