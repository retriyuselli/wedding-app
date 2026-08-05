import Foundation
import UIKit

enum DeviceIdentity {
    static var identifier: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
    }

    static var name: String {
        UIDevice.current.name
    }

    static var platform: String { "ios" }
}
