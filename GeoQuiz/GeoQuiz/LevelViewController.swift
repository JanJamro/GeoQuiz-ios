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
    var alreadyGuessedCountries: [Country: Bool] = [:]
    
    
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
                alreadyGuessedCountries[currentRoundCountry] = true
                
                if category == "Flags" {
                    var correct = currentRoundCountry.flag?.numberOfCorrect ?? 0
                    correct += 1
                    currentRoundCountry.flag?.numberOfCorrect = correct
                }
                else if category == "Capitals" {
                    var correct = currentRoundCountry.capital?.numberOfCorrect ?? 0
                    correct += 1
                    currentRoundCountry.capital?.numberOfCorrect = correct
                }
            }
            else {
                alreadyGuessedCountries[currentRoundCountry] = false
                answerLabel.text = "Correct answer was: \(answer.capitalized)"
                flagImageView.layer.borderColor = UIColor.red.cgColor
                capitalLabel.textColor = .red
                answerLabel.isHidden = false
            }
            
            if category == "Flags" {
                var num = currentRoundCountry.flag?.numberOfGuess ?? 0
                num += 1
                currentRoundCountry.flag?.numberOfGuess = num
            }
            else if category == "Capitals" {
                var num = currentRoundCountry.capital?.numberOfGuess ?? 0
                num += 1
                currentRoundCountry.capital?.numberOfGuess = num
            }
            do {
                try context.save()
            }
            catch {
                print("Unsuccessful save, error: \(error)")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                
                if self.countriesSet.isEmpty {
                    let historyRecord = History(context: self.context)
                    historyRecord.date = Date()
                    historyRecord.score = Int64(self.score)
                    historyRecord.level = self.fetchController.fetchedObjects?.first
                    do {
                        try self.context.save()
                    }
                    catch {
                        print("Failed to save context: \(error)")
                    }
                    
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LevelSummary") as? LevelSummaryViewController {
                        vc.category = self.category
                        vc.continent = self.continent
                        vc.score = self.score
                        vc.maxPossibleScore = self.allRounds
                        vc.countries = self.alreadyGuessedCountries
                        var controllers = self.navigationController?.viewControllers
                        controllers?.removeLast()
                        controllers?.append(vc)
                        self.navigationController?.setViewControllers(controllers!, animated: true)
                    }
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
