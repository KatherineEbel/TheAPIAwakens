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
  
  var parameters: [String : Any]? {
    return nil
  }
}

final class SWAPIClient: APIClient {
  static let sharedClient = SWAPIClient()
  var nextPage: Endpoint?
  let configuration: URLSessionConfiguration
  let dispatchGroup = DispatchGroup()
  lazy var session: URLSession = {
    return URLSession(configuration: self.configuration)
  }()
  
  init(configuration: URLSessionConfiguration) {
    self.configuration = configuration
  }
  
  convenience init() {
    self.init(configuration: .default)
  }
  
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
    var error = NSError()
    // turn list of planets into a set to avoid duplicated network requests
    let planets = Set(characters.map { $0.home })
    for (_, planet) in planets.enumerated() {
      dispatchGroup.enter()
      fetch(endpoint: SWAPI.planets(planet), parse: { (json) -> [StarWarsEntity]? in
          guard let name = json["name"] as? String else {
            return nil
          }
        let matching = characters.filter({ (person) -> Bool in
          person.home == planet
        }).map { person -> (StarWarsEntity) in
          var mutablePerson = person
          mutablePerson.home = name.capitalized
          return StarWarsEntity.person(mutablePerson)
        }
        self.dispatchGroup.leave()
        return matching
      }, completion: { result in
        switch result {
          case .success(let updated): updatedCharacters.append(contentsOf: updated)
          case .failure(let partialError): error = partialError as NSError
        }
      })
    }
    dispatchGroup.notify(queue: .main) {
      if updatedCharacters.count == characters.count {
        completion(APIResult.success(updatedCharacters))
      } else {
        completion(APIResult.failure(error))
      }
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
          return Double(first.height)! < Double(second.height)!
        }
      } else if let first = first as? Manned, let second = second as? Manned {
        if first.length == "unknown" || second.length == "unknown" {
          return false
        } else {
          return Double(first.length)! < Double(second.length)!
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
