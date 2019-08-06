import UIKit

final class CourseListViewController: UIViewController {
    
    
    private var model: CourseListModel!
}

extension CourseListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up model
        
        
    }
}

final class CourseListModel {
    private(set) var courseList: [String]
    
    private weak var delegate: CourseListModelDelegate?
    private let persistence: HomeworkTaskPersistence
    
    init(delegate: CourseListModelDelegate, persistence: HomeworkTaskPersistence) {
        self.delegate = delegate
        self.persistence = persistence
        
        courseList = persistence.courses.sorted(by: { $0 < $1 })
    }
}

extension CourseListModel {
    private func add(course: String) {
        persistence.add(course: course)
    }
    
    private func delete(course: String) {
        persistence.delete(course: course)
    }
}
