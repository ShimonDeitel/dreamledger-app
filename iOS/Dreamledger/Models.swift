import Foundation

struct DreamEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var createdAt: Date
    var text: String
    var mood: String

    init(id: UUID = UUID(), createdAt: Date = Date(), text: String = "", mood: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.text = text
        self.mood = mood
    }
}
