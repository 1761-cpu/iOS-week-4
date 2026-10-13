import SwiftUI

struct StudentsView: View {
    @EnvironmentObject var manager: SchoolManager
    
    @State private var id = ""
    @State private var name = ""
    @State private var address = ""
    @State private var yearText = ""
    @State private var message: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Thêm sinh viên") {
                    TextField("Mã SV (vd: SV004)", text: $id)
                    TextField("Họ tên", text: $name)
                    TextField("Địa chỉ", text: $address)
                    TextField("Năm vào (vd: 2023)", text: $yearText)
                        .keyboardType(.numberPad)
                    Button("Thêm") { add() }
                }
                
                Section("Danh sách (\(manager.students.count))") {
                    ForEach(manager.students) { s in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(s.getName()).font(.headline)
                            Text("\(s.getID()) • \(s.getAddress()) • Khóa \(s.getEntranceYear())")
                                .font(.caption).foregroundColor(.gray)
                            if let g = manager.gpa(of: s.getID()) {
                                Text("GPA: \(String(format: "%.2f", g))")
                                    .font(.caption).bold()
                                    .foregroundColor(g >= 8 ? .green : .blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sinh viên")
            .messageAlert("Thông báo", message: $message)
        }
    }
    
    private func add() {
        guard let year = Int(yearText) else {
            message = "Năm vào phải là số."
            return
        }
        do {
            try manager.addStudent(id: id, name: name, address: address, entranceYear: year)
            id = ""; name = ""; address = ""; yearText = ""
            message = "✅ Đã thêm sinh viên."
        } catch {
            message = error.localizedDescription
        }
    }
}

#Preview {
    StudentsView()
        .environmentObject(SchoolManager.preview())
}