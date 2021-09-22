//
//  AddIngridientCell.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 20.08.2021.
//

import UIKit

class AddIngridientCell: UITableViewCell {

    @IBOutlet weak var titleIngridientText: UITextField!
    @IBOutlet weak var quanityIngridientText: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
