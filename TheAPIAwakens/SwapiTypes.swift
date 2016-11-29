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

enum StarWarsEntity: JSONDecodable {
  case person(Person)
  case vehicle(Vehicle)
  case starship(Starship)
  
  var entity: Any {
    switch self {
      case .person(let person): return person
      case .vehicle(let vehicle): return vehicle
      case .starship(let starship): return starship
    }
  }
  
  struct Person: JSONDecodable {
    let name: String
    let born: String
    var home: String
    let height: String
    let eyes: String
    let hair: String
    let vehicles: [String]?
  }
  struct Vehicle: Manned {
    let name: String
    let make: String
    let cost: String
    let length: String
    let type: String
    let crew: String
    
    
  }
  struct Starship: Manned {
    let name: String
    let make: String
    let cost: String
    let length: String
    let type: String
    let crew: String
  }
  
  init?(JSON: [String : Any]) {
    if JSON.keys.contains("birth_year") {
      if let person = Person(JSON: JSON) {
        self = .person(person)
      } else {
        return nil
      }
    } else if JSON.keys.contains("vehicle_class") {
      if let vehicle = Vehicle(JSON: JSON) {
        self = .vehicle(vehicle)
      } else {
        return nil
      }
    } else if JSON.keys.contains("starship_class") {
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
    if let name = JSON["name"] as? String, let homeworld = JSON["homeworld"] as? String, let height = JSON["height"] as? String,
      let eyes = JSON["eye_color"] as? String, let hair = JSON["hair_color"] as? String, let vehicles = JSON["vehicles"] as? [String],
      let birthYear = JSON["birth_year"] as? String {
      self.name = name
      self.home = homeworld
      self.born = birthYear
      self.height = height
      self.eyes = eyes
      self.hair = hair
      self.vehicles = vehicles
    } else {
      return nil
    }
  }
}

extension StarWarsEntity.Vehicle {
  init?(JSON: JSON) {
    if let name = JSON["name"] as? String, let model = JSON["model"] as? String, let length = JSON["length"] as? String, let cost = JSON["cost_in_credits"] as? String, let type = JSON["vehicle_class"] as? String, let crew = JSON["crew"] as? String {
      self.name = name
      self.make = model
      self.length = length
      self.cost = cost
      self.crew = crew
      self.type = type
    } else {
      return nil
    }
  }
}

extension StarWarsEntity.Starship {
  init?(JSON: JSON) {
    if let name = JSON["name"] as? String, let model = JSON["model"] as? String, let length = JSON["length"] as? String, let cost = JSON["cost_in_credits"] as? String, let type = JSON["starship_class"] as? String, let crew = JSON["crew"] as? String {
      self.name = name
      self.make = model
      self.length = length
      self.cost = cost
      self.crew = crew
      self.type = type
    }
    return nil
  }
}
