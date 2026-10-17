import Foundation

// MARK: - Định nghĩa các lỗi hệ thống
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
    case duplicateTeacher(String)
    case teacherNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyField(let f):
            return "\(f) cannot be empty."
        case .duplicateStudent(let id):
            return "Student ID \(id) already exists."
        case .duplicateSubject(let id):
            return "Subject ID \(id) already exists."
        case .studentNotFound(let id):
            return "Student with ID \(id) not found."
        case .subjectNotFound(let id):
            return "Subject with ID \(id) not found."
        case .invalidCredits(let c):
            return "Credits \(c) must be greater than 0."
        case .invalidSemester(let s):
            return "Semester \(s) must be between 1 and 8."
        case .invalidMark(let m):
            return "Mark \(m) must be between 0 and 10."
        case .duplicateEnrollment(let sv, let mh, let k):
            return "Student \(sv) is already enrolled in subject \(mh) for semester \(k)."
        case .duplicateTeacher(let id):
            return "Teacher ID \(id) already exists."
        case .teacherNotFound(let id):
            return "Teacher with ID \(id) not found."
        }
    }
}
