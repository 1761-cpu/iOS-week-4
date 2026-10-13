import Foundation

class Student: Identifiable {
    // MARK: - Properties
    var id: String
    private var name: String
    private var address: String
    private var entranceYear: Int
        
    // MARK: - Constructors
    init() {
        self.id = ""
        self.name = ""
        self.address = ""
        self.entranceYear = 0
    }
    
    init(id: String, name: String, address: String, entranceYear: Int) {
        self.id = id
        self.name = name
        self.address = address
        self.entranceYear = entranceYear
    }
    
    // MARK: - Methods
        //Getters
    func getID() -> String { return id }
    func getName() -> String { return name }
    func getAddress() -> String { return address }
    func getEntranceYear() -> Int { return entranceYear }
    
        //Setters
    func setID(_ newID: String) { self.id = newID }
    func setName(_ newName: String) { self.name = newName }
    func setAddress(_ newAddress: String) { self.address = newAddress }
    func setEntranceYear(_ newYear: Int) { self.entranceYear = newYear }
    
        //Display
    func displayInfo() {
        print("Student: ID=\(id), Name=\(name), Address=\(address), Entrance Year=\(entranceYear)")
    }
}
