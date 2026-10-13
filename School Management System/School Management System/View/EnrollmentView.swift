import SwiftUI

struct EnrollmentView: View {
    @EnvironmentObject var manager: SchoolManager
    
    @State private var studentID = ""
    @State private var semester = 1
    @State private var selected = Set<String>()   // Các môn đang tick
    @State private var message: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Chọn sinh viên & kì") {
                    Picker("Sinh viên", selection: $studentID) {
                        Text("— Chọn —").tag("")
                        ForEach(manager.students) { s in
                            Text("\(s.getID()) – \(s.getName())").tag(s.getID())
                        }
                    }
                    Picker("Học kỳ", selection: $semester) {
                        ForEach(1...8, id: \.self) { Text("Kì \($0)").tag($0) }
                    }
                }
                
                Section("Tick chọn môn") {
                    if manager.subjects.isEmpty {
                        Text("Chưa có môn học.").foregroundColor(.gray)
                    }
                    ForEach(manager.subjects) { sub in
                        Button {
                            toggle(sub.getID())
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sub.getName())
                                    Text("\(sub.getID()) • \(sub.getCredits()) TC • Kì CTĐT: \(sub.getSemester())")
                                        .font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: selected.contains(sub.getID()) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selected.contains(sub.getID()) ? .blue : .gray)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    Button("Chọn hết môn theo kì CTĐT") {
                        selected = Set(
                            manager.subjects
                                .filter { $0.getSemester() == semester }
                                .map { $0.getID() }
                        )
                    }
                }
                
                Section {
                    Button("Đăng ký \(selected.count) môn") { register() }
                        .disabled(studentID.isEmpty || selected.isEmpty)
                }
                
                if !studentID.isEmpty {
                    Section("Đã đăng ký ở kì \(semester)") {
                        let current = manager.records(ofStudent: studentID)
                            .filter { $0.getSemester() == semester }
                        if current.isEmpty {
                            Text("Chưa đăng ký môn nào.").foregroundColor(.gray)
                        }
                        ForEach(current) { r in
                            Text("\(r.getSubjectID()) – \(manager.subject(withID: r.getSubjectID())?.getName() ?? "?")")
                        }
                    }
                }
            }
            .navigationTitle("Đăng ký môn")
            .messageAlert("Kết quả", message: $message)
        }
    }
    
    private func toggle(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }
    
    private func register() {
        let result = manager.enroll(
            studentID: studentID,
            subjectIDs: Array(selected),
            semester: semester
        )
        var lines = ["✅ Đăng ký thành công: \(result.added) môn."]
        lines += result.errors.map { "• " + $0 }
        message = lines.joined(separator: "\n")
        selected.removeAll()
    }
}

#Preview {
    EnrollmentView()
        .environmentObject(SchoolManager.preview())
}