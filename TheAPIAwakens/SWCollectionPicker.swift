//
//  SWCollectionPicker.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/29/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

@IBDesignable class SWCollectionPicker: UIPickerView {
  override func awakeFromNib() {
    self.backgroundColor = UIColor(red: 27/255.0, green: 32/255.0, blue: 36/255.0, alpha: 1.0)
    self.selectRow(0, inComponent: 0, animated: true)
  }
}
