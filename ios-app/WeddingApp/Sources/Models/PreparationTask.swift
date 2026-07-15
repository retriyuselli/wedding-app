import Foundation

struct PreparationSubTask: Codable, Identifiable, Hashable {
    let id: Int
    var title: String
    var status: String
    var dueDate: String?
    var completedAt: String?
    var sortOrder: Int?

    var statusValue: PreparationTask.Status {
        PreparationTask.Status(rawValue: status) ?? .pending
    }
}

struct PreparationTaskAttachment: Codable, Identifiable, Hashable {
    let id: Int
    var fileName: String
    var filePath: String?
    var fileSize: Int?
    var mimeType: String?
    var url: String?
    var createdAt: String?
}

struct PreparationTask: Codable, Identifiable, Hashable {
    let id: Int
    var weddingEventId: Int?
    var sectionId: Int?
    var title: String
    var label: String?
    var description: String?
    var notes: String?
    var priority: String?
    var status: String
    var dueDate: String?
    var sortOrder: Int?
    var createdAt: String? = nil
    var subTasks: [PreparationSubTask]?
    var attachments: [PreparationTaskAttachment]?

    enum Status: String {
        case pending
        case inProgress = "in_progress"
        case done
    }

    enum Priority: String {
        case high
        case medium
        case low

        var label: String {
            switch self {
            case .high: return L10n.Checklist.priorityHigh
            case .medium: return L10n.Checklist.priorityMedium
            case .low: return L10n.Checklist.priorityLow
            }
        }
    }

    var statusValue: Status {
        Status(rawValue: status) ?? .pending
    }

    var priorityValue: Priority {
        Priority(rawValue: priority ?? "medium") ?? .medium
    }

    static func status(from subTasks: [PreparationSubTask]) -> Status {
        guard !subTasks.isEmpty else { return .pending }

        if subTasks.allSatisfy({ $0.statusValue == .done }) {
            return .done
        }

        if subTasks.allSatisfy({ $0.statusValue == .pending }) {
            return .pending
        }

        return .inProgress
    }

    static func nextStatus(after status: Status) -> Status {
        switch status {
        case .pending: return .inProgress
        case .inProgress: return .done
        case .done: return .pending
        }
    }
}

struct SubTaskToggleResponse: Decodable {
    let data: PreparationSubTask
    let parentTaskStatus: String
}

struct TaskEditResult {
    let title: String
    let description: String?
    let notes: String?
    let priority: PreparationTask.Priority
    let dueDate: String?
}
