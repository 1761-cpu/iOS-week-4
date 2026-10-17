import SwiftUI

enum TeacherSort { case name, credits }

struct TeachersView: View {
    @EnvironmentObject var manager: SchoolManager
    @State private var showAddSheet = false
    @State private var searchText = ""
    @State private var sort: TeacherSort = .name
    
    var displayedTeachers: [Teacher] {
        let k = searchText.lowercased()
        let filtered = k.isEmpty ? manager.teachers : manager.teachers.filter { t in
            t.getName().lowercased().contains(k) || t.getID().lowercased().contains(k) || t.getDepartment().lowercased().contains(k) || t.getSubjects().contains { $0.getID().lowercased().contains(k) }
        }
        switch sort {
        case .name: return filtered.sorted { $0.getName() < $1.getName() }
        case .credits: return filtered.sorted { manager.totalCredits(ofTeacher: $0) > manager.totalCredits(ofTeacher: $1) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchField(placeholder: "Search name, ID, department or subject ID...", text: $searchText)
                
                List {
                    if displayedTeachers.isEmpty {
                        EmptyHint(systemImage: "person.crop.circle.badge.questionmark", text: "No teachers found.").listRowCard()
                    }
                    ForEach(displayedTeachers) { t in
                        TeacherCard(teacher: t).listRowCard()
                    }
                }
                .listStyle(.plain)
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(title: "TEACHERS", glassTint: Theme.teachers.opacity(0.9), topPadding: 20, bottomPadding: 20) {
                    Menu {
                        Picker("Sort", selection: $sort) {
                            Text("Name (A–Z)").tag(TeacherSort.name)
                            Text("Total credits (high → low)").tag(TeacherSort.credits)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill").font(.title3).foregroundColor(Theme.teachers)
                    }
                    
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title3).foregroundColor(Theme.teachers)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) { AddTeacherView().environmentObject(manager) }
            .screenBackground("teachView", fit: true, topOffset: 215)
        }
    }
}

// MARK: - Add Teacher Pop-up
struct AddTeacherView: View {
    @EnvironmentObject var manager: SchoolManager
    @Environment(\.dismiss) var dismiss
    
    @State private var id = ""
    @State private var name = ""
    @State private var department = ""
    @State private var message: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Teacher ID (e.g., T004)", text: $id).textInputAutocapitalization(.characters)
                    TextField("Full Name (e.g., TS. Nguyễn Văn A)", text: $name)
                    TextField("Department", text: $department)
                } header: {
                    SectionTag("Teacher Info", systemImage: "graduationcap.fill", color: Theme.teachers)
                }
                .listRowBackground(Color.white.opacity(0.85))
                
                Section {
                    Text("After saving, use “Edit assignments” on the teacher’s card to choose the subjects they can teach.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .listRowBackground(Color.white.opacity(0.85))
            }
            .centeredTitle("ADD TEACHER")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }
                        .foregroundColor(.black)}
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }
                        .bold()
                        .foregroundColor(Color(hex: "#059669"))}
            }
            .messageAlert("Notice", message: $message)
        }
    }
    
    private func save() {
        do {
            try manager.addTeacher(id: id, name: name, department: department)
            dismiss()
        } catch { message = error.localizedDescription }
    }
}

#Preview {
    TeachersView().environmentObject(SchoolManager.preview())
}
