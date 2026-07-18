import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "SplashBackground" asset catalog color resource.
    static let splashBackground = DeveloperToolsSupport.ColorResource(name: "SplashBackground", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "AboutAppIcon" asset catalog image resource.
    static let aboutAppIcon = DeveloperToolsSupport.ImageResource(name: "AboutAppIcon", bundle: resourceBundle)

    /// The "AuthFloralCorner" asset catalog image resource.
    static let authFloralCorner = DeveloperToolsSupport.ImageResource(name: "AuthFloralCorner", bundle: resourceBundle)

    /// The "CouplePortrait" asset catalog image resource.
    static let couplePortrait = DeveloperToolsSupport.ImageResource(name: "CouplePortrait", bundle: resourceBundle)

    /// The "FloralHeader" asset catalog image resource.
    static let floralHeader = DeveloperToolsSupport.ImageResource(name: "FloralHeader", bundle: resourceBundle)

    /// The "SplashRings" asset catalog image resource.
    static let splashRings = DeveloperToolsSupport.ImageResource(name: "SplashRings", bundle: resourceBundle)

    /// The "SplashScreen" asset catalog image resource.
    static let splashScreen = DeveloperToolsSupport.ImageResource(name: "SplashScreen", bundle: resourceBundle)

    /// The "WeddingAppCoupleLogo" asset catalog image resource.
    static let weddingAppCoupleLogo = DeveloperToolsSupport.ImageResource(name: "WeddingAppCoupleLogo", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "SplashBackground" asset catalog color.
    static var splashBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .splashBackground)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "SplashBackground" asset catalog color.
    static var splashBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .splashBackground)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "SplashBackground" asset catalog color.
    static var splashBackground: SwiftUI.Color { .init(.splashBackground) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "SplashBackground" asset catalog color.
    static var splashBackground: SwiftUI.Color { .init(.splashBackground) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "AboutAppIcon" asset catalog image.
    static var aboutAppIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aboutAppIcon)
#else
        .init()
#endif
    }

    /// The "AuthFloralCorner" asset catalog image.
    static var authFloralCorner: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .authFloralCorner)
#else
        .init()
#endif
    }

    /// The "CouplePortrait" asset catalog image.
    static var couplePortrait: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .couplePortrait)
#else
        .init()
#endif
    }

    /// The "FloralHeader" asset catalog image.
    static var floralHeader: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .floralHeader)
#else
        .init()
#endif
    }

    /// The "SplashRings" asset catalog image.
    static var splashRings: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .splashRings)
#else
        .init()
#endif
    }

    /// The "SplashScreen" asset catalog image.
    static var splashScreen: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .splashScreen)
#else
        .init()
#endif
    }

    /// The "WeddingAppCoupleLogo" asset catalog image.
    static var weddingAppCoupleLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .weddingAppCoupleLogo)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "AboutAppIcon" asset catalog image.
    static var aboutAppIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aboutAppIcon)
#else
        .init()
#endif
    }

    /// The "AuthFloralCorner" asset catalog image.
    static var authFloralCorner: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .authFloralCorner)
#else
        .init()
#endif
    }

    /// The "CouplePortrait" asset catalog image.
    static var couplePortrait: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .couplePortrait)
#else
        .init()
#endif
    }

    /// The "FloralHeader" asset catalog image.
    static var floralHeader: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .floralHeader)
#else
        .init()
#endif
    }

    /// The "SplashRings" asset catalog image.
    static var splashRings: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .splashRings)
#else
        .init()
#endif
    }

    /// The "SplashScreen" asset catalog image.
    static var splashScreen: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .splashScreen)
#else
        .init()
#endif
    }

    /// The "WeddingAppCoupleLogo" asset catalog image.
    static var weddingAppCoupleLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .weddingAppCoupleLogo)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

