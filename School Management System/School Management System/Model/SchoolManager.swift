import Foundation
import Combine

final class SchoolManager: ObservableObject {
    // MARK: - Thuộc tính (Data)
    @Published private(set) var students: [Student] = []
    @Published private(set) var subjects: [Subject] = []
    @Published private(set) var studentSubjects: [StudentSubject] = []
    @Published private(set) var teachers: [Teacher] = []
    
    static let passMark = 5.0
    static let excellentGPA = 8.0
    
    init(sample: Bool = false) {
        if sample { loadSampleData() }
    }
    
    // MARK: - 1. LOOKUP (Hàm tra cứu)
    func student(withID id: String) -> Student? { students.first { $0.getID() == id } }
    func subject(withID id: String) -> Subject? { subjects.first { $0.getID() == id } }
    func teacher(withID id: String) -> Teacher? { teachers.first { $0.getID() == id } }
    
    func records(ofStudent id: String) -> [StudentSubject] {
        studentSubjects
            .filter { $0.getStudentID() == id }
            .sorted { $0.getSemester() < $1.getSemester() }
    }
    
    // MARK: - 2. ADD DATA (Hàm thêm mới)
    func addStudent(id: String, name: String, address: String, entranceYear: Int) throws {
        let cleanID = id.trimmingCharacters(in: .whitespaces)
        guard !cleanID.isEmpty else { throw SchoolError.emptyField("Student ID") }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { throw SchoolError.emptyField("Student Name") }
        guard student(withID: cleanID) == nil else { throw SchoolError.duplicateStudent(cleanID) }
        
        students.append(Student(id: cleanID, name: name, address: address, entranceYear: entranceYear))
    }
    
    func addSubject(id: String, name: String, credits: Int, semester: Int) throws {
        let cleanID = id.trimmingCharacters(in: .whitespaces)
        guard !cleanID.isEmpty else { throw SchoolError.emptyField("Subject ID") }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { throw SchoolError.emptyField("Subject Name") }
        guard credits > 0 else { throw SchoolError.invalidCredits(credits) }
        guard (1...8).contains(semester) else { throw SchoolError.invalidSemester(semester) }
        guard subject(withID: cleanID) == nil else { throw SchoolError.duplicateSubject(cleanID) }
        
        subjects.append(Subject(id: cleanID, name: name, credits: credits, semester: semester))
    }
    
    func addTeacher(id: String, name: String, department: String) throws {
        let cleanID = id.trimmingCharacters(in: .whitespaces)
        guard !cleanID.isEmpty else { throw SchoolError.emptyField("Teacher ID") }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { throw SchoolError.emptyField("Teacher Name") }
        guard teacher(withID: cleanID) == nil else { throw SchoolError.duplicateTeacher(cleanID) }
        
        teachers.append(Teacher(id: cleanID, name: name, subjects: [], department: department))
    }
    
    // MARK: - 3. UPDATE DATA (Hàm cập nhật)
    func toggleSubject(_ subjectID: String, forTeacher teacherID: String) throws {
        guard let t = teacher(withID: teacherID) else { throw SchoolError.teacherNotFound(teacherID) }
        guard let s = subject(withID: subjectID) else { throw SchoolError.subjectNotFound(subjectID) }
        
        if t.getSubjects().contains(where: { $0.getID() == subjectID }) {
            t.removeSubject(byID: subjectID)
        } else {
            t.addSubject(s)
        }
        objectWillChange.send()
    }
    
    func updateSubject(id: String, newName: String, newCredits: Int, newSemester: Int) throws {
        guard let sub = subject(withID: id) else { throw SchoolError.subjectNotFound(id) }
        guard newCredits > 0 else { throw SchoolError.invalidCredits(newCredits) }
        guard (1...8).contains(newSemester) else { throw SchoolError.invalidSemester(newSemester) }
        
        sub.setName(newName)
        sub.setCredits(newCredits)
        sub.setSemester(newSemester)
        objectWillChange.send()
    }
    
    func updateMark(recordID: UUID, mark: Double) throws {
        guard (0.0...10.0).contains(mark) else { throw SchoolError.invalidMark(mark) }
        guard let record = studentSubjects.first(where: { $0.id == recordID }) else { return }
        
        record.setMark(mark)
        objectWillChange.send()
    }
    
    // MARK: - 4. ENROLLMENT (Đăng ký môn & Ràng buộc)
    func enroll(studentID: String, subjectIDs: [String], semester: Int) -> (added: Int, errors: [String]) {
        var added = 0
        var errors: [String] = []
        
        for sid in subjectIDs {
            do {
                try enrollOne(studentID: studentID, subjectID: sid, semester: semester)
                added += 1
            } catch {
                errors.append(error.localizedDescription)
            }
        }
        return (added, errors)
    }
    
    private func enrollOne(studentID: String, subjectID: String, semester: Int) throws {
        guard student(withID: studentID) != nil else { throw SchoolError.studentNotFound(studentID) }
        guard subject(withID: subjectID) != nil else { throw SchoolError.subjectNotFound(subjectID) }
        guard (1...8).contains(semester) else { throw SchoolError.invalidSemester(semester) }
        
        let exists = studentSubjects.contains {
            $0.getStudentID() == studentID && $0.getSubjectID() == subjectID && $0.getSemester() == semester
        }
        guard !exists else { throw SchoolError.duplicateEnrollment(studentID, subjectID, semester) }
        
        studentSubjects.append(StudentSubject(idStudent: studentID, idSubject: subjectID, semester: semester))
    }
    
    // MARK: - 5. STATISTICS & GPA (Thống kê)
    func gpa(of studentID: String) -> Double? {
        var totalPoints = 0.0
        var totalCredits = 0.0
        
        for r in records(ofStudent: studentID) where r.isGraded() {
            guard let sub = subject(withID: r.getSubjectID()) else { continue }
            totalPoints += r.getMark() * Double(sub.getCredits())
            totalCredits += Double(sub.getCredits())
        }
        return totalCredits > 0 ? totalPoints / totalCredits : nil
    }
    
    func averageMark(ofStudent id: String) -> Double? {
        let graded = records(ofStudent: id).filter { $0.isGraded() }
        guard !graded.isEmpty else { return nil }
        let sum = graded.reduce(0.0) { $0 + $1.getMark() }
        return sum / Double(graded.count)
    }
    
    func totalCredits(ofStudent id: String) -> Int {
        records(ofStudent: id).reduce(0) { sum, r in
            sum + (subject(withID: r.getSubjectID())?.getCredits() ?? 0)
        }
    }
    
    func studentsWithGPAAbove(_ threshold: Double = SchoolManager.excellentGPA) -> [(student: Student, gpa: Double)] {
        students.compactMap { s in
            guard let g = gpa(of: s.getID()), g > threshold else { return nil }
            return (s, g)
        }.sorted { $0.gpa > $1.gpa }
    }
    
    func failuresBySubject() -> [(subject: Subject, failures: [(student: Student, mark: Double)])] {
        subjects.map { sub in
            let fails = studentSubjects
                .filter { $0.getSubjectID() == sub.getID() && $0.isGraded() && $0.getMark() < SchoolManager.passMark }
                .compactMap { r -> (Student, Double)? in
                    guard let s = student(withID: r.getStudentID()) else { return nil }
                    return (s, r.getMark())
                }
            return (sub, fails)
        }
    }
    
    // MARK: - 6. EXTENDED PRACTICES (Bài tập mở rộng)
    func excellentStudents(threshold: Double = 8.0) -> [(Student, Double)] {
        students.compactMap { s in
            guard let g = gpa(of: s.getID()), g >= threshold else { return nil }
            return (s, g)
        }.sorted { $0.1 > $1.1 }
    }
    
    func searchStudents(_ keyword: String) -> [Student] {
        let k = keyword.lowercased()
        return students.filter {
            $0.getID().lowercased().contains(k) || $0.getName().lowercased().contains(k)
        }
    }
    
    func students(inYear year: Int) -> [Student] {
        students.filter { $0.getEntranceYear() == year }
    }
    
    func studentsSortedByGPADesc() -> [(Student, Double)] {
        students.compactMap { s in
            gpa(of: s.getID()).map { (s, $0) }
        }.sorted { $0.1 > $1.1 }
    }
    
    func subjects(inSemester sem: Int) -> [Subject] {
        subjects.filter { $0.getSemester() == sem }
    }
    
    func subjectsSortedByCreditsDesc() -> [Subject] {
        subjects.sorted { $0.getCredits() > $1.getCredits() }
    }
    
    // MARK: - 7. CARD HELPERS (Hàm bổ trợ cho giao diện Thẻ)
    func teachersTeaching(subjectID id: String) -> [Teacher] {
        teachers.filter { t in t.getSubjects().contains { $0.getID() == id } }
    }
    
    func enrolledCount(inSubject id: String) -> Int {
        Set(studentSubjects.filter { $0.getSubjectID() == id }.map { $0.getStudentID() }).count
    }
    
    func gradedCount(inSubject id: String) -> Int {
        studentSubjects.filter { $0.getSubjectID() == id && $0.isGraded() }.count
    }
    
    func failedCount(inSubject id: String) -> Int {
        studentSubjects.filter {
            $0.getSubjectID() == id && $0.isGraded() && $0.getMark() < SchoolManager.passMark
        }.count
    }
    
    func totalCredits(ofTeacher teacher: Teacher) -> Int {
        teacher.getSubjects().reduce(0) { $0 + $1.getCredits() }
    }
    
    func studentCount(ofTeacher teacher: Teacher) -> Int {
        let ids = Set(teacher.getSubjects().map { $0.getID() })
        return Set(studentSubjects.filter { ids.contains($0.getSubjectID()) }.map { $0.getStudentID() }).count
    }
    
    // MARK: - 8. SAMPLE DATA
    private func loadSampleData() {
        let ios = Subject(id: "CSE101", name: "iOS Programming", credits: 3, semester: 4)
        let dsa = Subject(id: "CSE201", name: "Data Structures", credits: 4, semester: 3)
        let algo = Subject(id: "CSE301", name: "Algorithms", credits: 3, semester: 5)
        let db = Subject(id: "CSE202", name: "Database Systems", credits: 3, semester: 3)
        let network = Subject(id: "CSE302", name: "Computer Networks", credits: 3, semester: 5)
        subjects = [ios, dsa, algo, db, network]
        
        teachers = [
            Teacher(id: "T001", name: "TS. Diệp Dương", subjects: [ios, dsa], department: "Information Technology"),
            Teacher(id: "T002", name: "ThS. Lê Ninh", subjects: [algo, network], department: "Computer Science"),
            Teacher(id: "T003", name: "PGS.TS. Kim Mai", subjects: [db, dsa], department: "Artificial Security")
        ]
        
        students = [
            Student(id: "SV001", name: "Nguyễn Ánh", address: "HCM", entranceYear: 2023),
            Student(id: "SV002", name: "Phạm Bảo", address: "Hà Nội", entranceYear: 2023),
            Student(id: "SV003", name: "Trần Đông", address: "Đà Nẵng", entranceYear: 2023),
            Student(id: "SV004", name: "Hạ Cẩm", address: "Huế", entranceYear: 2023),
            Student(id: "SV005", name: "Cao Khánh", address: "Cần Thơ", entranceYear: 2024)
        ]
        
        _ = enroll(studentID: "SV001", subjectIDs: ["CSE101", "CSE201", "CSE202", "CSE301"], semester: 4)
        _ = enroll(studentID: "SV002", subjectIDs: ["CSE101", "CSE201", "CSE202"], semester: 4)
        _ = enroll(studentID: "SV003", subjectIDs: ["CSE101", "CSE201"], semester: 4)
        _ = enroll(studentID: "SV004", subjectIDs: ["CSE101", "CSE301", "CSE302"], semester: 4)
        
        for r in studentSubjects {
            switch (r.getStudentID(), r.getSubjectID()) {
            case ("SV001", "CSE101"): r.setMark(9.0)
            case ("SV001", "CSE201"): r.setMark(8.5)
            case ("SV001", "CSE202"): r.setMark(8.0)
            case ("SV001", "CSE301"): r.setMark(9.5)
            case ("SV002", "CSE101"): r.setMark(4.0)
            case ("SV002", "CSE201"): r.setMark(6.5)
            case ("SV002", "CSE202"): r.setMark(7.0)
            case ("SV003", "CSE101"): r.setMark(3.5)
            case ("SV003", "CSE201"): r.setMark(5.0)
            case ("SV004", "CSE101"): r.setMark(9.0)
            case ("SV004", "CSE301"): r.setMark(8.0)
            case ("SV004", "CSE302"): r.setMark(8.5)
            default: break
            }
        }
    }
}

extension SchoolManager {
    static func preview() -> SchoolManager {
        SchoolManager(sample: true)
    }
}
