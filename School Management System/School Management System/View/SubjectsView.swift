import SwiftUI

struct SubjectsView: View {
    @EnvironmentObject var manager: SchoolManager
    @State private var showAddSheet = false
    @State private var editingSubject: Subject?
    @State private var message: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                List {
                    ForEach(manager.subjects) { s in
                        Button {
                            editingSubject = s
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "book.circle.fill")
                                    .font(.system(size: 34))
                                    .foregroundColor(.brown)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(s.getName()).font(.headline)
                                    Text("ID: \(s.getID())")
                                        .font(.caption).italic().foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(s.getCredits()) Cr").bold()
                                    Text("Sem \(s.getSemester())")
                                        .font(.caption).foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .foregroundColor(.primary)
                        .listRowCard()
                    }
                }
                .listStyle(.plain)
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(title: "SUBJECTS",
                       glassTint: .brown.opacity(0.9),
                       topPadding: 20,
                       bottomPadding: 20) {
                    Menu {
                        Button {
                            let list = manager.subjectsSortedByCreditsDesc()
                            message = list.isEmpty
                                ? "No subjects."
                                : list.map { "\($0.getID()) \($0.getName()) – \($0.getCredits()) Cr" }
                                    .joined(separator: "\n")
                        } label: { Label("Sort by credits (desc)", systemImage: "arrow.down") }

                        Button {
                            let list = manager.subjects(inSemester: 3)
                            message = list.isEmpty
                                ? "No subjects in semester 3."
                                : list.map { "\($0.getID()) – \($0.getName())" }.joined(separator: "\n")
                        } label: { Label("Subjects in Semester 3", systemImage: "calendar") }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill").font(.title3).foregroundColor(.brown)
                    }

                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title3).foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) { AddSubjectView().environmentObject(manager) }
            .sheet(item: $editingSubject) { sub in EditSubjectView(subject: sub).environmentObject(manager) }
            .messageAlert("Result", message: $message)
            .screenBackground("subView", fit: true, topOffset: 158)
        }
    }
}

// MARK: - Add Subject Pop-up
struct AddSubjectView: View {
    @EnvironmentObject var manager: SchoolManager
    @Environment(\.dismiss) var dismiss
    
    @State private var id = ""
    @State private var name = ""
    @State private var creditsText = ""
    @State private var semester = 1
    @State private var message: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Subject ID (e.g., CSE401)", text: $id)
                        .textInputAutocapitalization(.characters)
                    TextField("Subject Name", text: $name)
                    TextField("Credits", text: $creditsText).keyboardType(.numberPad)
                    Picker("Curriculum Semester", selection: $semester) {
                        ForEach(1...8, id: \.self) { Text("Semester \($0)").tag($0) }
                    }
                } header: {
                    SectionTag("Subject Info", systemImage: "book.fill", color: .brown)
                }
                .listRowBackground(Color.white.opacity(0.85))
            }
            .centeredTitle("ADD SUBJECT", color: .brown)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.brown)
                        .bold()
                }
            }
            .messageAlert("Notice", message: $message)
        }
    }
    
    private func save() {
        guard let credits = Int(creditsText) else {
            message = "Credits must be a number."; return
        }
        do {
            try manager.addSubject(id: id, name: name, credits: credits, semester: semester)
            dismiss()
        } catch { message = error.localizedDescription }
    }
}

// MARK: - Edit Subject (Extended Practice: updateInfo)
struct EditSubjectView: View {
    @EnvironmentObject var manager: SchoolManager
    @Environment(\.dismiss) var dismiss
    
    let subject: Subject
    @State private var name: String
    @State private var credits: String
    @State private var semester: Int
    @State private var message: String?
    
    init(subject: Subject) {
        self.subject = subject
        _name = State(initialValue: subject.getName())
        _credits = State(initialValue: String(subject.getCredits()))
        _semester = State(initialValue: subject.getSemester())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Credits", text: $credits).keyboardType(.numberPad)
                    Picker("Curriculum Semester", selection: $semester) {
                        ForEach(1...8, id: \.self) { Text("Semester \($0)").tag($0) }
                    }
                } header: {
                    SectionTag("Update Info", systemImage: "square.and.pencil", color: .brown)
                }
                .listRowBackground(Color.white.opacity(0.85))
            }
            .centeredTitle("EDIT SUBJECT", color: .brown)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.brown)
                        .bold()
                }
            }
            .messageAlert("Notice", message: $message)
        }
    }
    
    private func save() {
        guard let c = Int(credits) else {
            message = "Credits must be a number."; return
        }
        do {
            try manager.updateSubject(id: subject.getID(),
                                       newName: name,
                                       newCredits: c,
                                       newSemester: semester)
            dismiss()
        } catch { message = error.localizedDescription }
    }
}


#Preview {
    SubjectsView().environmentObject(SchoolManager.preview())
}
