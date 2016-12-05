//
//  SwapiClient.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/21/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

enum SWAPIClientError: Error {
  case unsuccessfulRequest(message: String)
}

enum SWAPI: Endpoint {
  case characters
  case vehicles
  case starships
  case property(String)
  case nextPage(String)
  
  enum SWPath: String {
    case base = "http://swapi.co/api/"
    case people
    case vehicles
    case starships
  }
  
  var baseURL: String {
    return SWPath.base.rawValue
  }
  
  var path: String {
    switch self {
      case .characters: return "\(SWPath.people.rawValue)/"
      case .vehicles: return "\(SWPath.vehicles.rawValue)/"
      case .starships: return "\(SWPath.starships.rawValue)/"
      case .property(let planetURLString):
        let path = planetURLString.substring(from: baseURL.endIndex)
        return path
      case .nextPage(let urlString):
        return urlString.substring(from: baseURL.endIndex)
    }
  }
}

struct SWSettings {
  var measurementSystem: MeasurementSystem
  var currentCurrency: CurrencyUnit
  var exchangeRate: Double
}

final class SWAPIClient: APIClient {
  static let sharedClient = SWAPIClient()
  var nextPage: Endpoint? // used to identify if another page for a resources is available
  var defaults: SWSettings // used to sync cell data with viewController data
  let configuration: URLSessionConfiguration
  let dispatchGroup = DispatchGroup()
  lazy var session: URLSession = {
    return URLSession(configuration: self.configuration)
  }()
  
  init(configuration: URLSessionConfiguration) {
    self.configuration = configuration
    self.defaults = SWSettings(measurementSystem: .english, currentCurrency: .GalacticCredits, exchangeRate: 1.0)
  }
  
  convenience init() {
    self.init(configuration: .default)
  }
  
  // fetches the first "page" for any given endpoint, and stores the next page url if there is one. If it is nil, the
  // client can be queried for a nil nextPage property to know if it has more pages to fetch.
  func fetchPage(for endpoint: Endpoint, completion: @escaping (APIResult<[StarWarsEntity]>) -> Void) {
    fetch(endpoint: endpoint, parse: { (json) -> [StarWarsEntity]? in
      guard let results = json["results"] as? [[String: Any]] else {
        return nil
      }
      if let next = json["next"] as? String {
        self.nextPage = SWAPI.nextPage(next)
      } else {
        self.nextPage = nil
      }
      return results.flatMap { StarWarsEntity(JSON: $0) }
    }, completion: completion)
  }
  
  // fetches an individual property for an array of Characters
  func update(property name: StarWarsEntity.PropertyNames, for characters: [StarWarsEntity.Person], completion: @escaping (APIResult<[StarWarsEntity]>) -> Void) {
    var error = SWAPIClientError.unsuccessfulRequest(message: "None")
    var updatedCharacters = characters
    let URLs = extract(property: name, from: characters)
    // iterate through the list of url's for properties and submit a request for each one
    for URL in URLs {
      dispatchGroup.enter()
      fetch(endpoint: SWAPI.property(URL), parse: { (json) -> [StarWarsEntity.Person]? in
        self.dispatchGroup.leave()
        guard let newName = json[StarWarsEntity.SWKeys.name.rawValue] as? String else {
          error = SWAPIClientError.unsuccessfulRequest(message: "Unable to find \(name.rawValue)")
          return nil
        }
        // update the passed in characters that have the property that matches the one being searched
        return self.updateProperty(for: updatedCharacters, oldName: URL, newName: newName)
      }, completion: { result in
        switch result {
          case .success(let updated):
            updatedCharacters = updated
          case .failure(let partialError): error = SWAPIClientError.unsuccessfulRequest(message: partialError.localizedDescription)
        }
      })
    }
    dispatchGroup.notify(queue: .main) {
      // updated characters should always match number of passed in characters
      if updatedCharacters.count == characters.count {
        completion(APIResult.success(updatedCharacters.map { StarWarsEntity.person($0) }))
      } else {
        error = SWAPIClientError.unsuccessfulRequest(message: "Error fetching \(name.rawValue) for all characters")
        completion(APIResult.failure(error))
      }
    }
  }
  
  // filters all the people in param 1 that have a value of param 2 and replaces with param 3
  func updateProperty(for people: [StarWarsEntity.Person], oldName old: String, newName new: String) -> [StarWarsEntity.Person] {
    let newValues = people.enumerated().map { (index, person) -> StarWarsEntity.Person in
      var mutablePerson = person
      switch old {
        case let url where url.contains("planets"):
          if mutablePerson.home == old {
            mutablePerson.home = new
          } else {
            return person
          }
        case let url where url.contains(StarWarsEntity.SWKeys.vehicles.rawValue):
          if let index = mutablePerson.vehicles.index(of: old) {
            mutablePerson.vehicles[index] = new
          } else {
            return person
          }
        case let url where url.contains(StarWarsEntity.SWKeys.starships.rawValue):
          if let index = mutablePerson.starships.index(of: old) {
            mutablePerson.starships[index] = new
          } else {
            return person
        }
        default: break
      }
      return mutablePerson
    }
    return newValues
  }
  
  
  // for updating a collection with newly requested property values
  func updatePropertyForCollection(property name: StarWarsEntity.PropertyNames, oldValues: [StarWarsEntity], newValues: [StarWarsEntity]) -> [StarWarsEntity] {
    // search for the property name and update
    let newValues = oldValues.enumerated().map { (index, person) -> StarWarsEntity in
      let newValue = newValues[index].entity as! StarWarsEntity.Person
      var mutablePerson = person.entity as! StarWarsEntity.Person
      switch name {
        case .Home:
          mutablePerson.home = newValue.home
          return StarWarsEntity.person(mutablePerson)
        case .Vehicles:
          mutablePerson.vehicles = newValue.vehicles
          return StarWarsEntity.person(mutablePerson)
        case .Starships:
          mutablePerson.starships = newValue.starships
          return StarWarsEntity.person(mutablePerson)
        default: return person
      }
    }
    return newValues
  }
  
  
  // gets all of the individual property values from an array of characters
  func extract(property name: StarWarsEntity.PropertyNames, from characters: [StarWarsEntity.Person]) -> Set<String> {
    var setOfProperties = Set<String>()
    switch name {
    case .Vehicles:
      let vehicles = characters.flatMap { $0.vehicles }
      setOfProperties = Set(vehicles.map { $0 })
    case .Starships:
      let starships = characters.flatMap { $0.starships }
      setOfProperties = Set(starships.map { $0 })
    case .Home:
      let planets = characters.map { $0.home }
      setOfProperties = Set(planets)
    default: break
    }
    return setOfProperties
  }
  
  // takes any number of starwars entities and returns the name of the smallest and largest in the group
  func smallestAndLargest(from collection: [StarWarsEntity]) -> (smallest: String, largest: String)? {
    let sorted = collection.sorted(by: { firstEntity, secondEntity in
      let first = firstEntity.entity
      let second = secondEntity.entity
      if let first = first as? StarWarsEntity.Person, let second  = second as? StarWarsEntity.Person {
        // don't try to calculate height for unknown values
        if first.height == "unknown" || second.height == "unknown" {
          return false
        } else {
          let heightOne = first.height.replacingOccurrences(of: "ft", with: "")
          let heightTwo = second.height.replacingOccurrences(of: "ft", with: "")
          return Double(heightOne)! < Double(heightTwo)!
        }
      } else if let first = first as? Manned, let second = second as? Manned {
        if first.length == "unknown" || second.length == "unknown" {
          return false
        } else {
          let lengthOne = first.length.replacingOccurrences(of: "ft", with: "")
          let lengthTwo = second.length.replacingOccurrences(of: "ft", with: "")
          return Double(lengthOne)! < Double(lengthTwo)!
        }
      } else {
        return false
      }
    })
    let smallest = sorted.first?.entity as! StarWarsType
    let largest = sorted.last?.entity as! StarWarsType
    return (smallest: smallest.name, largest: largest.name)
  }
}
