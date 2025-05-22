import Foundation
import CoreData

extension MixTape {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MixTape> {
        return NSFetchRequest<MixTape>(entityName: "MixTape")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var moodLabel: String?
    @NSManaged private var songsSet: NSSet?
    
    public var songs: Set<Song> {
        get {
            (songsSet as? Set<Song>) ?? []
        }
        set {
            songsSet = newValue as NSSet
        }
    }
    
    public var songsArray: [Song] {
        return Array(songs).sorted { $0.title < $1.title }
    }
}

// MARK: Generated accessors for songs
extension MixTape {
    @objc(addSongsObject:)
    @NSManaged public func addToSongs(_ value: Song)

    @objc(removeSongsObject:)
    @NSManaged public func removeFromSongs(_ value: Song)

    @objc(addSongs:)
    @NSManaged public func addToSongs(_ values: NSSet)

    @objc(removeSongs:)
    @NSManaged public func removeFromSongs(_ values: NSSet)
}
