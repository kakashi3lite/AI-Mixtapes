import Foundation

extension Notification.Name {
    static let playAudio = Notification.Name("com.mixtapes.playAudio")
    static let pauseAudio = Notification.Name("com.mixtapes.pauseAudio")
    static let skipNext = Notification.Name("com.mixtapes.skipNext")
    static let skipPrevious = Notification.Name("com.mixtapes.skipPrevious")
    static let updateProgress = Notification.Name("com.mixtapes.updateProgress")
    static let audioFinished = Notification.Name("com.mixtapes.audioFinished")
}
