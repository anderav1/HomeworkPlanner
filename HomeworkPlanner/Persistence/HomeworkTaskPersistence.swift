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
                result = HomeworkTask.from(homeworkTaskEntities)
                
                print("Successfully retrieved \(result.count) tasks")
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
            try managedContext.save()
            
            print("Successfully saved \(homeworkTask.name)")
        } catch {
            print(error)
        }
    }
}
