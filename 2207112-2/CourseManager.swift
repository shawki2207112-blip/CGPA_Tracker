import Foundation
import FirebaseAuth
import FirebaseFirestore

struct Course: Identifiable {
    var id: String
    var name: String
    var credits: Double
    var grade: String
}

struct GradeOption {
    var grade: String
    var points: Double
}

class CourseManager: ObservableObject {

    private var listener: ListenerRegistration?

    @Published var courses = [Course]()
    @Published var grades = [GradeOption]()
    @Published var errorMessage = ""

    // each user has their own courses: users -> uid -> courses
    private var coursesCollection: CollectionReference {
        let uid = Auth.auth().currentUser?.uid ?? "unknown"
        return Firestore.firestore().collection("users").document(uid).collection("courses")
    }

    // ---- JSON PARSING: read grades.json from inside the app ----
    func loadGrades() {
        if let url = Bundle.main.url(forResource: "grades", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data)
                var loaded: [GradeOption] = []
                if let list = json as? [[String: Any]] {
                    for item in list {
                        let grade = item["grade"] as? String ?? ""
                        let points = item["points"] as? Double ?? 0
                        loaded.append(GradeOption(grade: grade, points: points))
                    }
                }
                grades = loaded
            } catch {
                errorMessage = "Could not read grades.json"
            }
        } else {
            errorMessage = "grades.json not found in the app"
        }
    }

    // points for a letter grade, looked up in the JSON list
    func points(for grade: String) -> Double {
        for g in grades {
            if g.grade == grade {
                return g.points
            }
        }
        return 0
    }

    var totalCredits: Double {
        var total = 0.0
        for course in courses {
            total += course.credits
        }
        return total
    }

    // CGPA = sum(credits x points) / total credits
    var cgpa: Double {
        var totalPoints = 0.0
        var credits = 0.0
        for course in courses {
            totalPoints += points(for: course.grade) * course.credits
            credits += course.credits
        }
        if credits == 0 {
            return 0
        }
        return totalPoints / credits
    }

    // ---- READ (live updates) ----
    func getCourses() {
        listener?.remove()
        listener = coursesCollection
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                var loaded: [Course] = []
                for doc in snapshot?.documents ?? [] {
                    let data = doc.data()
                    loaded.append(Course(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        credits: data["credits"] as? Double ?? 0,
                        grade: data["grade"] as? String ?? ""
                    ))
                }
                self.courses = loaded
            }
    }

    func stopListening() {
        listener?.remove()
    }

    // ---- CREATE ----
    func addCourse(name: String, credits: Double, grade: String) {
        coursesCollection.addDocument(data: [
            "name": name,
            "credits": credits,
            "grade": grade,
            "createdAt": Date().timeIntervalSince1970
        ]) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // ---- UPDATE ----
    func updateCourse(id: String, name: String, credits: Double, grade: String) {
        coursesCollection.document(id).updateData([
            "name": name,
            "credits": credits,
            "grade": grade
        ]) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // ---- DELETE ----
    func deleteCourse(course: Course) {
        coursesCollection.document(course.id).delete { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
