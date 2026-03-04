import SwiftUI

/// Centralized theme tokens.
/// Keeping colors in one place makes design updates easy and consistent.
enum Theme {
    static let page = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.black
            : UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0)
    })
    static let navy = Color(red: 0.05, green: 0.10, blue: 0.22)
    static let primary = Color(red: 0.21, green: 0.45, blue: 1.0)
    static let sky = Color(red: 0.33, green: 0.74, blue: 0.98)
    static let text = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(red: 0.08, green: 0.11, blue: 0.20, alpha: 1.0)
    })
    static let muted = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0.76, alpha: 1.0)
            : UIColor(red: 0.37, green: 0.45, blue: 0.56, alpha: 1.0)
    })
    static let surface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0.09, alpha: 1.0)
            : UIColor.white
    })
    static let field = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0.13, alpha: 1.0)
            : UIColor(red: 0.96, green: 0.98, blue: 1.0, alpha: 1.0)
    })
    static let stroke = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0.25, alpha: 1.0)
            : UIColor(red: 0.82, green: 0.89, blue: 1.0, alpha: 1.0)
    })
}
