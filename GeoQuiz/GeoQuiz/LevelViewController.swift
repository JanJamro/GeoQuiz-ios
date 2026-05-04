//
//  LevelViewController.swift
//  GeoQuiz
//
//  Created by Jan on 03/05/2026.
//

import UIKit
import CoreData

class LevelViewController: UIViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var guessButton: UIButton!
    var fetchController: NSFetchedResultsController<Level>!
    var category: String!
    var continent: String!
    var score = 0 {
        didSet {
            answerLabel.text = "You're right!"
            flagImageView.layer.borderColor = UIColor.green.cgColor
            capitalLabel.textColor = UIColor.green
        }
    }
    var roundCounter = 0
    var allRounds = 0
    var answer: String!
    var currentRoundCountry: Country!
    var context: NSManagedObjectContext!
    var countriesSet: Set<Country> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        score = 0
        roundCounter = 0
        flagImageView.layer.borderWidth = 2
        flagImageView.layer.borderColor = UIColor.black.cgColor
        fetchLevel()
        prepareRound()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func fetchLevel() {
        if fetchController == nil {
            let request = Level.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "continent.continentName", ascending: true)]
            fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchController.delegate = self
        }
        fetchController.fetchRequest.predicate = NSPredicate(format: "category.categoryName == %@ AND continent.continentName == %@", category, continent)
        do {
            try fetchController.performFetch()
        }
        catch {
            print("Fetch failed")
        }
        roundLabel.text = "\(roundCounter)/\(allRounds)"
        if let level = fetchController.fetchedObjects?.first {
            if let countries = level.continent?.countries as? Set<Country> {
                countriesSet = countries
                allRounds = countriesSet.count
            }
        }
    }
    
    private func prepareRound() {
        textField.text = ""
        roundCounter += 1
        flagImageView.layer.borderColor = UIColor.black.cgColor
        capitalLabel.textColor = .black
        currentRoundCountry = countriesSet.randomElement()!
        countriesSet.remove(currentRoundCountry)
        answer = currentRoundCountry.countryName?.lowercased() ?? ""
        roundLabel.text = "\(roundCounter)/\(allRounds)"
        answerLabel.isHidden = true
        if category == "Flags" {
            flagImageView.isHidden = false
            capitalLabel.isHidden = true
            flagImageView.image = UIImage(named: currentRoundCountry.flag?.flagFileName ?? "")
            descriptionLabel.text = "Which country flag is it?"
        }
        else if category == "Capitals" {
            flagImageView.isHidden = true
            capitalLabel.isHidden = false
            capitalLabel.text = currentRoundCountry.capital?.capitalName ?? ""
            descriptionLabel.text = "Which country capital is it?"
        }
    }
    @IBAction func makeGuess(_ sender: Any) {
        if textField.text != nil && textField.text != "" {
            view.isUserInteractionEnabled = false
            let answerText = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if answerText == answer {
                score += 1
            }
            else {
                answerLabel.text = "Wrong answer!"
                flagImageView.layer.borderColor = UIColor.red.cgColor
                capitalLabel.textColor = .red
            }
            answerLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.countriesSet.isEmpty {
                    self.flagImageView.isHidden = true
                    self.roundLabel.isHidden = true
                    self.descriptionLabel.isHidden = true
                    self.textField.isHidden = true
                    self.answerLabel.isHidden = true
                    self.guessButton.isHidden = true
                    self.capitalLabel.text = "Your score is \(self.score)/\(self.allRounds)"
                    self.capitalLabel.textColor = .black
                    self.capitalLabel.isHidden = false
                }
                else {
                    self.prepareRound()
                }
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
