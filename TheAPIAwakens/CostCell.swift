//
//  CostCell.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/28/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

enum CostCellError: Error {
  case invalidConversionRate(message: String)
}

enum CurrencyUnit {
  case USDollars
  case GalacticCredits
}

protocol CostCellDelegate: class {
  var defaults: SWSettings { get set }
  func shouldChangeConversionRate(for cell: CostCell)
  func currencyUnitDidChange(for cell: CostCell)
  func exchangeRateDidChange(for cell: CostCell)
}

class CostCell: UITableViewCell {
  
  
  @IBOutlet weak var attributeNameLabel: UILabel!
  @IBOutlet weak var attributeValueLabel: UILabel!
  @IBOutlet weak var conversionButton: UIButton!
  weak var delegate: CostCellDelegate?
  var exchangeRate = 1.0 {
    didSet {
      if let delegate = delegate {
        delegate.exchangeRateDidChange(for: self)
      }
    }
  }
  var currentCurrency = CurrencyUnit.GalacticCredits {
    didSet {
      if let delegate = delegate {
        delegate.currencyUnitDidChange(for: self)
      }
    }
  }

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
    let rounded = String(galacticCredits * exchangeRate).roundToPlaces(decimalPlaces: 2)
    attributeValueLabel.text = rounded
  }
  
  func convertToGalacticCredits() {
    guard let dollars = Double(attributeValueLabel.text!) else {
      return
    }
    currentCurrency = .GalacticCredits
    let image = UIImage(named: "GalacticCredit")
    conversionButton.setBackgroundImage(image, for: .normal)
    conversionButton.setTitle("", for: .normal)
    let rounded = String(dollars / exchangeRate).roundToPlaces(decimalPlaces: 2)
    attributeValueLabel.text = rounded
  }
  
  func configure(withAttributeName name: StarWarsEntity.PropertyNames, andValue value: String) {
    attributeNameLabel.text = name.rawValue
    attributeValueLabel.text = value.roundToPlaces(decimalPlaces: 2)
    conversionButton.isHidden = attributeValueLabel.text == "unknown"
    currentCurrency = (delegate?.defaults.currentCurrency)!
    exchangeRate = (delegate?.defaults.exchangeRate)!
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
    guard amount > 0.0 else {
      throw CostCellError.invalidConversionRate(message: "Value must be greater than 0")
    }
    exchangeRate = amount
    if currentCurrency == .USDollars {
      switchToCurrency(.USDollars)
    }
  }
}
