//
//  LevelHistoryViewController.swift
//  GeoQuiz
//
//  Created by Jan on 08/05/2026.
//

import UIKit
import CoreData

class LevelHistoryViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var dateTableView: UITableView!
    @IBOutlet weak var countriesTableView: UITableView!
    var context: NSManagedObjectContext!
    var category: String!
    var continent: String!
    var fetchController: NSFetchedResultsController<History>!
    var countries: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTableView.delegate = self
        dateTableView.dataSource = self
        countriesTableView.delegate = self
        countriesTableView.dataSource = self
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
        if let countriesSet = fetchController.fetchedObjects?.first?.level?.continent?.countries as? Set<Country> {
            for country in countriesSet {
                countries.append(country)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == dateTableView {
            return fetchController.fetchedObjects?.count ?? 0
        }
        
        return fetchController.fetchedObjects?.first?.level?.continent?.countries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? LevelHistoryCell {
            if tableView == dateTableView {
                if let date = fetchController.object(at: indexPath).date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .none
                    cell.dateOrScoreLabel.text = formatter.string(from: date)
                    
                    let score = fetchController.object(at: indexPath).score
                    let max = fetchController.object(at: indexPath).level?.continent?.countries?.count ?? 0
                    cell.scoreLabel.text = "\(score)/\(max)"
                    return cell
                }
            }
            else {
                let country = countries[indexPath.row]
                cell.dateOrScoreLabel.text = country.countryName
                var guesses = 0
                var correctGuesses = 0
                if category == "Flags" {
                    guesses = Int(country.flag?.numberOfGuess ?? 0)
                    correctGuesses = Int(country.flag?.numberOfCorrect ?? 0)
                }
                else if category == "Capitals" {
                    guesses = Int(country.capital?.numberOfGuess ?? 0)
                    correctGuesses = Int(country.capital?.numberOfCorrect ?? 0)
                }
                cell.scoreLabel.text = "\(correctGuesses)/\(guesses)"
                if Double(correctGuesses)/Double(guesses) > 0.8 {
                    cell.scoreLabel.textColor = .systemGreen
                }
                else if Double(correctGuesses)/Double(guesses) < 0.2 {
                    cell.scoreLabel.textColor = .systemRed
                }
                else {
                    cell.scoreLabel.textColor = .black
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}
