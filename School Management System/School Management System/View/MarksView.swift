import SwiftUI

struct MarksView: View {
    @EnvironmentObject var manager: SchoolManager
    @State private var studentID = ""
    @State private var message: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        Picker("Student", selection: $studentID) {
                            Text("— Select —").tag("")
                            ForEach(manager.students) { s in
                                Text("\(s.getID()) – \(s.getName())").tag(s.getID())
                            }
                        }
                    } header: {
                        SectionTag("Select Student", systemImage: "person.fill", color: .orange)
                    }
                    .listRowBackground(Color.white.opacity(0.85))
                    
                    if !studentID.isEmpty {
                        // Extended Practice: hiển thị tổng tín chỉ + điểm TB
                        Section {
                            HStack {
                                Text("Total credits:")
                                Spacer()
                                Text("\(manager.totalCredits(ofStudent: studentID))").bold()
                            }
                            HStack {
                                Text("Average mark:")
                                Spacer()
                                if let avg = manager.averageMark(ofStudent: studentID) {
                                    Text(String(format: "%.2f", avg)).bold().foregroundColor(.blue)
                                } else {
                                    Text("—").foregroundColor(.gray)
                                }
                            }
                            HStack {
                                Text("GPA (weighted):")
                                Spacer()
                                if let g = manager.gpa(of: studentID) {
                                    Text(String(format: "%.2f", g)).bold().foregroundColor(.orange)
                                } else {
                                    Text("—").foregroundColor(.gray)
                                }
                            }
                        } header: {
                            SectionTag("Summary", systemImage: "chart.pie.fill", color: .blue)
                        }
                        .listRowBackground(Color.white.opacity(0.85))
                        
                        Section {
                            let recs = manager.records(ofStudent: studentID)
                            if recs.isEmpty {
                                Text("No enrollment records.").foregroundColor(.gray)
                            }
                            ForEach(recs) { r in
                                MarkRow(record: r) { message = $0 }
                            }
                        } header: {
                            SectionTag("Marks (0 – 10)", systemImage: "pencil.and.list.clipboard", color: .purple)
                        }
                        .listRowBackground(Color.white.opacity(0.85))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(title: "MARKS",
                       glassTint: .orange.opacity(0.9),
                       topPadding: 20,
                       bottomPadding: 20)
            }
            .messageAlert("Notice", message: $message)
            .screenBackground("markView", fit: true, topOffset: 210)
        }
    }
}

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
                Text("\(record.getSubjectID()) • Semester \(record.getSemester())")
                    .font(.caption).foregroundColor(.gray)
            }
            Spacer()
            TextField("Mark", text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)
                .multilineTextAlignment(.center)
            Button("Save") { save() }
                .buttonStyle(.borderless).foregroundColor(.blue)
        }
        .onAppear {
            text = record.isGraded() ? String(format: "%.1f", record.getMark()) : ""
        }
    }
    
    private func save() {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else {
            onMessage("Mark must be a number."); return
        }
        do {
            try manager.updateMark(recordID: record.id, mark: value)
            onMessage("✅ Mark saved.")
        } catch { onMessage(error.localizedDescription) }
    }
}

#Preview {
    MarksView().environmentObject(SchoolManager.preview())
}
