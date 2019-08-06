import CoreData
import UIKit

// Derived from the PokemonPersistence class discussed during class
final class HomeworkTaskPersistence {
    var homeworkTasks: [HomeworkTask] {
        guard let appDelegate = getAppDelegate() else { return [] }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let hwTaskFetchRequest: NSFetchRequest<HomeworkTaskEntity> = HomeworkTaskEntity.fetchRequest()
        
        var result: [HomeworkTask] = []
        managedContext.performAndWait {
            do {
                let homeworkTaskEntities = try managedContext.fetch(hwTaskFetchRequest)
                result = HomeworkTask.from(homeworkTaskEntities).filter { $0.deadline >= Date() }
                
                print("Successfully retrieved \(result.count) tasks")
            } catch {
                print(error)
            }
        }
        
        return result
    }
    
    var courses: [String] {
        guard let appDelegate = getAppDelegate() else { return [] }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let coursesFetchRequest: NSFetchRequest<CourseEntity> = CourseEntity.fetchRequest()
        
        var result: [String] = []
        managedContext.performAndWait {
            do {
                let courseEntities = try managedContext.fetch(coursesFetchRequest)
                for courseEntity in courseEntities {
                    result.append($0.name)
                }
                
                print("Successfully retrieved \(result.count) courses")
            } catch {
                print(error)
            }
        }
        
        return result
    }
    
    // Save a homework task to core data
    func save(homeworkTask: HomeworkTask) {
        DispatchQueue.main.async { [weak self] in
            guard let appDelegate = self?.getAppDelegate() else { return }
            
            self?.save(homeworkTask: homeworkTask, with: appDelegate)
        }
    }
    
    // Helper function for getting appDelegate
    private func getAppDelegate() -> AppDelegate? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error: Could not locate AppDelegate")
            return nil
        }
        
        return appDelegate
    }
}

extension HomeworkTaskPersistence {
    // Save a homework task to core data
    private func save(homeworkTask: HomeworkTask, with appDelegate: AppDelegate) {
        let managedContext = appDelegate.persistentContainer.viewContext
        let homeworkTaskEntity = NSEntityDescription.entity(forEntityName: "HomeworkTaskEntity", in: managedContext)!
        
        let homeworkTaskObject = NSManagedObject(entity: homeworkTaskEntity, insertInto: managedContext)
        homeworkTaskObject.setValue(homeworkTask.id, forKey: "id")
        homeworkTaskObject.setValue(homeworkTask.name, forKey: "name")
        homeworkTaskObject.setValue(homeworkTask.course, forKey: "course")
        homeworkTaskObject.setValue(homeworkTask.deadline, forKey: "deadline")
        homeworkTaskObject.setValue(homeworkTask.taskDescription, forKey: "taskDescription")
        homeworkTaskObject.setValue(homeworkTask.reminderId, forKey: "reminderId")
        
        do {
            let alarmSettingsData = try JSONEncoder().encode(homeworkTask.alarmSettings)
            homeworkTaskObject.setValue(alarmSettingsData, forKey: "alarmSettings")
            
            try managedContext.save()
            
            print("Successfully saved \(homeworkTask.name)")
        } catch {
            print(error)
        }
    }
}

extension HomeworkTaskPersistence {
    func add(course: String) {
        DispatchQueue.main.async { [weak self] in
            guard let appDelegate = self?.getAppDelegate() else { return }
            
            self?.add(course: course, with: appDelegate)
        }
    }
    
    func delete(course: String) {
        DispatchQueue.main.async { [weak self] in
            guard let appDelegate = self?.getAppDelegate() else { return }
            
            self?.delete(course: course, with: appDelegate)
        }
    }
    
    private func add(course: String, with appDelegate: AppDelegate) {
        let managedContext = appDelegate.persistentContainer.viewContext
        let courseEntity = NSEntityDescription.entity(forEntityName: "CourseEntity", in: managedContext)!
        
        let courseObject = NSManagedObject(entity: courseEntity, insertInto: managedContext)
        courseObject.setValue(course, forKey: "name")
        
        do {
            try managedContext.save()
            
            print("Successfully saved \(course)")
        } catch {
            print(error)
        }
    }
    
    private func delete(course: String, with appDelegate: AppDelegate) {
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<CourseEntity> = CourseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == \(course)")
        
        managedContext.performAndWait {
            let courseEntitiesToDelete = try? managedContext.fetch(fetchRequest)
            courseEntitiesToDelete.forEach {
                managedContext.delete($0)
                
                print("Successfully deleted an object from context")
            }
            
            do {
                try managedContext.save()
                
                print("Successfully saved after deletion")
            } catch {
                print("Could not save context after deletion")
            }
        }
    }
}
