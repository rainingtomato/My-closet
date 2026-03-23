import SwiftUI

extension Color {
    static func closetColor(for name: String) -> Color {
        switch name {
        case "白": return .white
        case "黑": return .black
        case "灰": return .gray
        case "蓝": return .blue
        case "红": return .red
        case "绿": return .green
        case "棕": return .brown
        case "米": return Color(red: 0.94, green: 0.89, blue: 0.76)
        default: return .secondary
        }
    }
}

struct ColorDot: View {
    let colorName: String
    let isSelected: Bool

    var body: some View {
        Circle()
            .fill(Color.closetColor(for: colorName))
            .overlay(
                Circle()
                    .strokeBorder(Color.primary.opacity(0.25), lineWidth: 1)
            )
            .frame(width: 28, height: 28)
            .overlay(
                Circle()
                    .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 3)
                    .padding(-4)
            )
            .accessibilityLabel(colorName)
    }
}
