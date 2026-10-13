import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var manager: SchoolManager
    
    var body: some View {
        let top = manager.studentsWithGPAAbove()
        let failures = manager.failuresBySubject()
        
        NavigationStack{
            List {
                Section {
                    if top.isEmpty {
                        Text("No students with GPA > 8.").foregroundColor(.gray)
                    }
                    ForEach(top, id: \.student.id) { item in
                        HStack(spacing: 12) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text(item.student.getName()).font(.headline)
                                Text(item.student.getID())
                                    .font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            Text(String(format: "%.2f", item.gpa))
                                .bold().foregroundColor(.green)
                        }
                        .listRowCard(fill: Color.orange.opacity(0.18), border: Color.orange.opacity(0.35))

                    }
                } header: {
                    SectionTag("Students with GPA > 8", systemImage: "star.fill", color: .orange)
                }
                
                ForEach(failures, id: \.subject.id) { f in
                    Section {
                        if f.failures.isEmpty {
                            Text("No failures.").foregroundColor(.gray)
                                .listRowCard(fill: Color.green.opacity(0.12), border: Color.green.opacity(0.30))
                        }
                        ForEach(f.failures, id: \.student.id) { item in
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("\(item.student.getID()) – \(item.student.getName())")
                                Spacer()
                                Text(String(format: "%.1f", item.mark))
                                    .foregroundColor(.red).bold()
                            }
                            .listRowCard(fill: Color.red.opacity(0.12), border: Color.red.opacity(0.30))
                        }
                    } header: {
                        SectionTag("\(f.subject.getID()) – \(f.subject.getName())",
                                   systemImage: f.failures.isEmpty ? "checkmark.circle.fill"
                                                                   : "exclamationmark.triangle.fill",
                                   color: f.failures.isEmpty ? .green : .red)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(title: "STATISTICS",
                       glassTint: .black.opacity(0.9),
                       topPadding: 20,
                       bottomPadding: 20) {
                    Menu {
                        Button {
                            // Có thể mở rộng thêm
                        } label: { Label("Export report", systemImage: "square.and.arrow.up") }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill").font(.title3).foregroundColor(.black)
                    }
                }
            }
        }
    }
}

#Preview {
    StatisticsView().environmentObject(SchoolManager.preview())
}
