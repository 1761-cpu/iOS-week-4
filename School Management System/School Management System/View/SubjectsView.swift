import SwiftUI

struct SubjectsView: View {
    @EnvironmentObject var manager: SchoolManager
    
    @State private var id = ""
    @State private var name = ""
    @State private var creditsText = ""
    @State private var semester = 1
    @State private var message: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Thêm môn học") {
                    TextField("Mã môn (vd: CSE401)", text: $id)
                    TextField("Tên môn", text: $name)
                    TextField("Số tín chỉ", text: $creditsText)
                        .keyboardType(.numberPad)
                    Picker("Kì theo CTĐT", selection: $semester) {
                        ForEach(1...8, id: \.self) { Text("Kì \($0)").tag($0) }
                    }
                    Button("Thêm") { add() }
                }
                
                Section("Danh sách (\(manager.subjects.count))") {
                    ForEach(manager.subjects) { s in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(s.getName()).font(.headline)
                            Text("\(s.getID()) • \(s.getCredits()) tín chỉ • Kì \(s.getSemester())")
                                .font(.caption).foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Môn học")
            .messageAlert("Thông báo", message: $message)
        }
    }
    
    private func add() {
        guard let credits = Int(creditsText) else {
            message = "Số tín chỉ phải là số."
            return
        }
        do {
            try manager.addSubject(id: id, name: name, credits: credits, semester: semester)
            id = ""; name = ""; creditsText = ""
            message = "✅ Đã thêm môn học."
        } catch {
            message = error.localizedDescription
        }
    }
}

#Preview {
    SubjectsView()
        .environmentObject(SchoolManager.preview())
}