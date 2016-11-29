//
//  HomeController.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/21/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
  
  var starwarsEntities = [Any]()
  var swapiClient = SWAPIClient()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func fetchCharacters(_ sender: UIButton) {
    swapiClient.fetchPeople { result in
      switch result {
        case .success(let entities):
          if let characters = (entities.map { $0.entity }) as? [StarWarsEntity.Person] {
            self.swapiClient.getPlanetNames(for: characters) { result in
              switch result {
                case .success(let characters):
                  self.starwarsEntities = characters
                  print(characters)
                case .failure(let error): print(error.localizedDescription)
              }
            }
          }
        case .failure(let error): print(error)
      }
    }
  }
  
  @IBAction func fetchVehicles(_ sender: UIButton) {
  }

  @IBAction func fetchStarships(_ sender: UIButton) {
  }

}

