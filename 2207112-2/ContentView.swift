
import SwiftUI

struct ContentView: View {

    @StateObject private var courseManager = CourseManager()
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var showingSheet = false
    @State private var courseToEdit: Course? = nil   // nil = adding a new course

    // ---------- colours (same blue / purple as the login page) ----------
    var backgroundGradient: LinearGradient {
        LinearGradient(colors: [Color.blue.opacity(0.18), Color.purple.opacity(0.18)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }

    var cardGradient: LinearGradient {
        LinearGradient(colors: [Color.blue, Color.purple],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }

    // ---------- texts ----------
    var cgpaText: String {
        return String(format: "%.2f", courseManager.cgpa)
    }

    var summaryText: String {
        let credits = String(format: "%.1f", courseManager.totalCredits)
        let count = courseManager.courses.count
        return "\(credits) credits, \(count) courses"
    }

    func detailsText(_ course: Course) -> String {
        let credits = String(format: "%g", course.credits)
        let points = String(format: "%.2f", courseManager.points(for: course.grade))
        return "\(credits) credits · \(course.grade) · \(points) points"
    }

    // ---------- CGPA card ----------
    var summaryCard: some View {
        VStack(spacing: 4) {
            Text("Your CGPA")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.85))
            Text(cgpaText)
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
            Text(summaryText)
                .font(.footnote)
                .foregroundColor(Color.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(cardGradient)
        .cornerRadius(20)
        .shadow(color: Color.purple.opacity(0.35), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // ---------- one course row ----------
    func courseRow(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(course.name)
                .font(.headline)
            Text(detailsText(course))
                .font(.subheadline)
                .foregroundColor(Color.purple.opacity(0.8))

            HStack(spacing: 20) {
                Button("Update") {
                    courseToEdit = course
                    showingSheet = true
                }
                Button("Delete") {
                    courseManager.deleteCourse(course: course)
                }
                .foregroundColor(.red)
            }
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    // ---------- course list ----------
    var courseList: some View {
        List {
            ForEach(courseManager.courses) { course in
                courseRow(course)
                    .listRowBackground(Color(.systemBackground).opacity(0.9))
            }
        }
        .listStyle(InsetGroupedListStyle())
        .scrollContentBackground(.hidden)
    }

    // ---------- sign out ----------
    var signOutButton: some View {
        Button("Sign Out") {
            courseManager.stopListening()
            authViewModel.signOut()
        }
        .foregroundColor(.red)
        .padding(.horizontal, 28)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.bottom, 8)
    }

    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                VStack {
                    summaryCard

                    if courseManager.errorMessage != "" {
                        Text(courseManager.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    courseList

                    signOutButton
                }
            }
            .navigationTitle("My CGPA")
            .navigationBarItems(trailing: Button("Add") {
                courseToEdit = nil
                showingSheet = true
            })
            .onAppear {
                courseManager.loadGrades()
                courseManager.getCourses()
            }
            .sheet(isPresented: $showingSheet) {
                AddCourseView(courseManager: courseManager, courseToEdit: courseToEdit)
            }
        }
        .tint(Color.purple)
    }
}
