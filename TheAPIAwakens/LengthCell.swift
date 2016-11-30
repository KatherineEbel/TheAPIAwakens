//
//  LengthCell.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/28/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class LengthCell: UITableViewCell {
  
  @IBOutlet weak var attributeNameLabel: UILabel!
  @IBOutlet weak var attributeValueLabel: UILabel!
  @IBOutlet weak var unitsLabel: UILabel!
  @IBOutlet weak var englishConversionButton: UIButton!
  @IBOutlet weak var metricConversionButton: UIButton!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  func resetConversionButtons() {
    metricConversionButton.isUserInteractionEnabled = true
    metricConversionButton.tintColor = UIColor.darkGray
    englishConversionButton.isUserInteractionEnabled = false
    englishConversionButton.tintColor = UIColor.white
  }
  
  @IBAction func toEnglishMeasurement() {
    attributeValueLabel.text? = (attributeValueLabel.text?.toFeetFromMeters())!
    unitsLabel.text = "ft"
    resetConversionButtons()
  }
  
  @IBAction func toMetricMeasurement() {
    attributeValueLabel.text = (attributeValueLabel.text?.fromFeetToMeters())!
    unitsLabel.text = "m"
    metricConversionButton.isUserInteractionEnabled = false
    metricConversionButton.tintColor = UIColor.white
    englishConversionButton.isUserInteractionEnabled = true
    englishConversionButton.tintColor = UIColor.darkGray
  }
  
  

}
