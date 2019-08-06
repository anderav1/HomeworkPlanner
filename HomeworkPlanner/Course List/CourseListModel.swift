import UIKit

protocol CourseListModelDelegate: class {
    func dataChanged()
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

// Functions for editing the course list
extension CourseListModel {
    func add(course: String) {
        persistence.add(course: course)
        courseList.append(course)
        delegate?.dataChanged()
    }
    
    func delete(at index: Int) {
        persistence.delete(course: courseList[index])
        courseList.remove(at: index)
    }
}
