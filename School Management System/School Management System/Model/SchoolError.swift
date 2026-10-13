//
//  SchoolError.swift
//  School Management System
//
//  Created by MAY 04 on 12/10/26.
//


import Foundation

// MARK: - Lỗi có thể xảy ra
enum SchoolError: LocalizedError {
    case emptyField(String)
    case duplicateStudent(String)
    case duplicateSubject(String)
    case studentNotFound(String)
    case subjectNotFound(String)
    case invalidCredits(Int)
    case invalidSemester(Int)
    case invalidMark(Double)
    case duplicateEnrollment(String, String, Int)
    
    var errorDescription: String? {
        switch self {
        case .emptyField(let f):
            return "\(f) không được để trống."
        case .duplicateStudent(let id):
            return "Mã sinh viên \(id) đã tồn tại."
        case .duplicateSubject(let id):
            return "Mã môn học \(id) đã tồn tại."
        case .studentNotFound(let id):
            return "Không tìm thấy sinh viên \(id)."
        case .subjectNotFound(let id):
            return "Không tìm thấy môn học \(id)."
        case .invalidCredits(let c):
            return "Số tín chỉ \(c) phải > 0."
        case .invalidSemester(let s):
            return "Học kỳ \(s) phải từ 1 đến 8."
        case .invalidMark(let m):
            return "Điểm \(m) phải từ 0 đến 10."
        case .duplicateEnrollment(let sv, let mh, let k):
            return "Sinh viên \(sv) đã đăng ký môn \(mh) ở kỳ \(k)."
        }
    }
}

// MARK: - STUDENT
class Student: Identifiable {
    var id: String
    private var name: String
    private var address: String
    private var entranceYear: Int
    
    init(id: String, name: String, address: String, entranceYear: Int) {
        self.id = id
        self.name = name
        self.address = address
        self.entranceYear = entranceYear
    }
    
    func getID() -> String { id }
    func getName() -> String { name }
    func getAddress() -> String { address }
    func getEntranceYear() -> Int { entranceYear }
    
    func setName(_ v: String) { name = v }
    func setAddress(_ v: String) { address = v }
    func setEntranceYear(_ v: Int) { entranceYear = v }
    
    func displayInfo() -> String {
        "SV[\(id)] \(name) - \(address) - Khóa \(entranceYear)"
    }
}

// MARK: - SUBJECT
class Subject: Identifiable {
    var id: String
    private var name: String
    private var credits: Int
    private var semester: Int   // Kì nên học theo CTĐT (1...8)
    
    init(id: String, name: String, credits: Int, semester: Int) {
        self.id = id
        self.name = name
        self.credits = credits
        self.semester = semester
    }
    
    func getID() -> String { id }
    func getName() -> String { name }
    func getCredits() -> Int { credits }
    func getSemester() -> Int { semester }
    
    func setName(_ v: String) { name = v }
    func setCredits(_ v: Int) { credits = v }
    func setSemester(_ v: Int) { semester = v }
    
    func displayInfo() -> String {
        "Môn[\(id)] \(name) - \(credits) TC - Kì \(semester)"
    }
}

// MARK: - TEACHER
class Teacher: Identifiable {
    var id: String
    private var name: String
    private var subjects: [Subject]   // Mảng môn có thể dạy
    private var department: String
    
    init(id: String, name: String, subjects: [Subject], department: String) {
        self.id = id
        self.name = name
        self.subjects = subjects
        self.department = department
    }
    
    func getID() -> String { id }
    func getName() -> String { name }
    func getSubjects() -> [Subject] { subjects }
    func getDepartment() -> String { department }
    
    func setName(_ v: String) { name = v }
    func setDepartment(_ v: String) { department = v }
    func addSubject(_ s: Subject) { subjects.append(s) }
    func removeSubject(byID id: String) { subjects.removeAll { $0.id == id } }
    
    func displayInfo() -> String {
        let list = subjects.map { $0.getName() }.joined(separator: ", ")
        return "GV[\(id)] \(name) - \(department) - Dạy: [\(list)]"
    }
}

// MARK: - STUDENTSUBJECT (điểm của SV cho 1 môn)
class StudentSubject: Identifiable {
    var id = UUID()
    private var idStudent: String
    private var idSubject: String
    private var mark: Double
    private var semester: Int
    private var graded: Bool   // false = chưa có điểm, true = đã có
    
    // Init đơn giản - ràng buộc do SchoolManager lo
    init(idStudent: String, idSubject: String, semester: Int, mark: Double? = nil) {
        self.idStudent = idStudent
        self.idSubject = idSubject
        self.semester = semester
        self.mark = mark ?? 0.0
        self.graded = (mark != nil)
    }
    
    func getStudentID() -> String { idStudent }
    func getSubjectID() -> String { idSubject }
    func getMark() -> Double { mark }
    func getSemester() -> Int { semester }
    func isGraded() -> Bool { graded }
    
    func setMark(_ v: Double) {
        mark = v
        graded = true   // Khi set điểm → đánh dấu đã có điểm
    }
    
    func displayInfo() -> String {
        let markText = graded ? String(format: "%.1f", mark) : "chưa có"
        return "SV \(idStudent) - Môn \(idSubject) - Kì \(semester) - Điểm: \(markText)"
    }
}