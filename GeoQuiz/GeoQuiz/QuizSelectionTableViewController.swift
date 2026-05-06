//
//  QuizSelectionTableViewController.swift
//  GeoQuiz
//
//  Created by Jan on 02/05/2026.
//

import UIKit
import CoreData

class QuizSelectionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var context: NSManagedObjectContext!
    var fetchController: NSFetchedResultsController<Level>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GeoQuiz - Select Quiz"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        loadLevelsFromDatabase()
        
    }
    
    private func loadLevelsFromDatabase() {
        if fetchController == nil {
            let request = Level.fetchRequest()
            let sort = NSSortDescriptor(key: "continent.continentName", ascending: true)
            request.sortDescriptors = [sort]
            fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "continent.continentName", cacheName: nil)
            fetchController.delegate = self
        }
        
        do {
            try fetchController.performFetch()
            tableView.reloadData()
        }
        catch {
            print ("Fetch unsuccesfull")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchController.sections?[section].name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Level", for: indexPath) as? LevelCell {
            cell.descriptionLabel.text = fetchController.object(at: indexPath).levelDescription
            cell.titleLabel.text = "\(fetchController.object(at: indexPath).continent?.continentName ?? "Continent") \(fetchController.object(at: indexPath).category?.categoryName ?? "Category")"
            cell.titleLabel.textColor = UIColor.systemBlue
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "LevelViewController") as? LevelViewController {
            vc.category = fetchController.object(at: indexPath).category?.categoryName
            vc.continent = fetchController.object(at: indexPath).continent?.continentName
            vc.context = context
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
