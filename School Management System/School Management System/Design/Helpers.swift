import SwiftUI

// ==========================================
// MARK: - ALERT & TITLE
// ==========================================
extension View {
    func messageAlert(_ title: String, message: Binding<String?>) -> some View {
        alert(title, isPresented: Binding(get: { message.wrappedValue != nil }, set: { if !$0 { message.wrappedValue = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
    
    func centeredTitle(_ text: String, color: Color = .black) -> some View {
        self.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(text)
                        .font(.system(size: 25, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                }
            }
    }
}

// ==========================================
// MARK: - BACKGROUND & CARD MODIFIER
// ==========================================
extension View {
    func screenBackground(_ imageName: String = "bg1", opacity: Double = 0.3, fit: Bool = false, topOffset: CGFloat = 0) -> some View {
        self.scrollContentBackground(.hidden)
            .background {
                GeometryReader { geo in
                    ZStack(alignment: .top) {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .scaleEffect(fit ? 1.15 : 1)
                            .blur(radius: fit ? 30 : 0)
                            .clipped()
                        
                        if fit {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width)
                                .mask(
                                    LinearGradient(stops: [
                                        .init(color: .clear, location: 0),
                                        .init(color: .black, location: 0.08),
                                        .init(color: .black, location: 0.92),
                                        .init(color: .clear, location: 1)
                                    ], startPoint: .top, endPoint: .bottom)
                                )
                                .padding(.top, topOffset)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                    .clipped()
                    .overlay(Color.gray.opacity(opacity))
                }
                .ignoresSafeArea()
            }
    }
}

struct ListRowCard: ViewModifier {
    var inset: CGFloat = 16
    var fill: Color = Color.white.opacity(0.9)
    var border: Color = .clear
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 12).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1))
            .listRowInsets(EdgeInsets(top: 10, leading: inset, bottom: 4, trailing: inset))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

extension View {
    func listRowCard(inset: CGFloat = 16, fill: Color = Theme.cardFill, border: Color = .clear) -> some View {
        modifier(ListRowCard(inset: inset, fill: fill, border: border))
    }
}

// ==========================================
// MARK: - CUSTOM TOP BAR & SECTION TAG
// ==========================================
struct TitleBadge: View {
    let text: String
    let color: Color
    let radius: CGFloat
    let glassTint: Color
    let rim: CGFloat = 6
    
    var body: some View {
        let inner = RoundedRectangle(cornerRadius: radius)
        let outer = RoundedRectangle(cornerRadius: radius + rim)
        
        Text(text)
            .font(.system(size: 25, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 14)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.75), in: inner)
            .padding(rim)
            .glassEffect(.regular.tint(glassTint), in: outer)
    }
}

struct TopBar<Leading: View, Trailing: View>: View {
    let title: String
    var color: Color = .black
    var radius: CGFloat = 12
    var glassTint: Color = .blue.opacity(0.9)
    var topPadding: CGFloat = 0
    var bottomPadding: CGFloat = 12
    var showTrailing = true
    let leading: Leading
    let trailing: Trailing
    
    // Hàm khởi tạo gốc (dùng cho các màn hình cần cả 2 nút, hoặc cần nút Back)
    init(title: String, color: Color = .black, radius: CGFloat = 12, glassTint: Color = .blue.opacity(0.9), topPadding: CGFloat = 0, bottomPadding: CGFloat = 12, @ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.color = color
        self.radius = radius
        self.glassTint = glassTint
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.leading = leading()
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack {
            leading
            TitleBadge(text: title, color: color, radius: radius, glassTint: glassTint)
            Spacer()
            if showTrailing {
                HStack(spacing: 16) { trailing }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .glassEffect(.regular, in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
    }
}

// Extension 1: Chỉ có nút bên phải (Menu/Add), không có nút Back
// (Dùng cho Students, Subjects, Teachers)
extension TopBar where Leading == EmptyView {
    init(title: String, color: Color = .black, radius: CGFloat = 12, glassTint: Color = .blue.opacity(0.9), topPadding: CGFloat = 0, bottomPadding: CGFloat = 12, @ViewBuilder trailing: () -> Trailing) {
        self.init(title: title, color: color, radius: radius, glassTint: glassTint, topPadding: topPadding, bottomPadding: bottomPadding, leading: { EmptyView() }, trailing: trailing)
    }
}

// Extension 2: Không có nút nào cả
extension TopBar where Leading == EmptyView, Trailing == EmptyView {
    init(title: String, color: Color = .black, radius: CGFloat = 12, glassTint: Color = .blue.opacity(0.9), topPadding: CGFloat = 0, bottomPadding: CGFloat = 12) {
        self.init(title: title, color: color, radius: radius, glassTint: glassTint, topPadding: topPadding, bottomPadding: bottomPadding, leading: { EmptyView() }, trailing: { EmptyView() })
        self.showTrailing = false   // <- thêm dòng này
    }
}

struct SectionTag: View {
    let text: String
    var systemImage: String? = nil
    let color: Color
    
    init(_ text: String, systemImage: String? = nil, color: Color) {
        self.text = text
        self.systemImage = systemImage
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 6) {
            if let systemImage { Image(systemName: systemImage) }
            Text(text)
        }
        .font(.system(size: 15, weight: .bold))
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color, in: RoundedRectangle(cornerRadius: 12))
        .textCase(nil)
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
