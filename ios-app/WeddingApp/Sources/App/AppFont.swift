import SwiftUI

struct AppFont {
    static func regular(_ size: CGFloat) -> Font {
        .custom("Poppins-Regular", size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("Poppins-Medium", size: size)
    }

    static func semibold(_ size: CGFloat) -> Font {
        .custom("Poppins-SemiBold", size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom("Poppins-Bold", size: size)
    }
}
