import SwiftUI

// MARK: - Color(hex:)
// Nếu bạn đã thêm extension này vào Helpers.swift rồi thì xóa một trong hai bản (tránh trùng định nghĩa).
extension Color {
    /// Nhận "#F97316", "F97316" hoặc 8 ký tự "#RRGGBBAA" (có độ trong suốt)
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let v = Scanner(string: s).scanHexInt64() ?? 0

        let r, g, b, a: Double
        if s.count == 8 {
            r = Double((v >> 24) & 0xFF) / 255
            g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255
            a = Double(v & 0xFF) / 255
        } else {
            r = Double((v >> 16) & 0xFF) / 255
            g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Bảng màu duy nhất của app (đổi màu cả app chỉ cần sửa ở đây)
enum Theme {
    // Màu theo từng tab
    static let students   = Color(hex: "#F97316")
    static let subjects   = Color(hex: "#2563EB")
    static let teachers   = Color(hex: "#059669")
    static let enrollment = Color(hex: "#6366F1")
    static let marks      = Color(hex: "#8B5CF6")
    static let statistics = Color(hex: "#DB2777")

    // Màu theo ý nghĩa
    static let danger  = Color(hex: "#DC2626")   // rớt
    static let success = Color(hex: "#16A34A")   // đạt
    static let gold    = Color(hex: "#F59E0B")   // GPA giỏi

    static let cardFill = Color.white.opacity(0.92)
}