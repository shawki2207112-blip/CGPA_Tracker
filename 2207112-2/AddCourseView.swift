import SwiftUI

struct AddCourseView: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var courseManager: CourseManager
    var courseToEdit: Course?          // nil = adding, otherwise = updating

    @State private var name = ""
    @State private var credits = 3.0
    @State private var selectedGrade = ""
    @State private var message = ""

    let columns = [GridItem(.adaptive(minimum: 56))]

    // ---------- colours (same blue / purple as the login page) ----------
    var backgroundGradient: LinearGradient {
        LinearGradient(colors: [Color.blue.opacity(0.18), Color.purple.opacity(0.18)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }

    // selected grade = full gradient, others = light tint
    func chipBackground(_ grade: String) -> LinearGradient {
        if selectedGrade == grade {
            return LinearGradient(colors: [Color.blue, Color.purple],
                                  startPoint: .leading,
                                  endPoint: .trailing)
        }
        return LinearGradient(colors: [Color.blue.opacity(0.12), Color.purple.opacity(0.12)],
                              startPoint: .leading,
                              endPoint: .trailing)
    }

    func chipTextColor(_ grade: String) -> Color {
        if selectedGrade == grade {
            return Color.white
        }
        return Color.primary
    }

    func chipShadow(_ grade: String) -> Color {
        if selectedGrade == grade {
            return Color.purple.opacity(0.4)
        }
        return Color.clear
    }

    // ---------- texts ----------
    var creditsText: String {
        let number = String(format: "%g", credits)
        return "Credits: \(number)"
    }

    var selectedText: String {
        if selectedGrade == "" {
            return "Selected: none"
        }
        let points = String(format: "%.2f", courseManager.points(for: selectedGrade))
        return "Selected: \(selectedGrade) (\(points) points)"
    }

    // ---------- one grade button ----------
    func gradeChip(_ g: GradeOption) -> some View {
        Button(action: {
            selectedGrade = g.grade
        }) {
            Text(g.grade)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(chipBackground(g.grade))
                .foregroundColor(chipTextColor(g.grade))
                .cornerRadius(10)
                .shadow(color: chipShadow(g.grade), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    var body: some View {
        NavigationView {
            Form {

                if message != "" {
                    Text(message)
                        .foregroundColor(.red)
                        .listRowBackground(Color(.systemBackground).opacity(0.9))
                }

                Section(header: Text("Course").foregroundColor(Color.purple)) {
                    TextField("Course name", text: $name)
                    Stepper(creditsText, value: $credits, in: 0.5...10, step: 0.5)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.9))

                // one button per grade, taken from grades.json
                Section(header: Text("Grade").foregroundColor(Color.purple)) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(courseManager.grades, id: \.grade) { g in
                            gradeChip(g)
                        }
                    }
                    Text(selectedText)
                        .foregroundColor(Color.purple)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.9))
            }
            .scrollContentBackground(.hidden)
            .background(backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(courseToEdit == nil ? "Add Course" : "Update Course")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if name == "" || selectedGrade == "" {
                        message = "Enter a course name and choose a grade"
                    } else {
                        if let course = courseToEdit {
                            courseManager.updateCourse(id: course.id, name: name, credits: credits, grade: selectedGrade)
                        } else {
                            courseManager.addCourse(name: name, credits: credits, grade: selectedGrade)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
            .onAppear {
                if let course = courseToEdit {
                    name = course.name
                    credits = course.credits
                    selectedGrade = course.grade
                }
            }
        }
        .tint(Color.purple)
    }
}
