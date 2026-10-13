import Foundation

class Subject: Identifiable {
    // MARK: - Properties
    var id: String
    private var name: String
    private var credits: Int
    private var semester: Int   // Kì nên học theo chương trình đào tạo (1...8)
    
    // MARK: - Constructors
    init() {
        self.id = ""
        self.name = ""
        self.credits = 0
        self.semester = 0
    }
    
    init(id: String, name: String, credits: Int, semester: Int) {
        self.id = id
        self.name = name
        self.credits = credits
        self.semester = semester
    }
    
    // MARK:  - Methods
        //Getters
    func getID() -> String { return id }
    func getName() -> String { return name }
    func getCredits() -> Int { return credits }
    func getSemester() -> Int { return semester }
    
        //Setters
    func setID(_ newID: String) { self.id = newID }
    func setName(_ newName: String) { self.name = newName }
    func setCredits(_ newCredits: Int) { self.credits = newCredits }
    func setSemester(_ newSemester: Int) { self.semester = newSemester }
    
        //Display
    func displayInfo() {
        print("Subject: ID=\(id), Name=\(name), Credits=\(credits), Semester=\(semester)")
    }
}
