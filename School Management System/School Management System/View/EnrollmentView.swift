import SwiftUI

struct EnrollmentView: View {
    @EnvironmentObject var manager: SchoolManager
    @State private var studentID = ""
    @State private var semester = 1
    @State private var selected = Set<String>()
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
                        Picker("Semester", selection: $semester) {
                            ForEach(1...8, id: \.self) { Text("Semester \($0)").tag($0) }
                        }
                    } header: {
                        SectionTag("Student & Semester", systemImage: "person.fill", color: .blue)
                    }
                    .listRowBackground(Color.white.opacity(0.85))
                    
                    Section {
                        if manager.subjects.isEmpty {
                            Text("No subjects available.").foregroundColor(.gray)
                        }
                        ForEach(manager.subjects) { sub in
                            Button { toggle(sub.getID()) } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(sub.getName()).foregroundColor(.primary)
                                        Text("\(sub.getID()) • \(sub.getCredits()) credits • Curriculum: Sem \(sub.getSemester())")
                                            .font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: selected.contains(sub.getID())
                                          ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selected.contains(sub.getID()) ? .blue : .gray)
                                }
                            }
                        }
                        Button("✓ Select all from curriculum semester") {
                            selected = Set(manager.subjects
                                .filter { $0.getSemester() == semester }
                                .map { $0.getID() })
                        }
                        .foregroundColor(.blue)
                    }  header: {
                        SectionTag("Subjects to take this semester", systemImage: "checklist", color: .green)
                    }
                    .listRowBackground(Color.white.opacity(0.85))
                    
                    Section {
                        Button("Enroll \(selected.count) subject(s)") { register() }
                            .disabled(studentID.isEmpty || selected.isEmpty)
                            .bold()
                    }
                    .listRowBackground(Color.white.opacity(0.85))
                    
                    if !studentID.isEmpty {
                        Section {
                            let current = manager.records(ofStudent: studentID)
                                .filter { $0.getSemester() == semester }
                            if current.isEmpty {
                                Text("No subjects registered yet.").foregroundColor(.gray)
                            }
                            ForEach(current) { r in
                                Text("\(r.getSubjectID()) – \(manager.subject(withID: r.getSubjectID())?.getName() ?? "?")")
                            }
                        } header: {
                            SectionTag("Already enrolled in Semester \(semester)",
                                       systemImage: "checkmark.seal.fill", color: .indigo)
                        }
                        .listRowBackground(Color.white.opacity(0.85))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(title: "ENROLLMENT",
                       glassTint: .green.opacity(0.9),
                       topPadding: 20,
                       bottomPadding: 20)
            }
            .messageAlert("Result", message: $message)
            .screenBackground("enrolView", fit: true, topOffset: 360)
        }
    }
    
    private func toggle(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }
    
    private func register() {
        let result = manager.enroll(studentID: studentID,
                                     subjectIDs: Array(selected),
                                     semester: semester)
        var lines = ["✅ Enrolled: \(result.added) subject(s)."]
        lines += result.errors.map { "• " + $0 }
        message = lines.joined(separator: "\n")
        selected.removeAll()
    }
}

#Preview {
    EnrollmentView().environmentObject(SchoolManager.preview())
}
