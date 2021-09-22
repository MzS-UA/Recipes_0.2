//
//  MyButton.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 16.08.2021.
//

import Foundation
import UIKit

class MyButton : UIButton {

   override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
      }

   required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
      }

    private func setup() {
        self.layer.cornerRadius = frame.height / 2
        self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
      }

}
