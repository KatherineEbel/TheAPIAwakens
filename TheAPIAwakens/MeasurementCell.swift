//
//  LengthCell.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/28/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

// MARK: MeasurementSystem enum
enum MeasurementSystem: String {
  case english = "ft"
  case metric = "m"
}

// MARK: MeasurementCell Delegate protocol
// LengthCellDelegate helps keep the cell's value in sync with user changes
protocol MeasurementCellDelegate: class {
  var defaults: SWSettings { get set }
  func measurementSystemDidChange(for cell: MeasurementCell)
}

// MARK: MeasurementCell Class def
class MeasurementCell: UITableViewCell {
  @IBOutlet weak var attributeNameLabel: UILabel!
  @IBOutlet weak var attributeValueLabel: UILabel!
  @IBOutlet weak var englishConversionButton: UIButton!
  @IBOutlet weak var metricConversionButton: UIButton!
  weak var delegate: MeasurementCellDelegate?
  var currentMeasurementSystem = MeasurementSystem.english
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  // MARK: Helper methods
  // sets button an label properties to match user's preference
  // chosen measurement system button is white, and disabled to avoid converting value multiple times in a row
  func configureCellForCurrentMeasurementSystem() {
    switch currentMeasurementSystem {
      case .metric:
        metricConversionButton.isUserInteractionEnabled = false
        metricConversionButton.tintColor = UIColor.white
        englishConversionButton.isUserInteractionEnabled = true
        englishConversionButton.tintColor = UIColor.darkGray
      case .english:
        metricConversionButton.isUserInteractionEnabled = true
        metricConversionButton.tintColor = UIColor.darkGray
        englishConversionButton.isUserInteractionEnabled = false
        englishConversionButton.tintColor = UIColor.white
    }
  }
  
  // switch measurement system to that of parameter, and adjust value label, 
  // calls configureCellforCurrentMeasurementSystem to reset button properties
  func convertToMeasurementSystem(_ system: MeasurementSystem) {
    switch  system {
      case .metric:
        currentMeasurementSystem = .metric
        attributeValueLabel.text = (attributeValueLabel.text?.fromFeetToMeters())!
      case .english:
        currentMeasurementSystem = .english
        attributeValueLabel.text? = (attributeValueLabel.text?.toFeetFromMeters())!
    }
    delegate?.measurementSystemDidChange(for: self)
    configureCellForCurrentMeasurementSystem()
  }
  

  // view controller passes in attribute values in cell for row at indexPath
  func configure(withAttributeName name: StarWarsEntity.PropertyNames, andValue value: String) {
    attributeNameLabel.text = name.rawValue
    attributeValueLabel.text = value.lowercased() == "unknown" ? value.capitalized : value.roundToPlaces(decimalPlaces: 2)
    convertToMeasurementSystem(delegate!.defaults.measurementSystem)
  }
  
  // MARK: IBActions
  @IBAction func toEnglishMeasurement() {
    // don't convert if not a number
    if attributeValueLabel.text?.lowercased() == "unknown" {
      return
    }
    convertToMeasurementSystem(.english)
  }
  
  @IBAction func toMetricMeasurement() {
    if attributeValueLabel.text?.lowercased() == "unknown" {
      return
    }
    convertToMeasurementSystem(.metric)
  }
  
}
