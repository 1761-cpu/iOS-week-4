import Foundation

class Teacher: Identifiable {
    // MARK: - Properties
    var id: String
    private var name: String
    private var subjects: [Subject]      // Danh sách môn giáo viên có thể dạy
    private var department: String

    // MARK: - Constructors
    init() {
        self.id = ""
        self.name = ""
        self.subjects = []
        self.department = ""
    }

    init(id: String, name: String, subjects: [Subject], department: String) {
        self.id = id
        self.name = name
        self.subjects = subjects
        self.department = department
    }

    // MARK: - Methods
    // Getters
    func getID() -> String { return id }
    func getName() -> String { return name }
    func getSubjects() -> [Subject] { return subjects }
    func getDepartment() -> String { return department }

    // Setters
    func setID(_ newID: String) { self.id = newID }
    func setName(_ newName: String) { self.name = newName }
    func setSubjects(_ newSubjects: [Subject]) { self.subjects = newSubjects }
    func setDepartment(_ newDept: String) { self.department = newDept }

    // Display
    func displayInfo() {
        print("Teacher: ID=\(id), Name=\(name), Department=\(department)")
        print("Subjects taught:")
        for s in subjects {
            print("  - [\(s.getID())] \(s.getName()) (\(s.getCredits()) credits, Semester \(s.getSemester()))")
        }
    }

    // Add - Remove subject
    func addSubject(_ subject: Subject) {
        guard !subjects.contains(where: { $0.getID() == subject.getID() }) else { return }
        subjects.append(subject)
    }

    func removeSubject(byID id: String) {
        subjects.removeAll { $0.getID() == id }
    }
}
