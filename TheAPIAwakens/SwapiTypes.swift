//
//  SwapiTypes.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/21/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

protocol Manned: JSONDecodable {
  var name: String { get }
  var make: String { get }
  var cost: String { get }
  var length: String { get }
  var type: String { get }
  var crew: String { get }
  init?(JSON: JSON)
}

protocol StarWarsType {
  var name: String { get }
}

enum StarWarsEntity: JSONDecodable {
  case person(Person)
  case vehicle(Vehicle)
  case starship(Starship)
  
  // SWAPI keys
  enum SWKeys: String {
    case name
    case homeworld
    case height
    case eye_color
    case hair_color
    case birth_year
    case vehicles
    case model
    case starship_class
    case vehicle_class
    case crew
    case cost_in_credits
    case length
  }
  
  // SWEntity Property names
  enum PropertyNames: String {
    case Born
    case Home
    case Height
    case Eyes
    case Hair
    case Make
    case Cost
    case Length
    case Kind = "Type" // need to use different value since Type clashes with other properties
    case Crew
  }
  
  var entity: Any {
    switch self {
      case .person(let person): return person
      case .vehicle(let vehicle): return vehicle
      case .starship(let starship): return starship
    }
  }
  
  // return array of property names for each type. Makes easier for viewController to setup cells
  var propertyNames: [PropertyNames] {
    switch self {
      case .person(_):
        return [.Born, .Home, .Height, .Eyes, .Hair]
      case .vehicle, .starship:
        return [.Make, .Cost, .Length, .Kind, .Crew]
    }
  }
  
  var propertyValues: [String] {
    switch self {
    case .person(let person):
      return [person.born, person.home, person.height, person.eyes, person.hair]
    case .vehicle(let vehicle):
      return [vehicle.make, vehicle.cost, vehicle.length, vehicle.type, vehicle.crew]
    case .starship(let starShip):
      return [starShip.make, starShip.cost, starShip.length, starShip.type, starShip.crew]
    }
  }
  
  struct Person: JSONDecodable, StarWarsType {
    let name: String
    let born: String
    var home: String
    let height: String
    let eyes: String
    let hair: String
    let vehicles: [String]?
  }
  
  struct Vehicle: Manned, StarWarsType {
    let name: String
    let make: String
    let cost: String
    let length: String
    let type: String
    let crew: String
  }
  
  struct Starship: Manned, StarWarsType {
    let name: String
    let make: String
    let cost: String
    let length: String
    let type: String
    let crew: String
  }
  
  // allows initializing specific types from any JSON dictionary
  init?(JSON: [String : Any]) {
    if JSON.keys.contains(SWKeys.birth_year.rawValue) {
      if let person = Person(JSON: JSON) {
        self = .person(person)
      } else {
        return nil
      }
    } else if JSON.keys.contains(SWKeys.vehicle_class.rawValue) {
      if let vehicle = Vehicle(JSON: JSON) {
        self = .vehicle(vehicle)
      } else {
        return nil
      }
    } else if JSON.keys.contains(SWKeys.starship_class.rawValue) {
      if let starship = Starship(JSON: JSON) {
        self = .starship(starship)
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
}

extension StarWarsEntity.Person {
  init?(JSON: JSON) {
    let keys = StarWarsEntity.SWKeys.self
    if let name = JSON[keys.name.rawValue] as? String, let homeworld = JSON[keys.homeworld.rawValue] as? String, let height = JSON[keys.height.rawValue] as? String,
      let eyes = JSON[keys.eye_color.rawValue] as? String, let hair = JSON[keys.hair_color.rawValue] as? String, let vehicles = JSON[keys.vehicles.rawValue] as? [String],
      let birthYear = JSON[keys.birth_year.rawValue] as? String {
      self.name = name
      self.home = homeworld
      self.born = birthYear.uppercased()
      self.height = height.toFeetFromCentimeters()
      self.eyes = eyes.capitalized
      self.hair = hair.capitalized
      self.vehicles = vehicles
    } else {
      return nil
    }
  }
}

extension StarWarsEntity.Vehicle {
  init?(JSON: JSON) {
    let keys = StarWarsEntity.SWKeys.self
    if let name = JSON[keys.name.rawValue] as? String, let model = JSON[keys.model.rawValue] as? String, let length = JSON[keys.length.rawValue] as? String, let cost = JSON[keys.cost_in_credits.rawValue] as? String, let type = JSON[keys.vehicle_class.rawValue] as? String, let crew = JSON[keys.crew.rawValue] as? String {
      self.name = name
      self.make = model.capitalized
      self.length = length
      self.cost = cost.roundToPlaces(decimalPlaces: 2)
      self.crew = crew
      self.type = type.capitalized
    } else {
      return nil
    }
  }
}

extension StarWarsEntity.Starship {
  init?(JSON: JSON) {
    let keys = StarWarsEntity.SWKeys.self
    if let name = JSON[keys.name.rawValue] as? String, let model = JSON[keys.model.rawValue] as? String, let length = JSON[keys.length.rawValue] as? String, let cost = JSON[keys.cost_in_credits.rawValue] as? String, let type = JSON[keys.starship_class.rawValue] as? String, let crew = JSON[keys.crew.rawValue] as? String {
      self.name = name.capitalized
      self.make = model.capitalized
      self.length = length.replacingOccurrences(of: ",", with: "")
      self.cost = cost.roundToPlaces(decimalPlaces: 2)
      self.crew = crew
      self.type = type.capitalized
    } else {
      return nil
    }
  }
}
