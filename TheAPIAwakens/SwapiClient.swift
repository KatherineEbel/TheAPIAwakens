//
//  SwapiClient.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/21/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

enum SWAPI: Endpoint {
  case characters
  case vehicles
  case starships
  case planets(String)
  
  var baseURL: URL {
    return URL(string: "http://swapi.co/api/")!
  }
  
  var path: String {
    switch self {
      case .characters: return "people"
      case .vehicles: return "vehicles"
      case .starships: return "starships"
      case .planets(let planetURLString):
        let endIndex = "http://swapi.co/api/".endIndex
        let path = planetURLString.substring(from: endIndex)
        return path
    }
  }
}

final class SWAPIClient: APIClient {
  static let sharedClient = SWAPIClient()
  let configuration: URLSessionConfiguration
  var collectionTitle: String = ""
  lazy var session: URLSession = {
    return URLSession(configuration: self.configuration)
  }()
  
  init(configuration: URLSessionConfiguration) {
    self.configuration = configuration
  }
  
  convenience init() {
    self.init(configuration: .default)
  }
  
  func fetchCollection(for endpoint: Endpoint, completion: @escaping (APIResult<[StarWarsEntity]>) -> Void) {
    fetch(endpoint: endpoint, parse: { (json) -> [StarWarsEntity]? in
      guard let results = json["results"] as? [[String : Any]] else {
        return nil
      }
      return results.flatMap { StarWarsEntity.init(JSON: $0) }
    }, completion: completion)
  }
  
  func getPlanetNames(for characters: [StarWarsEntity.Person], completion: @escaping (APIResult<[StarWarsEntity.Person]>) -> Void) {
    var updatedCharacters: [StarWarsEntity.Person] = []
    let planets = characters.map { $0.home }
    let dispatchGroup = DispatchGroup()
    for (index, planet) in planets.enumerated() {
      let request = SWAPI.planets(planet).request
      dispatchGroup.enter()
      fetch(request, parse: { (json) -> StarWarsEntity.Person? in
          guard let name = json["name"] as? String else {
            return nil
          }
          var character = characters[index]
          character.home = name
          dispatchGroup.leave()
          return character
      }, completion: { result in
        switch result {
          case .success(let character): updatedCharacters.append(character)
          case .failure(let error): print(error.localizedDescription)
        }
      })
    }
    dispatchGroup.notify(queue: .main) {
      completion(APIResult.success(updatedCharacters))
    }
  }
}
