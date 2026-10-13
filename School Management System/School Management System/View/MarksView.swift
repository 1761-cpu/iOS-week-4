import SwiftUI

struct MarksView: View {
    @EnvironmentObject var manager: SchoolManager
    
    @State private var studentID = ""
    @State private var message: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Chọn sinh viên") {
                    Picker("Sinh viên", selection: $studentID) {
                        Text("— Chọn —").tag("")
                        ForEach(manager.students) { s in
                            Text("\(s.getID()) – \(s.getName())").tag(s.getID())
                        }
                    }
                }
                
                if !studentID.isEmpty {
                    Section("Điểm các môn") {
                        let recs = manager.records(ofStudent: studentID)
                        if recs.isEmpty {
                            Text("Chưa đăng ký môn nào.").foregroundColor(.gray)
                        }
                        ForEach(recs) { r in
                            MarkRow(record: r) { message = $0 }
                        }
                    }
                }
            }
            .navigationTitle("Cập nhật điểm")
            .messageAlert("Thông báo", message: $message)
        }
    }
}

// MARK: - 1 dòng nhập điểm
struct MarkRow: View {
    @EnvironmentObject var manager: SchoolManager
    let record: StudentSubject
    let onMessage: (String) -> Void
    
    @State private var text = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(manager.subject(withID: record.getSubjectID())?.getName() ?? record.getSubjectID())
                    .font(.headline)
                Text("\(record.getSubjectID()) • Kì \(record.getSemester())")
                    .font(.caption).foregroundColor(.gray)
            }
            Spacer()
            TextField("Điểm", text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)
                .multilineTextAlignment(.center)
            Button("Lưu") { save() }
                .buttonStyle(.borderless)
        }
        .onAppear {
            text = record.isGraded() ? String(format: "%.1f", record.getMark()) : ""
        }
    }
    
    private func save() {
        // Cho phép user gõ "8,5" kiểu VN
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else {
            onMessage("Điểm phải là số.")
            return
        }
        do {
            try manager.updateMark(recordID: record.id, mark: value)
            onMessage("✅ Đã lưu điểm.")
        } catch {
            onMessage(error.localizedDescription)
        }
    }
}

#Preview {
    MarksView()
        .environmentObject(SchoolManager.preview())
}