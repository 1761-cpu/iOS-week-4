import Foundation

class Fish: Identifiable {
    // Properties
    var id: Int
    private var name: String
    private var color: String
    private var price: Double
    
    // Constructor
    init(id: Int, name: String, color: String, price: Double) {
        self.id = id
        self.name = name
        self.color = color
        self.price = price
    }
    
    // Getter method
    func getInfo() -> String {
        return "\(id) - \(name) - \(color) - $\(price)"
    }
    
    // Setter method
    func setName(_ newName: String) {
        self.name = newName
    }
}
