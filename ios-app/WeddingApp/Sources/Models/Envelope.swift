import Foundation

/// Matches Laravel's default JsonResource wrapping: { "data": ... }
struct Envelope<T: Decodable>: Decodable {
    let data: T
}

struct NullableEnvelope<T: Decodable>: Decodable {
    let data: T?
}
