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
    var result = centimeters * feetPerCentimeter
    result.roundToPlaces(decimalPlaces: 2)
    return String(result)
  }
  
  func fromFeetToMeters() -> String {
    let feet = Double(self)!
    let feetPerMeter = 3.28084
    var result = feet / feetPerMeter
    result.roundToPlaces(decimalPlaces: 2)
    return String(result)
  }
  
  func toFeetFromMeters() -> String {
    let meters = Double(self)!
    let metersPerFoot = 0.3048
    var result = (meters / metersPerFoot)
    result.roundToPlaces(decimalPlaces: 2)
    return String(result)
  }
  
}

extension Double {
  // Round the given value to a specified number
  // of decimal places
  mutating func roundToPlaces(decimalPlaces: Int) {
    let divisor = pow(10.0, Double(decimalPlaces))
    self = (self * divisor).rounded() / divisor
  } 
}
