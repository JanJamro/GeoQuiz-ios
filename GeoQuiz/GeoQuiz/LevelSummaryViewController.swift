//
//  LevelSummaryViewController.swift
//  GeoQuiz
//
//  Created by Jan on 06/05/2026.
//

import UIKit

class LevelSummaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var levelNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var countries: [Country:Bool]!
    var category: String!
    var continent: String!
    var score: Int!
    var maxPossibleScore: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        levelNameLabel.text = "\(continent.capitalized) \(category.capitalized)"
        scoreLabel.text = "Your score was: \(score ?? 0)/\(maxPossibleScore ?? 0)"
        levelNameLabel.textColor = .systemBlue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath)
        let keysArray = Array(countries.keys)
        cell.textLabel?.text = keysArray[indexPath.row].countryName ?? ""
        if let guess = countries[keysArray[indexPath.row]] {
            if guess {
                cell.textLabel?.textColor = .systemGreen
            }
            else {
                cell.textLabel?.textColor = .systemRed
            }
        }
        return cell
    }
}
