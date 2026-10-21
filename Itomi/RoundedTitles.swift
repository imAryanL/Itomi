// Makes navigation titles use SF Pro Rounded like the rest of the app

import UIKit

// Apple's UIKit setup: SwiftUI can't change navigation title fonts on its own
enum RoundedTitles {
    static func apply() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.font: roundedFont(style: .largeTitle, weight: .bold)]
        appearance.titleTextAttributes = [.font: roundedFont(style: .headline, weight: .semibold)]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }

    // The system font at a text style's size, switched to the rounded design
    static func roundedFont(style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let size = UIFont.preferredFont(forTextStyle: style).pointSize
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return systemFont
    }
}
