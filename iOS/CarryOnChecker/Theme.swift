import SwiftUI

/// Unique visual identity for Carry-on Checker.
enum Theme {
    static let background = Color(red: 0.059, green: 0.106, blue: 0.176)
    static let accent = Color(red: 0.227, green: 0.651, blue: 1.000)
    static let secondary = Color(red: 0.561, green: 0.722, blue: 0.851)
    static let cardBackground = background.opacity(0.92)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 16
    static let spacing: CGFloat = 12
}
