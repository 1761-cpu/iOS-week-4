import SwiftUI

extension Color {
    /// Chuyển mã HEX sang Color
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Bảng màu duy nhất của App
enum Theme {
    // Màu theo tab
    static let students   = Color(hex: "#8B8000")
    static let subjects   = Color(hex: "#6E260E")
    static let teachers   = Color(hex: "#059669")
    static let enrollment = Color(hex: "#253A50")
    static let marks      = Color(hex: "#CD7F32")
    static let statistics = Color(hex: "#4C2942")
    
    // Màu ngữ nghĩa
    static let danger   = Color(hex: "#DC2626")   // rớt
    static let success  = Color(hex: "#FFBF00")   // đạt
    static let gold     = Color(hex: "#16A34A")   // giỏi
    static let cardFill = Color.white.opacity(0.95)
}

#Preview {
    ContentView()
}
