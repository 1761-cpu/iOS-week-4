import SwiftUI

struct StudentsView: View {
    @EnvironmentObject var manager: SchoolManager
    @State private var showAddSheet = false
    @State private var message: String?
    @State private var searchText = ""
    
    var displayedStudents: [Student] {
        searchText.isEmpty ? manager.students : manager.searchStudents(searchText)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                // Search bar
                TextField("Search by name or ID...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                
                List {
                    ForEach(displayedStudents) { s in
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(s.getName()).font(.headline)

                                Text("\(s.getID()) • \(s.getAddress()) • Class of \(String(s.getEntranceYear()))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                if let g = manager.gpa(of: s.getID()) {
                                    Text("GPA: \(String(format: "%.2f", g))")
                                        .font(.subheadline).bold()
                                        .foregroundColor(g >= 8 ? .green : .blue)
                                } else {
                                    Text("No GPA yet")
                                        .font(.subheadline).italic()
                                        .foregroundColor(.gray)
                                }
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .listRowCard()
                    }
                }
                .listStyle(.plain)
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(title: "STUDENTS",
                       glassTint: .blue.opacity(0.9),
                       topPadding: 20,          // cách mép trên (dưới Dynamic Island)
                       bottomPadding: 20) {
                   Menu {
                       Button {
                           let list = manager.studentsSortedByGPADesc()
                           message = list.isEmpty
                               ? "No students."
                               : list.map { "\($0.0.getID()) \($0.0.getName()) – GPA \(String(format: "%.2f", $0.1))" }
                                   .joined(separator: "\n")
                       } label: { Label("Sort by GPA (desc)", systemImage: "arrow.down") }

                       Button {
                           let list = manager.excellentStudents()
                           message = list.isEmpty
                               ? "No excellent students."
                               : list.map { "\($0.0.getName()) – \(String(format: "%.2f", $0.1))" }
                                   .joined(separator: "\n")
                       } label: { Label("Excellent (GPA ≥ 8)", systemImage: "star.fill") }

                       Button {
                           let list = manager.students(inYear: 2023)
                           message = list.isEmpty
                               ? "No students in 2023."
                               : list.map { $0.getName() }.joined(separator: "\n")
                       } label: { Label("Students in 2023", systemImage: "calendar") }
                   } label: {
                       Image(systemName: "ellipsis.circle.fill").font(.title3).foregroundColor(.blue)
                   }

                   Button { showAddSheet = true } label: {
                       Image(systemName: "plus.circle.fill").font(.title3).foregroundColor(.blue)
                   }
               }
               
           }
           .sheet(isPresented: $showAddSheet) { AddStudentView().environmentObject(manager) }
           .messageAlert("Result", message: $message)
           .screenBackground("stuView1", fit: true, topOffset: 220)
       }
    }
}

// MARK: - Add Student Pop-up
struct AddStudentView: View {
    @EnvironmentObject var manager: SchoolManager
    @Environment(\.dismiss) var dismiss
    
    @State private var id = ""
    @State private var name = ""
    @State private var address = ""
    @State private var yearText = ""
    @State private var message: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Student ID (e.g., SV006)", text: $id)
                        .textInputAutocapitalization(.characters)
                    TextField("Full Name", text: $name)
                    TextField("Address", text: $address)
                    TextField("Entrance Year (e.g., 2024)", text: $yearText)
                        .keyboardType(.numberPad)
                } header: {
                    SectionTag("Student Info", systemImage: "person.text.rectangle", color: .blue)
                }
                .listRowBackground(Color.white.opacity(0.85))
            }
            .centeredTitle("ADD STUDENT", color: .blue)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel",) { dismiss() }
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.blue)
                        .bold()
                }
            }
            .messageAlert("Notice", message: $message)
        }
    }
    
    private func save() {
        guard let year = Int(yearText) else {
            message = "Entrance year must be a number."
            return
        }
        do {
            try manager.addStudent(id: id, name: name, address: address, entranceYear: year)
            dismiss()
        } catch { message = error.localizedDescription }
    }
}

#Preview {
    StudentsView().environmentObject(SchoolManager.preview())
}
