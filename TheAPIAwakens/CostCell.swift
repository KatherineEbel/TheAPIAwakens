//
//  CostCell.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/28/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

typealias Dollars = Double
typealias GalacticCredits = Double


enum CostCellError: Error {
  case invalidConversionRate(message: String)
}

enum CurrencyUnit {
  case USDollars
  case GalacticCredits
}

protocol CostCellDelegate {
  func shouldChangeConversionRate(for cell: CostCell)
}

class CostCell: UITableViewCell {
  
  
  @IBOutlet weak var attributeNameLabel: UILabel!
  @IBOutlet weak var attributeValueLabel: UILabel!
  @IBOutlet weak var conversionButton: UIButton!
  
  var conversionRate = 1.0
  var currentCurrency = CurrencyUnit.GalacticCredits {
    didSet {
      if let delegate = delegate as? ListController {
        delegate.currentCurrency = self.currentCurrency
      }
    }
  }
  var delegate: CostCellDelegate! = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  func convertToUSDollars() {
    guard let galacticCredits = Double(attributeValueLabel.text!) else {
      return
    }
    currentCurrency = .USDollars
    conversionButton.setBackgroundImage(nil, for: .normal)
    conversionButton.setTitle("$", for: .normal)
    let rounded = roundToPlaces(value: galacticCredits * conversionRate, decimalPlaces: 2)
    attributeValueLabel.text = String(rounded)
  }
  
  func convertToGalacticCredits() {
    guard let dollars = Double(attributeValueLabel.text!) else {
      return
    }
    currentCurrency = .GalacticCredits
    let image = UIImage(named: "GalacticCredit")
    conversionButton.setBackgroundImage(image, for: .normal)
    conversionButton.setTitle("", for: .normal)
    let rounded = roundToPlaces(value: dollars / conversionRate, decimalPlaces: 2)
    attributeValueLabel.text = String(rounded)
  }
  
  @IBAction func convertCurrency(_ sender: UIButton) {
    switch currentCurrency {
      case .GalacticCredits: switchToCurrency(.USDollars)
      case .USDollars: switchToCurrency(.GalacticCredits)
    }
  }
  
  @IBAction func changeConversionRate() {
    if let delegate = delegate {
      delegate.shouldChangeConversionRate(for: self)
    }
  }
  
  func switchToCurrency(_ currency: CurrencyUnit) {
    switch currency {
      case .GalacticCredits: convertToGalacticCredits()
      case .USDollars: convertToUSDollars()
    }
  }
  
  func changeConversionRate(usingString value: String) throws {
    guard let amount = Double(value) else {
      throw CostCellError.invalidConversionRate(message: "Could not convert given value to a valid conversion rate")
    }
    conversionRate = amount
  }
}
