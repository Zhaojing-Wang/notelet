import SwiftUI

extension Color {
    static let noteletCanvas = Color(red: 0.96, green: 0.93, blue: 0.87)
    static let noteletPaper = Color(red: 1.0, green: 0.99, blue: 0.96)
    static let noteletInk = Color(red: 0.17, green: 0.15, blue: 0.12)
    static let noteletMutedInk = Color(red: 0.44, green: 0.38, blue: 0.30)
    static let noteletLine = Color(red: 0.25, green: 0.20, blue: 0.14).opacity(0.12)
    static let noteletAccent = Color(red: 0.65, green: 0.48, blue: 0.28)
}

extension View {
    func noteletCardStyle(radius: CGFloat = 18) -> some View {
        padding(16)
            .background(Color.noteletPaper)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.noteletLine, lineWidth: 1)
            }
            .shadow(color: Color.noteletInk.opacity(0.07), radius: 18, x: 0, y: 10)
    }
}

