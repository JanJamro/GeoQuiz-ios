//
//  LevelCell.swift
//  GeoQuiz
//
//  Created by Jan on 04/05/2026.
//

import UIKit

class LevelCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreHistoryButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    var onTap: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        onTap?()
    }
    
}
