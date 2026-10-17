import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var manager: SchoolManager
    @State private var tab = 0   // 0 = GPA > 8, 1 = failed

    var body: some View {
        let top = manager.studentsWithGPAAbove()
        let failures = manager.failuresBySubject()
        let failTotal = failures.reduce(0) { $0 + $1.failures.count }
        let gpaLimit = Int(SchoolManager.excellentGPA)
        let passLimit = Int(SchoolManager.passMark)

        NavigationStack {
            VStack(spacing: 12) {
                Picker("", selection: $tab) {
                    Text("GPA > \(gpaLimit)").tag(0)
                    Text("Failed (\(failTotal))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                if tab == 0 {
                    SummaryBanner(icon: "star.fill", title: "Students with GPA > \(gpaLimit)", subtitle: nil, value: "\(top.count)", valueLabel: "students", color: Theme.gold)
                } else {
                    SummaryBanner(icon: "exclamationmark.triangle.fill", title: "Failed students by subject (mark < \(passLimit))", subtitle: nil, value: "\(failTotal)", valueLabel: "fails", color: Theme.danger)
                }

                List {
                    if tab == 0 {
                        if top.isEmpty {
                            EmptyHint(systemImage: "star", text: "No students with GPA > \(gpaLimit).").listRowCard()
                        }
                        ForEach(top.indices, id: \.self) { i in
                            RankCard(rank: i + 1, student: top[i].student, gpa: top[i].gpa)
                                .listRowCard(fill: Theme.gold.opacity(0.12), border: Theme.gold.opacity(0.35))
                        }
                    } else {
                        ForEach(failures, id: \.subject.id) { f in
                            Section {
                                if f.failures.isEmpty {
                                    EmptyHint(systemImage: "checkmark.circle.fill", text: "No failures.", color: Theme.success)
                                        .listRowCard(fill: Theme.success.opacity(0.12), border: Theme.success.opacity(0.30))
                                }
                                ForEach(f.failures, id: \.student.id) { item in
                                    FailureRow(student: item.student, mark: item.mark)
                                        .listRowCard(fill: Theme.danger.opacity(0.10), border: Theme.danger.opacity(0.30))
                                }
                            } header: {
                                SectionTag("\(f.subject.getID()) – \(f.subject.getName())", systemImage: f.failures.isEmpty ? "checkmark.circle.fill" : "exclamationmark.triangle.fill", color: f.failures.isEmpty ? Theme.success : Theme.danger)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                TopBar(title: "STATISTICS",
                       glassTint: Theme.statistics.opacity(0.9),
                       topPadding: 20,
                       bottomPadding: 12) {
                    Menu {
                        Button { /* Export report */ } label: { Label("Export report", systemImage: "square.and.arrow.up") }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3).foregroundColor(Theme.statistics)
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

#Preview {
    StatisticsView().environmentObject(SchoolManager.preview())
}
