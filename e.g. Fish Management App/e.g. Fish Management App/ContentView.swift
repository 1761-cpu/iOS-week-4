import SwiftUI

struct ContentView: View {
    //Sample data
    @State private var fishes: [Fish] = [
        Fish(id: 1, name: "Neon Fish", color: "Red", price: 20.0),
        Fish(id: 2, name: "Betta Fish", color: "Blue", price: 35.0),
        Fish(id: 3, name: "Goldfish", color: "Orange", price: 25.0),
        Fish(id: 4, name: "Angelfish", color: "Silver", price: 40.0)
    ]
    
    var body: some View {
        NavigationView {
            List(fishes) { fish in
                HStack(spacing: 16) {
                    Image(systemName: "fish.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(colorFromName(fish.getInfo())) //func colorFromName
                    
                    VStack(alignment: .leading) {
                        Text(fish.getInfo().components(separatedBy: " - ")[1])
                            .font(.headline)
                        

                        Text("\(fish.getInfo().components(separatedBy: " - ")[2]) - \(fish.getInfo().components(separatedBy: " - ")[3])")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("My Aquarium")
        }
    }
    
    func colorFromName(_ info: String) -> Color {
        if info.contains("Red") { return .red }
        if info.contains("Blue") { return .blue }
        if info.contains("Orange") { return .orange }
        if info.contains("Silver") { return .gray }
        return .black
    }
}

#Preview {
    ContentView()
}
