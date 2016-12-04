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
  case planets(String)
  case nextPage(String)
  
  var baseURL: String {
    return "http://swapi.co/api/"
  }
  
  var path: String {
    switch self {
      case .characters: return "people/"
      case .vehicles: return "vehicles/"
      case .starships: return "starships/"
      case .planets(let planetURLString):
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
  var nextPage: Endpoint?
  var defaults: SWSettings
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
  
  func getPlanetNames(for characters: [StarWarsEntity.Person], completion: @escaping (APIResult<[StarWarsEntity]>) -> Void)  {
    var updatedCharacters: [StarWarsEntity] = []
    var error: SWAPIClientError = SWAPIClientError.unsuccessfulRequest(message: "None")
    // turn list of planets into a set to avoid duplicated network requests
    let planets = Set(characters.map { $0.home })
    for (_, planet) in planets.enumerated() {
      dispatchGroup.enter()
      fetch(endpoint: SWAPI.planets(planet), parse: { (json) -> [StarWarsEntity]? in
        self.dispatchGroup.leave()
        guard let newName = json["name"] as? String else {
          return nil
        }
        // update the passed in character names that have the planet that matches current iteration
        let matching = self.updateHomelands(for: characters, planet, newName)
        return matching
      }, completion: { result in
        switch result {
          case .success(let updated): updatedCharacters.append(contentsOf: updated)
          case .failure(let partialError): error = SWAPIClientError.unsuccessfulRequest(message: partialError.localizedDescription)
        }
      })
    }
    dispatchGroup.notify(queue: .main) {
      // updated characters should al
      if updatedCharacters.count == characters.count {
        completion(APIResult.success(updatedCharacters))
      } else {
        error = SWAPIClientError.unsuccessfulRequest(message: "Error fetching homelands for all characters")
        completion(APIResult.failure(error))
      }
    }
  }
  
  // filters all the people in param 1 that have a planet property with value of param 2 and replaces with param 3
  func updateHomelands(for people: [StarWarsEntity.Person], _ currentPlanet: String, _ newPlanet: String) -> [StarWarsEntity] {
    return people.filter({ (person) -> Bool in
        person.home == currentPlanet
      }).map { person -> (StarWarsEntity) in
        var mutablePerson = person
        mutablePerson.home = newPlanet.capitalized
        return StarWarsEntity.person(mutablePerson)
      }
  }
  
  // takes any number of starwars entities and returns the name of the smallest and largest in the group
  func smallestAndLargest(from collection: [StarWarsEntity]) -> (smallest: String, largest: String)? {
    let sorted = collection.sorted(by: { firstEntity, secondEntity in
      let first = firstEntity.entity
      let second = secondEntity.entity
      if let first = first as? StarWarsEntity.Person, let second  = second as? StarWarsEntity.Person {
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
