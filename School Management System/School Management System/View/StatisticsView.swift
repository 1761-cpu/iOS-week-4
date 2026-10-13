import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var manager: SchoolManager
    
    var body: some View {
        let top = manager.studentsWithGPAAbove()
        let failures = manager.failuresBySubject()
        
        NavigationStack {
            List {
                // ===== (a) SV có GPA > 8 =====
                Section {
                    if top.isEmpty {
                        Text("Không có sinh viên nào GPA > 8.").foregroundColor(.gray)
                    }
                    ForEach(top, id: \.student.id) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.student.getName()).font(.headline)
                                Text(item.student.getID()).font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            Text(String(format: "%.2f", item.gpa)).bold().foregroundColor(.green)
                        }
                    }
                } header: {
                    Label("⭐ Sinh viên GPA > 8", systemImage: "star.fill")
                        .foregroundColor(.orange)
                }
                
                // ===== (b) SV rớt theo môn =====
                Section {
                    if failures.isEmpty {
                        Text("Chưa có dữ liệu.").foregroundColor(.gray)
                    }
                } header: {
                    Label("❌ Sinh viên rớt theo môn", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
                
                ForEach(failures, id: \.subject.id) { f in
                    Section("\(f.subject.getID()) – \(f.subject.getName())") {
                        if f.failures.isEmpty {
                            Text("Không có SV rớt.").foregroundColor(.gray)
                        }
                        ForEach(f.failures, id: \.student.id) { item in
                            HStack {
                                Text("\(item.student.getID()) – \(item.student.getName())")
                                Spacer()
                                Text(String(format: "%.1f", item.mark)).foregroundColor(.red).bold()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Thống kê")
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(SchoolManager.preview())
}