import SwiftUI

struct ContentView: View {
    @StateObject private var manager = SchoolManager(sample: true)
    
    var body: some View {
        TabView {
            StudentsView()
                .tabItem { Label("Students", systemImage: "person.3.fill") }
            SubjectsView()
                .tabItem { Label("Subjects", systemImage: "book.fill") }
            EnrollmentView()
                .tabItem { Label("Enrollment", systemImage: "checklist") }
            MarksView()
                .tabItem { Label("Marks", systemImage: "square.and.pencil") }
            StatisticsView()
                .tabItem { Label("Statistics", systemImage: "chart.bar.fill") }
        }
        .environmentObject(manager)
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
