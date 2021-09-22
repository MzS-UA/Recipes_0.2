//
//  IngridientTableViewCell.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 11.08.2021.
//

import UIKit

class IngridientTableViewCell: UITableViewCell {


    @IBOutlet weak var ingridientCellLabel: UILabel!
    @IBOutlet weak var ingridientQuanityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }
    
}
