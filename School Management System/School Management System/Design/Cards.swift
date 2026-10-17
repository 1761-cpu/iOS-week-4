import SwiftUI

// MARK: - Student Card
struct StudentCard: View {
    @EnvironmentObject var manager: SchoolManager
    let student: Student
    
    var body: some View {
        let id = student.getID()
        let gpa = manager.gpa(of: id)
        let count = manager.records(ofStudent: id).count
        let credits = manager.totalCredits(ofStudent: id)
        let isTop = (gpa ?? 0) >= SchoolManager.excellentGPA
        let gpaColor: Color = {
            guard let g = gpa else { return .gray }
            if g >= SchoolManager.excellentGPA { return Theme.gold }
            return g >= SchoolManager.passMark ? Theme.success : Theme.danger
        }()
        
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                LetterAvatar(letter: String(student.getName().prefix(1)), color: Theme.students)
                VStack(alignment: .leading, spacing: 4) {
                    Text(student.getName()).font(.headline)
                    IDChip(text: id, color: Theme.students)
                }
                Spacer()
                if isTop {
                    Image(systemName: "star.circle.fill").font(.title2).foregroundColor(Theme.gold)
                }
            }
            InfoRow(label: "Address", value: student.getAddress())
            InfoRow(label: "Class of", value: String(student.getEntranceYear()))
            InfoRow(label: "Enrolled", value: "\(count) subjects (\(credits) credits)")
            Divider()
            MetricBlock(label: "Cumulative GPA", value: gpa.map { String(format: "%.2f", $0) } ?? "—", color: gpaColor)
        }
    }
}

// MARK: - Subject Card
struct SubjectCard: View {
    @EnvironmentObject var manager: SchoolManager
    let subject: Subject
    
    var body: some View {
        let id = subject.getID()
        let teachers = manager.teachersTeaching(subjectID: id)
        let enrolled = manager.enrolledCount(inSubject: id)
        let graded = manager.gradedCount(inSubject: id)
        let failed = manager.failedCount(inSubject: id)
        
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                IconBadge(systemName: "book.fill", color: Theme.subjects)
                VStack(alignment: .leading, spacing: 4) {
                    Text(subject.getName()).font(.headline)
                    IDChip(text: id, color: Theme.subjects)
                }
                Spacer()
                Image(systemName: "pencil").foregroundColor(.gray)
            }
            
            StatBox(items: [("Credits", "\(subject.getCredits()) credits"), ("Suggested sem.", "Semester \(subject.getSemester())")])
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "graduationcap.fill").foregroundColor(Theme.teachers)
                    Text("Teachers (\(teachers.count)):").foregroundColor(.gray)
                }
                .font(.system(size: 12))
                Text(teachers.isEmpty ? "No teacher assigned" : teachers.map { $0.getName() }.joined(separator: ", "))
                    .font(.system(size: 13, weight: .medium))
            }
            
            Divider()
            
            HStack {
                Label("Enrolled: \(enrolled)", systemImage: "person.2").font(.system(size: 13)).foregroundColor(.gray)
                Spacer()
                if graded == 0 {
                    StatusPill(text: "Not graded", color: .gray)
                } else if failed > 0 {
                    StatusPill(text: "\(failed) failed", color: Theme.danger)
                } else {
                    StatusPill(text: "100% Pass", color: Theme.gold)
                }
            }
        }
    }
}

// MARK: - Teacher Card
struct TeacherCard: View {
    @EnvironmentObject var manager: SchoolManager
    let teacher: Teacher
    @State private var showAssign = false
    
    var body: some View {
        let subs = teacher.getSubjects()
        let credits = manager.totalCredits(ofTeacher: teacher)
        let studentCount = manager.studentCount(ofTeacher: teacher)
        
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                IconBadge(systemName: "graduationcap.fill", color: Theme.teachers)
                VStack(alignment: .leading, spacing: 4) {
                    Text(teacher.getName()).font(.headline)
                    HStack(spacing: 6) {
                        IDChip(text: teacher.getID(), color: Theme.teachers)
                        Text(teacher.getDepartment()).font(.system(size: 12)).foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            
            StatBox(items: [("Total credits", "\(credits) credits (\(subs.count) subjects)")])
            
            Text("Subjects this teacher can teach:").font(.system(size: 12)).foregroundColor(.gray)
            
            if subs.isEmpty {
                EmptyHint(systemImage: "tray", text: "No subjects assigned yet.")
            } else {
                FlowLayout(spacing: 6) {
                    ForEach(subs) { s in
                        SubjectChip(id: s.getID(), name: s.getName(), color: Theme.teachers)
                    }
                }
            }
            
            if showAssign {
                Divider()
                Text("Tap to assign / remove:").font(.system(size: 12)).foregroundColor(.gray)
                FlowLayout(spacing: 6) {
                    ForEach(manager.subjects) { s in
                        let on = subs.contains { $0.getID() == s.getID() }
                        Button {
                            _ = try? manager.toggleSubject(s.getID(), forTeacher: teacher.getID())
                        } label: {
                            Text("\(s.getID()) \(on ? "✓" : "+")")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(on ? .white : .gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(on ? Theme.teachers : Color.gray.opacity(0.15), in: Capsule())
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            
            Divider()
            
            HStack {
                Label("\(studentCount) students", systemImage: "person.2").font(.system(size: 13)).foregroundColor(.gray)
                Spacer()
                Button(showAssign ? "Done" : "Edit -") {
                    withAnimation { showAssign.toggle() }
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.teachers)
                .buttonStyle(.borderless)
            }
        }
    }
}

// MARK: - Rank Card & Failure Row (Statistics)
struct RankCard: View {
    @EnvironmentObject var manager: SchoolManager
    let rank: Int
    let student: Student
    let gpa: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                LetterAvatar(letter: String(student.getName().prefix(1)), color: Theme.gold)
                VStack(alignment: .leading, spacing: 4) {
                    Text(student.getName()).font(.headline)
                    IDChip(text: student.getID(), color: Theme.gold)
                }
                Spacer()
                StatusPill(text: "Top \(rank)", color: Theme.gold)
            }
            InfoRow(label: "Address", value: student.getAddress())
            InfoRow(label: "Class of", value: String(student.getEntranceYear()))
            InfoRow(label: "Enrolled credits", value: "\(manager.totalCredits(ofStudent: student.getID()))")
            Divider()
            MetricBlock(label: "GPA", value: String(format: "%.2f", gpa), color: Theme.gold)
        }
    }
}

struct FailureRow: View {
    let student: Student
    let mark: Double
    
    var body: some View {
        HStack(spacing: 12) {
            LetterAvatar(letter: String(student.getName().prefix(1)), color: Theme.danger, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(student.getName()).font(.system(size: 15, weight: .semibold))
                HStack(spacing: 6) {
                    IDChip(text: student.getID(), color: Theme.danger)
                    Text("Class of \(String(student.getEntranceYear()))").font(.system(size: 12)).foregroundColor(.gray)
                }
            }
            Spacer()
            Text(String(format: "%.1f", mark))
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(Theme.danger)
        }
    }
}
