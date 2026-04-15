import SwiftUI

enum LockInTheme {
    static let background   = Color(hex: "0A0E1A")
    static let surface      = Color(hex: "111827")
    static let card         = Color(hex: "161D2E")
    static let accent       = Color(hex: "4F8EF7")
    static let accentAlt    = Color(hex: "7B5EF5")
    static let success      = Color(hex: "22C55E")
    static let warning      = Color(hex: "F59E0B")
    static let danger       = Color(hex: "EF4444")
    static let textPrimary  = Color.white
    static let textSecondary = Color(hex: "9CA3AF")
    static let textMuted    = Color(hex: "4B5563")
    static let border       = Color(hex: "1F2937")
    static let borderBright = Color(hex: "374151")
}

extension Color {
    init(hex: String) {
        var s = Scanner(string: hex)
        var rgb: UInt64 = 0
        s.scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8)  & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}

extension View {
    func glowAccent(radius: CGFloat = 8) -> some View {
        shadow(color: LockInTheme.accent.opacity(0.55), radius: radius)
    }
    func cardStyle() -> some View {
        background(LockInTheme.card)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(LockInTheme.border, lineWidth: 1))
    }
}

// MARK: - Reusable Components
struct PrimaryButton: View {
    let title: String; let icon: String?; let action: () -> Void
    var color: Color = LockInTheme.accent
    init(_ title: String, icon: String? = nil, color: Color = LockInTheme.accent, action: @escaping () -> Void) {
        self.title = title; self.icon = icon; self.color = color; self.action = action
    }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(color).foregroundColor(.white).cornerRadius(10)
        }
    }
}

struct SecondaryButton: View {
    let title: String; let icon: String?; let action: () -> Void
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title; self.icon = icon; self.action = action
    }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title).fontWeight(.medium)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 12)
            .background(LockInTheme.surface).foregroundColor(LockInTheme.textSecondary)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(LockInTheme.borderBright, lineWidth: 1))
        }
    }
}

struct StatCard: View {
    let label: String; let value: String; let unit: String
    var color: Color = LockInTheme.accent
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(color).glowAccent(radius: 5)
            if !unit.isEmpty { Text(unit).font(.system(size: 10, weight: .medium)).foregroundColor(LockInTheme.textMuted) }
            Text(label).font(.system(size: 11)).foregroundColor(LockInTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12).cardStyle()
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(LockInTheme.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
