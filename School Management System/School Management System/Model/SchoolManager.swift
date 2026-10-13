import Foundation
import Combine

final class SchoolManager: ObservableObject {
    // Dùng private(set) để UI chỉ đọc, không sửa trực tiếp
    @Published private(set) var students: [Student] = []
    @Published private(set) var subjects: [Subject] = []
    @Published private(set) var studentSubjects: [StudentSubject] = []
    
    static let passMark = 5.0        // Dưới 5 là rớt
    static let excellentGPA = 8.0    // Trên 8 là giỏi
    
    init(sample: Bool = false) {
        if sample { loadSampleData() }
    }
    
    // MARK: - Tra cứu
    func student(withID id: String) -> Student? {
        students.first { $0.getID() == id }
    }
    
    func subject(withID id: String) -> Subject? {
        subjects.first { $0.getID() == id }
    }
    
    func records(ofStudent id: String) -> [StudentSubject] {
        studentSubjects
            .filter { $0.getStudentID() == id }
            .sorted { $0.getSemester() < $1.getSemester() }
    }
    
    // MARK: - Thêm sinh viên
    func addStudent(id: String, name: String, address: String, entranceYear: Int) throws {
        let cleanID = id.trimmingCharacters(in: .whitespaces)
        guard !cleanID.isEmpty else { throw SchoolError.emptyField("Mã sinh viên") }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SchoolError.emptyField("Tên sinh viên")
        }
        guard student(withID: cleanID) == nil else {
            throw SchoolError.duplicateStudent(cleanID)
        }
        students.append(Student(id: cleanID, name: name, address: address, entranceYear: entranceYear))
    }
    
    // MARK: - Thêm môn học
    func addSubject(id: String, name: String, credits: Int, semester: Int) throws {
        let cleanID = id.trimmingCharacters(in: .whitespaces)
        guard !cleanID.isEmpty else { throw SchoolError.emptyField("Mã môn học") }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SchoolError.emptyField("Tên môn học")
        }
        guard credits > 0 else { throw SchoolError.invalidCredits(credits) }
        guard (1...8).contains(semester) else { throw SchoolError.invalidSemester(semester) }
        guard subject(withID: cleanID) == nil else {
            throw SchoolError.duplicateSubject(cleanID)
        }
        subjects.append(Subject(id: cleanID, name: name, credits: credits, semester: semester))
    }
    
    // MARK: - 🎯 ĐĂNG KÝ (RÀNG BUỘC CHÍNH)
    // Chỉ tạo StudentSubject khi cả SV và môn đều tồn tại!
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
    
    // Đăng ký 1 môn (private - chỉ dùng bên trong)
    private func enrollOne(studentID: String, subjectID: String, semester: Int) throws {
        // Ràng buộc 1: SV phải tồn tại
        guard student(withID: studentID) != nil else {
            throw SchoolError.studentNotFound(studentID)
        }
        // Ràng buộc 2: Môn phải tồn tại
        guard subject(withID: subjectID) != nil else {
            throw SchoolError.subjectNotFound(subjectID)
        }
        // Ràng buộc 3: Kì hợp lệ
        guard (1...8).contains(semester) else {
            throw SchoolError.invalidSemester(semester)
        }
        // Ràng buộc 4: Không trùng
        let exists = studentSubjects.contains {
            $0.getStudentID() == studentID &&
            $0.getSubjectID() == subjectID &&
            $0.getSemester() == semester
        }
        guard !exists else {
            throw SchoolError.duplicateEnrollment(studentID, subjectID, semester)
        }
        // Vượt qua hết → tạo
        studentSubjects.append(
            StudentSubject(idStudent: studentID, idSubject: subjectID, semester: semester)
        )
    }
    
    // MARK: - Cập nhật điểm
    func updateMark(recordID: UUID, mark: Double) throws {
        guard (0.0...10.0).contains(mark) else { throw SchoolError.invalidMark(mark) }
        guard let record = studentSubjects.first(where: { $0.id == recordID }) else { return }
        record.setMark(mark)
        objectWillChange.send()   // Báo UI cập nhật
    }
    
    // MARK: - GPA (có trọng số theo tín chỉ)
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
    
    // MARK: - THỐNG KÊ (a): SV có GPA > 8
    func studentsWithGPAAbove(_ threshold: Double = SchoolManager.excellentGPA) -> [(student: Student, gpa: Double)] {
        students.compactMap { s in
            guard let g = gpa(of: s.getID()), g > threshold else { return nil }
            return (s, g)
        }
        .sorted { $0.gpa > $1.gpa }
    }
    
    // MARK: - THỐNG KÊ (b): SV rớt theo từng môn
    // Trả về mảng tuple: (Subject, [(Student, mark)])
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
    
    // MARK: - Sample data cho Preview + chạy app
    private func loadSampleData() {
        // ===== 5 MÔN HỌC =====
        let ios     = Subject(id: "CSE101", name: "iOS Programming",   credits: 3, semester: 4)
        let dsa     = Subject(id: "CSE201", name: "Data Structures",   credits: 4, semester: 3)
        let algo    = Subject(id: "CSE301", name: "Algorithms",        credits: 3, semester: 5)
        let db      = Subject(id: "CSE202", name: "Database Systems",  credits: 3, semester: 3)
        let network = Subject(id: "CSE302", name: "Computer Networks", credits: 3, semester: 5)
        subjects = [ios, dsa, algo, db, network]
        
        // ===== 5 SINH VIÊN =====
        students = [
            Student(id: "SV001", name: "Nguyễn Ánh",   address: "HCM",     entranceYear: 2023),
            Student(id: "SV002", name: "Phạm Bảo",  address: "Hà Nội",  entranceYear: 2023),
            Student(id: "SV003", name: "Trần Đông",   address: "Đà Nẵng", entranceYear: 2023),
            Student(id: "SV004", name: "Hạ Cẩm", address: "Huế",   entranceYear: 2023),
            Student(id: "SV005", name: "Cao Khánh",  address: "Cần Thơ", entranceYear: 2024)
        ]
        
        // ===== ĐĂNG KÝ MÔN =====
        // SV001: học 4 môn ở nhiều kì (SV giỏi)
        _ = enroll(studentID: "SV001", subjectIDs: ["CSE101", "CSE201", "CSE202", "CSE301"], semester: 4)
        
        // SV002: học 3 môn (SV trung bình)
        _ = enroll(studentID: "SV002", subjectIDs: ["CSE101", "CSE201", "CSE202"], semester: 4)
        
        // SV003: học 2 môn (có rớt)
        _ = enroll(studentID: "SV003", subjectIDs: ["CSE101", "CSE201"], semester: 4)
        
        // SV004: học 3 môn (SV khá)
        _ = enroll(studentID: "SV004", subjectIDs: ["CSE101", "CSE301", "CSE302"], semester: 4)
        
        // SV005: CHƯA đăng ký môn nào → thấy empty state
        
        // ===== GÁN ĐIỂM =====
        for r in studentSubjects {
            switch (r.getStudentID(), r.getSubjectID()) {
            // SV001 - SV giỏi, GPA > 8
            case ("SV001", "CSE101"): r.setMark(9.0)
            case ("SV001", "CSE201"): r.setMark(8.5)
            case ("SV001", "CSE202"): r.setMark(8.0)
            case ("SV001", "CSE301"): r.setMark(9.5)
            // → GPA ≈ (9*3 + 8.5*4 + 8*3 + 9.5*3) / 13 = 111.5/13 ≈ 8.58 ✅
            
            // SV002 - Trung bình
            case ("SV002", "CSE101"): r.setMark(4.0)   // ❌ rớt
            case ("SV002", "CSE201"): r.setMark(6.5)
            case ("SV002", "CSE202"): r.setMark(7.0)
            
            // SV003 - Có rớt
            case ("SV003", "CSE101"): r.setMark(3.5)   // ❌ rớt
            case ("SV003", "CSE201"): r.setMark(5.0)   // đủ pass
            
            // SV004 - SV khá, GPA > 8
            case ("SV004", "CSE101"): r.setMark(9.0)
            case ("SV004", "CSE301"): r.setMark(8.0)
            case ("SV004", "CSE302"): r.setMark(8.5)
            // → GPA = (9*3 + 8*3 + 8.5*3) / 9 = 76.5/9 ≈ 8.5 ✅
            
            // SV005: chưa có gì
            
            default: break
            }
        }
        // Lưu ý: 1 môn (CSE101) còn chưa gán điểm cho SV nào khác → test "chưa có điểm"
    }
}

// MARK: - ===== EXTENDED PRACTICES =====
extension SchoolManager {
    
    // MARK: Slide 4 - Student
    /// SV xuất sắc (GPA >= 8.0)
    func excellentStudents(threshold: Double = 8.0) -> [(Student, Double)] {
        students.compactMap { s in
            guard let g = gpa(of: s.getID()), g >= threshold else { return nil }
            return (s, g)
        }.sorted { $0.1 > $1.1 }
    }
    
    /// Tìm SV theo keyword (ID hoặc tên)
    func searchStudents(_ keyword: String) -> [Student] {
        let k = keyword.lowercased()
        return students.filter {
            $0.getID().lowercased().contains(k) ||
            $0.getName().lowercased().contains(k)
        }
    }
    
    /// SV theo khóa (năm nhập học)
    func students(inYear year: Int) -> [Student] {
        students.filter { $0.getEntranceYear() == year }
    }
    
    /// Sắp xếp SV theo GPA giảm dần
    func studentsSortedByGPADesc() -> [(Student, Double)] {
        students.compactMap { s in
            gpa(of: s.getID()).map { (s, $0) }
        }.sorted { $0.1 > $1.1 }
    }
    
    // MARK: Slide 5 - Subject
    /// Cập nhật thông tin môn học
    func updateSubject(id: String, newName: String, newCredits: Int, newSemester: Int) throws {
        guard let sub = subject(withID: id) else {
            throw SchoolError.subjectNotFound(id)
        }
        guard newCredits > 0 else { throw SchoolError.invalidCredits(newCredits) }
        guard (1...8).contains(newSemester) else { throw SchoolError.invalidSemester(newSemester) }
        sub.setName(newName)
        sub.setCredits(newCredits)
        sub.setSemester(newSemester)
        objectWillChange.send()
    }
    
    /// Môn theo học kỳ CTĐT
    func subjects(inSemester sem: Int) -> [Subject] {
        subjects.filter { $0.getSemester() == sem }
    }
    
    /// Môn sắp xếp theo tín chỉ giảm dần
    func subjectsSortedByCreditsDesc() -> [Subject] {
        subjects.sorted { $0.getCredits() > $1.getCredits() }
    }
    
    // MARK: Slide 7 - StudentSubject
    /// Tổng tín chỉ SV đã đăng ký
    func totalCredits(ofStudent id: String) -> Int {
        records(ofStudent: id).reduce(0) { sum, r in
            sum + (subject(withID: r.getSubjectID())?.getCredits() ?? 0)
        }
    }
    
    /// Điểm trung bình (không trọng số) của SV
    func averageMark(ofStudent id: String) -> Double? {
        let graded = records(ofStudent: id).filter { $0.isGraded() }
        guard !graded.isEmpty else { return nil }
        let sum = graded.reduce(0.0) { $0 + $1.getMark() }
        return sum / Double(graded.count)
    }
}
