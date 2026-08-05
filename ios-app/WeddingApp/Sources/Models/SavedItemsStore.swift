import Foundation

@MainActor
final class SavedVendorsStore: ObservableObject {
    static let shared = SavedVendorsStore()

    @Published private(set) var ids: Set<Int> = []

    private let storageKey = "saved_vendor_ids"

    private init() {
        load()
    }

    func contains(_ id: Int) -> Bool {
        ids.contains(id)
    }

    func toggle(_ id: Int) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }

        persist()
    }

    private func load() {
        guard let stored = UserDefaults.standard.array(forKey: storageKey) as? [Int] else {
            ids = []
            return
        }

        ids = Set(stored)
    }

    private func persist() {
        UserDefaults.standard.set(Array(ids), forKey: storageKey)
    }
}

@MainActor
final class SavedInspirationStore: ObservableObject {
    static let shared = SavedInspirationStore()

    @Published private(set) var ids: Set<Int> = []

    private init() {}

    func contains(_ id: Int) -> Bool {
        ids.contains(id)
    }

    /// Sinkronkan status tersimpan dari respons API (`is_saved`).
    func sync(with items: [InspirationItem]) {
        for item in items {
            if item.isSaved {
                ids.insert(item.id)
            } else {
                ids.remove(item.id)
            }
        }
    }

    /// Toggle optimistik lalu persist ke server; kembalikan state jika gagal.
    func toggle(_ id: Int) {
        let wasSaved = ids.contains(id)

        if wasSaved {
            ids.remove(id)
        } else {
            ids.insert(id)
        }

        Task {
            do {
                if wasSaved {
                    try await APIClient.shared.requestNoContent("inspirations/\(id)/save", method: "DELETE")
                } else {
                    let _: Envelope<InspirationItem> = try await APIClient.shared.request(
                        "inspirations/\(id)/save",
                        method: "POST"
                    )
                }
            } catch {
                if wasSaved {
                    ids.insert(id)
                } else {
                    ids.remove(id)
                }
            }
        }
    }
}

@MainActor
final class LikedInspirationStore: ObservableObject {
    static let shared = LikedInspirationStore()

    @Published private(set) var likedIds: Set<Int> = []
    @Published private(set) var likesCounts: [Int: Int] = [:]

    private init() {}

    func contains(_ id: Int) -> Bool {
        likedIds.contains(id)
    }

    func likesCount(for id: Int, fallback: Int) -> Int {
        likesCounts[id] ?? fallback
    }

    func sync(with items: [InspirationItem]) {
        for item in items {
            if item.isLiked {
                likedIds.insert(item.id)
            } else {
                likedIds.remove(item.id)
            }

            likesCounts[item.id] = item.likes
        }
    }

    func toggle(_ id: Int, currentLikes: Int) {
        let wasLiked = likedIds.contains(id)
        let optimisticLikes = wasLiked ? max(0, currentLikes - 1) : currentLikes + 1

        if wasLiked {
            likedIds.remove(id)
        } else {
            likedIds.insert(id)
        }

        likesCounts[id] = optimisticLikes

        Task {
            do {
                let envelope: Envelope<InspirationItem> = try await APIClient.shared.request(
                    "inspirations/\(id)/like",
                    method: wasLiked ? "DELETE" : "POST"
                )

                if envelope.data.isLiked {
                    likedIds.insert(id)
                } else {
                    likedIds.remove(id)
                }

                likesCounts[id] = envelope.data.likes
            } catch {
                if wasLiked {
                    likedIds.insert(id)
                } else {
                    likedIds.remove(id)
                }

                likesCounts[id] = currentLikes
            }
        }
    }
}
