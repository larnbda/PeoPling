import Foundation

struct Memo: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var content: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}
