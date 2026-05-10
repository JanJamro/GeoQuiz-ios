//
//  LevelHistoryCell.swift
//  GeoQuiz
//
//  Created by Jan on 08/05/2026.
//

import UIKit

class LevelHistoryCell: UITableViewCell {
    @IBOutlet weak var dateOrScoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
