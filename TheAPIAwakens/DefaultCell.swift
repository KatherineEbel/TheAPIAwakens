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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
