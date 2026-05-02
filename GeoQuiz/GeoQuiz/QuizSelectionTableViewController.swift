//
//  QuizSelectionTableViewController.swift
//  GeoQuiz
//
//  Created by Jan on 02/05/2026.
//

import UIKit
import CoreData

class QuizSelectionTableViewController: UITableViewController {
    var context: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GeoQuiz - Select Quiz"
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }

}
