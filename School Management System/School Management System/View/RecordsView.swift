import SwiftUI

// Gộp Enrollment + Marks thành một tab, chuyển qua lại bằng thanh chọn 2 ngăn.
enum RecordsMode: String, CaseIterable, Identifiable {
    case enrollment = "Enrollment"
    case marks = "Marks"
    var id: String { rawValue }
}

struct RecordsView: View {
    @State private var mode: RecordsMode = .enrollment
    @State private var studentID = ""  // dùng chung: chọn SV ở ngăn này, sang ngăn kia vẫn giữ nguyên

    private var title: String { mode == .enrollment ? "ENROLLMENT" : "MARKS" }
    private var tint: Color { mode == .enrollment ? Theme.enrollment : Theme.marks }

    var body: some View {
        NavigationStack {
            Group {
                switch mode {
                case .enrollment: EnrollmentContent(studentID: $studentID)
                case .marks:      MarksContent(studentID: $studentID)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    TopBar(title: title,
                           glassTint: tint.opacity(0.9),
                           topPadding: 20,
                           bottomPadding: 12)

                    Picker("", selection: $mode) {
                        ForEach(RecordsMode.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .screenBackground(mode == .enrollment ? "enrolView" : "markView",
                              fit: true,
                              topOffset: mode == .enrollment ? 420 : 240)
        }
    }
}

// MARK: - Ngăn 1: Đăng ký môn
struct EnrollmentContent: View {
    @EnvironmentObject var manager: SchoolManager
    @Binding var studentID: String
    @State private var semester = 1
    @State private var selected = Set<String>()
    @State private var message: String?

    var body: some View {
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
                SectionTag("Student & Semester", systemImage: "person.fill", color: Theme.enrollment)
            }
            .listRowBackground(Color.white.opacity(0.95))

            Section {
                if manager.subjects.isEmpty {
                    Text("No subjects available.").foregroundColor(.gray)
                }
                ForEach(manager.subjects) { sub in
                    Button { toggle(sub.getID()) } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sub.getName()).foregroundColor(.primary)
                                HStack(spacing: 6) {
                                    IDChip(text: sub.getID(), color: Theme.enrollment)
                                    Text("\(sub.getCredits()) credits · Curriculum: Sem \(sub.getSemester())")
                                        .font(.caption).foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Image(systemName: selected.contains(sub.getID())
                                  ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selected.contains(sub.getID()) ? Theme.enrollment : .gray)
                        }
                    }
                }
                Button("✓ Select all from curriculum semester") {
                    selected = Set(manager.subjects
                        .filter { $0.getSemester() == semester }
                        .map { $0.getID() })
                }
                .foregroundColor(Theme.enrollment)
            } header: {
                SectionTag("Subjects to take this semester", systemImage: "checklist", color: Theme.enrollment)
            }
            .listRowBackground(Color.white.opacity(0.95))

            Section {
                Button("Enroll \(selected.count) subject(s)") { register() }
                    .disabled(studentID.isEmpty || selected.isEmpty)
                    .bold()
            }
            .listRowBackground(Color.white.opacity(0.95))

            if !studentID.isEmpty {
                Section {
                    let current = manager.records(ofStudent: studentID)
                        .filter { $0.getSemester() == semester }
                    if current.isEmpty {
                        Text("No subjects registered yet.").foregroundColor(.gray)
                    }
                    ForEach(current) { r in
                        HStack(spacing: 8) {
                            IDChip(text: r.getSubjectID(), color: Theme.enrollment)
                            Text(manager.subject(withID: r.getSubjectID())?.getName() ?? "?")
                        }
                    }
                } header: {
                    SectionTag("Already enrolled in Semester \(semester)",
                               systemImage: "checkmark.seal.fill", color: Theme.success)
                }
                .listRowBackground(Color.white.opacity(0.95))
            }
        }
        .scrollContentBackground(.hidden)
        .messageAlert("Result", message: $message)
    }

    private func toggle(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }

    private func register() {
        let result = manager.enroll(studentID: studentID,
                                    subjectIDs: selected.sorted(),
                                    semester: semester)
        var lines = ["✅ Enrolled: \(result.added) subject(s)."]
        lines += result.errors.map { "• " + $0 }
        message = lines.joined(separator: "\n")
        selected.removeAll()
    }
}

// MARK: - Ngăn 2: Nhập điểm
struct MarksContent: View {
    @EnvironmentObject var manager: SchoolManager
    @Binding var studentID: String
    @State private var message: String?

    var body: some View {
        Form {
            Section {
                Picker("Student", selection: $studentID) {
                    Text("— Select —").tag("")
                    ForEach(manager.students) { s in
                        Text("\(s.getID()) – \(s.getName())").tag(s.getID())
                    }
                }
            } header: {
                SectionTag("Select Student", systemImage: "person.fill", color: Theme.marks)
            }
            .listRowBackground(Color.white.opacity(0.95))

            if !studentID.isEmpty {
                Section {
                    HStack {
                        MetricBlock(label: "Credits",
                                    value: "\(manager.totalCredits(ofStudent: studentID))")
                        Spacer()
                        MetricBlock(label: "Average",
                                    value: manager.averageMark(ofStudent: studentID).map { String(format: "%.2f", $0) } ?? "—",
                                    color: Theme.subjects)
                        Spacer()
                        MetricBlock(label: "GPA",
                                    value: manager.gpa(of: studentID).map { String(format: "%.2f", $0) } ?? "—",
                                    color: Theme.gold)
                    }
                    .padding(.vertical, 8)
                } header: {
                    SectionTag("Summary", systemImage: "chart.pie.fill", color: Theme.marks)
                }
                .listRowBackground(Color.white.opacity(0.95))

                Section {
                    let recs = manager.records(ofStudent: studentID)
                    if recs.isEmpty {
                        Text("No enrollment records.").foregroundColor(.gray)
                    }
                    ForEach(recs) { r in
                        MarkRow(record: r) { message = $0 }
                    }
                } header: {
                    SectionTag("Marks (0 – 10)", systemImage: "pencil.and.list.clipboard", color: Theme.marks)
                }
                .listRowBackground(Color.white.opacity(0.95))
            }
        }
        .scrollContentBackground(.hidden)
        .messageAlert("Notice", message: $message)
    }
}

struct MarkRow: View {
    @EnvironmentObject var manager: SchoolManager
    let record: StudentSubject
    let onMessage: (String) -> Void
    @State private var text = ""

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(manager.subject(withID: record.getSubjectID())?.getName() ?? record.getSubjectID())
                    .font(.headline)
                HStack(spacing: 6) {
                    IDChip(text: record.getSubjectID(), color: Theme.marks)
                    Text("Semester \(record.getSemester())").font(.caption).foregroundColor(.gray)
                }
            }
            Spacer()
            TextField("Mark", text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)
                .multilineTextAlignment(.center)
            Button("Save") { save() }
                .buttonStyle(.borderless).foregroundColor(Theme.marks)
        }
        .onAppear {
            text = record.isGraded() ? String(format: "%.1f", record.getMark()) : ""
        }
    }

    private func save() {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else {
            onMessage("Mark must be a number.")
            return
        }
        do {
            try manager.updateMark(recordID: record.id, mark: value)
            onMessage("✅ Mark saved.")
        } catch { onMessage(error.localizedDescription) }
    }
}

#Preview {
    RecordsView().environmentObject(SchoolManager.preview())
}
