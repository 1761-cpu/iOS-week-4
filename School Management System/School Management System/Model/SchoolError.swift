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

