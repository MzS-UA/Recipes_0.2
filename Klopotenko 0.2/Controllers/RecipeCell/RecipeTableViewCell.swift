//
//  RecipeTableViewCell.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 11.08.2021.
//

import UIKit
import SwipeCellKit

class RecipeTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var RecipeCellImage: UIImageView!
    @IBOutlet weak var RecipeCellLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
