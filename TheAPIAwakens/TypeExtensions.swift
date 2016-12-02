//
//  StringExtension.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/29/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import Foundation

// this String extension is for convenience of converting API values in to the correct measurements

extension String {
  func toFeetFromCentimeters() -> String {
    if let centimeters = Double(self) {
      let feetPerCentimeter = 0.0328084
      let result = String(centimeters * feetPerCentimeter).roundToPlaces(decimalPlaces: 2)
      return String(result)
    } else {
      return self
    }
  }
  
  func fromFeetToMeters() -> String {
    if let feet = Double(self) {
      let feetPerMeter = 3.28084
      let result = String(feet / feetPerMeter).roundToPlaces(decimalPlaces: 2)
      return result
    } else {
      return self
    }
  }
  
  func toFeetFromMeters() -> String {
    if let meters = Double(self) {
      let metersPerFoot = 0.3048
      let feet = String((meters / metersPerFoot)).roundToPlaces(decimalPlaces: 2)
      return feet
    } else {
      return self
    }
  }
  
  func roundToPlaces(decimalPlaces: Int) -> String {
    if let double = Double(self) {
      let divisor = pow(10.0, Double(decimalPlaces))
      let rounded = (double * divisor).rounded() / divisor
      let result = String(rounded)
      return result
    } else {
      return self
    }
  } 
}
