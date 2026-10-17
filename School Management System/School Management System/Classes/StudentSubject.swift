import Foundation

class StudentSubject: Identifiable {
    // MARK: - Properties
    var id = UUID()
    private var idStudent: String   // Khóa ngoại → Student.id
    private var idSubject: String   // Khóa ngoại → Subject.id
    private var mark: Double
    private var semester: Int       // Kì sinh viên thực tế học
    private var graded: Bool        // false = chưa có điểm, true = đã có

    // MARK: - Constructors
    init(idStudent: String, idSubject: String, semester: Int, mark: Double? = nil) {
        self.idStudent = idStudent
        self.idSubject = idSubject
        self.semester = semester
        self.mark = mark ?? 0.0
        self.graded = (mark != nil)
    }
    

    // MARK: - Methods
    // Getters
    func getStudentID() -> String { return idStudent }
    func getSubjectID() -> String { return idSubject }
    func getMark() -> Double { return mark }
    func getSemester() -> Int { return semester }
    func isGraded() -> Bool { return graded }

    // Setters
    func setStudentID(_ newID: String) { self.idStudent = newID }
    func setSubjectID(_ newID: String) { self.idSubject = newID }
    func setMark(_ newMark: Double) { self.mark = newMark; self.graded = true }
    func setSemester(_ newSemester: Int) { self.semester = newSemester }

    // Display
    func displayInfo() {
        let markText = graded ? String(mark) : "not graded"
        print("StudentSubject: Student=\(idStudent), Subject=\(idSubject), Mark=\(markText), Semester=\(semester)")
    }
}
