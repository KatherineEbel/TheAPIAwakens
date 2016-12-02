//: Playground - noun: a place where people can play

import Foundation

extension Double {
  // Round the given value to a specified number
  // of decimal places
  mutating func roundToPlaces(decimalPlaces: Int) {
    let divisor = pow(10.0, Double(decimalPlaces))
    self = (self * divisor).rounded() / divisor
  } 
}

var double = 1.345678
double.roundToPlaces(decimalPlaces: 2)


