import Foundation

struct DocumentFolderItem: Codable, Identifiable, Hashable {
    let id: Int
    var name: String
    var sortOrder: Int?
    var documentsCount: Int?
    var createdAt: String?
    var updatedAt: String?
}

struct WeddingDocumentItem: Codable, Identifiable, Hashable {
    let id: Int
    var documentFolderId: Int?
    var folderName: String?
    var fileName: String
    var filePath: String?
    var fileSize: Int?
    var mimeType: String?
    var category: String
    var url: String?
    var source: String?
    var taskTitle: String?
    var createdAt: String?
    var updatedAt: String?

    var isUploaded: Bool { (source ?? "uploaded") == "uploaded" && id > 0 }

    var categoryKind: DocumentCategory {
        DocumentCategory(rawValue: category) ?? .vendor
    }
}

struct WeddingDocumentSummary: Codable, Hashable {
    var usedBytes: Int
    var quotaBytes: Int
    var usedPercent: Double
    var counts: [String: Int]
}
