//
//  DefaultCell.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/29/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class DefaultCell: UITableViewCell {

  @IBOutlet weak var attributeNameLabel: UILabel!
  @IBOutlet weak var attributeValueLabel: UILabel!
  
  override func awakeFromNib() {
      super.awakeFromNib()
  }
  
  func configure(withAttributeName name: StarWarsEntity.PropertyNames, andValue value: String) {
    attributeNameLabel.text = name.rawValue
    attributeValueLabel.text = value.lowercased() == "unknown" ? value.capitalized : value
  }

}
