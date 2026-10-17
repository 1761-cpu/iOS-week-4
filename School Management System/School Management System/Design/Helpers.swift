import SwiftUI

// MARK: - Alert helper
extension View {
    func messageAlert(_ title: String, message: Binding<String?>) -> some View {
        alert(title,
              isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { if !$0 { message.wrappedValue = nil } }
              )) {
                  Button("OK", role: .cancel) {}
              } message: {
                  Text(message.wrappedValue ?? "")
              }
    }
    
    // Style chung cho title ở giữa màn hình
    func centeredTitle(_ text: String, color: Color = .black) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(text)
                        .font(.system(size: 25, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                }
            }
    }
    
    //Background image với overlay
    func screenBackground(_ imageName: String = "bg1",
                          opacity: Double = 0.3,
                          fit: Bool = false,
                          topOffset: CGFloat = 0) -> some View {
        self
            .scrollContentBackground(.hidden)
            .background {
                GeometryReader { geo in
                    ZStack(alignment: .top) {
                        // Lớp dưới: ảnh phủ kín màn hình (làm mờ nếu fit)
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .scaleEffect(fit ? 1.15 : 1)
                            .blur(radius: fit ? 30 : 0)
                            .clipped()

                        // Lớp trên: ảnh nguyên vẹn theo chiều ngang, đẩy xuống topOffset
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

// Modifier biến mỗi List row thành card trắng mờ, bo góc, tách nhau
struct ListRowCard: ViewModifier {
    var inset: CGFloat = 16
    var fill: Color = Color.white.opacity(0.9)
    var border: Color = .clear

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12).fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1)
            )
            .listRowInsets(EdgeInsets(top: 10, leading: inset, bottom: 4, trailing: inset))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

extension View {
    func listRowCard(inset: CGFloat = 16,
                     fill: Color = Color.white.opacity(0.9),
                     border: Color = .clear) -> some View {
        modifier(ListRowCard(inset: inset, fill: fill, border: border))
    }
}

// Nhãn tiêu đề: lớp kính + lớp trắng mờ, cùng một shape
struct TitleBadge: View {
    let text: String
    let color: Color
    let radius: CGFloat        // bo góc lớp trắng (lớp trong)
    let glassTint: Color
    let rim: CGFloat = 6       // độ dày viền kính nhìn thấy quanh lớp trắng

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
            .background(Color.white.opacity(0.75), in: inner)   // lớp trên (trắng mờ)
            .padding(rim)                                       // chừa chỗ cho viền kính
            .glassEffect(.regular.tint(glassTint), in: outer)   // lớp dưới (kính, to hơn)
    }
}

extension View {
    func mainTitle(_ text: String,
                   color: Color = .black,
                   radius: CGFloat = 12,
                   glassTint: Color = .white.opacity(0.5)) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    TitleBadge(text: text, color: color, radius: radius, glassTint: glassTint)
                }
                .sharedBackgroundVisibility(.hidden)
            }
    }
}


struct TopBar<Trailing: View>: View {
    let title: String
    var color: Color = .black
    var radius: CGFloat = 12
    var glassTint: Color = .blue.opacity(0.9)
    var topPadding: CGFloat = 0      // khoảng cách thêm phía trên (tính từ vùng an toàn)
    var bottomPadding: CGFloat = 12  // khoảng cách giữa thanh và nội dung bên dưới
    var showTrailing = true
    let trailing: Trailing

    init(title: String,
         color: Color = .black,
         radius: CGFloat = 12,
         glassTint: Color = .blue.opacity(0.9),
         topPadding: CGFloat = 0,
         bottomPadding: CGFloat = 12,
         @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.color = color
        self.radius = radius
        self.glassTint = glassTint
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.trailing = trailing()
    }

    var body: some View {
        HStack {
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

// Dùng khi không có nút bên phải (Enrollment, Marks)
extension TopBar where Trailing == EmptyView {
    init(title: String,
         color: Color = .black,
         radius: CGFloat = 12,
         glassTint: Color = .blue.opacity(0.9),
         topPadding: CGFloat = 0,
         bottomPadding: CGFloat = 12) {
        self.init(title: title, color: color, radius: radius, glassTint: glassTint,
                  topPadding: topPadding, bottomPadding: bottomPadding) { EmptyView() }
        self.showTrailing = false
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
        .textCase(nil)          // không tự viết hoa theo style của Form/List
        .padding(.vertical, 4)
    }
}

struct IDChip: View {
    let text: String
    var color: Color = .orange
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 5))
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).foregroundColor(.gray)
            Spacer()
            Text(value).fontWeight(.medium)
        }
        .font(.system(size: 13))
    }
}

struct StudentCard: View {
    @EnvironmentObject var manager: SchoolManager
    let student: Student

    var body: some View {
        let gpa = manager.gpa(of: student.getID())
        let count = manager.records(ofStudent: student.getID()).count
        let credits = manager.totalCredits(ofStudent: student.getID())
        let gpaColor: Color = (gpa ?? 0) >= SchoolManager.excellentGPA ? .orange
                            : (gpa == nil ? .gray : .green)

        VStack(alignment: .leading, spacing: 10) {
            // Đầu thẻ
            HStack(spacing: 12) {
                Text(String(student.getName().prefix(1)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.orange)
                    .frame(width: 44, height: 44)
                    .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text(student.getName()).font(.headline)
                    IDChip(text: student.getID())
                }
                Spacer()
                if let g = gpa, g >= SchoolManager.excellentGPA {
                    Image(systemName: "star.circle.fill")
                        .font(.title2).foregroundColor(.orange)
                }
            }
            // Thân thẻ
            InfoRow(label: "Address", value: student.getAddress())
            InfoRow(label: "Class of", value: String(student.getEntranceYear()))
            InfoRow(label: "Enrolled", value: "\(count) subjects (\(credits) credits)")
            Divider()
            // Chân thẻ
            VStack(alignment: .leading, spacing: 2) {
                Text("CUMULATIVE GPA")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
                Text(gpa.map { String(format: "%.2f", $0) } ?? "—")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(gpaColor)
            }
        }
    }
}

// MARK: - Preview helper
extension SchoolManager {
    static func preview() -> SchoolManager {
        SchoolManager(sample: true)
    }
}

#Preview {
    ContentView()
}
