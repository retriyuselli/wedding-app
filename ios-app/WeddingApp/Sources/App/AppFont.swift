import SwiftUI

struct AppFont {
    static func regular(_ size: CGFloat) -> Font {
        .custom("Poppins-Regular", size: size, relativeTo: .body)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("Poppins-Medium", size: size, relativeTo: .body)
    }

    static func semibold(_ size: CGFloat) -> Font {
        .custom("Poppins-SemiBold", size: size, relativeTo: .body)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom("Poppins-Bold", size: size, relativeTo: .body)
    }
}
