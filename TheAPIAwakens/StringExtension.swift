//
//  StringExtension.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/29/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import Foundation

extension String {
  
  
  func toFeetFromCentimeters() -> String {
    let centimeters = Double(self)!
    let feetPerCentimeter = 0.0328084
    let result = roundToPlaces(value: centimeters * feetPerCentimeter, decimalPlaces: 2)
    return String(result)
  }
  
  func fromFeetToMeters() -> String {
    let feet = Double(self)!
    let feetPerMeter = 3.28084
    let result = roundToPlaces(value: feet / feetPerMeter, decimalPlaces: 2)
    return String(result)
  }
  
  func toFeetFromMeters() -> String {
    let meters = Double(self)!
    let metersPerFoot = 0.3048
    let result = roundToPlaces(value: meters / metersPerFoot, decimalPlaces: 2)
    return String(result)
  }
  
}


  // Round the given value to a specified number
  // of decimal places
  public func roundToPlaces(value: Double, decimalPlaces: Int) -> Double {
    let divisor = pow(10.0, Double(decimalPlaces))
    return round(value * divisor) / divisor
  } 
