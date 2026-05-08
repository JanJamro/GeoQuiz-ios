//
//  LevelHistoryViewController.swift
//  GeoQuiz
//
//  Created by Jan on 08/05/2026.
//

import UIKit
import CoreData

class LevelHistoryViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var context: NSManagedObjectContext!
    var category: String!
    var continent: String!
    var fetchController: NSFetchedResultsController<History>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(continent.capitalized) \(category.capitalized) Level History"
        if fetchController == nil {
            let request = History.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchController.delegate = self
        }
        fetchController.fetchRequest.predicate = NSPredicate(format: "level.category.categoryName == %@ AND level.continent.continentName == %@", category, continent)
        do {
            try fetchController.performFetch()
        }
        catch {
            print("Failed to fetch with error: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? LevelHistoryCell {
            if let date = fetchController.object(at: indexPath).date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                cell.dateLabel.text = formatter.string(from: date)
                
                let score = fetchController.object(at: indexPath).score
                cell.scoreLabel.text = "\(score)"
                return cell
            }
        }
        return UITableViewCell()
    }
}
