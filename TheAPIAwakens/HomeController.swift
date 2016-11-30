//
//  HomeController.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/21/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
  
  @IBOutlet weak var progressView: UIView!
  @IBOutlet weak var progressSpinner: UIActivityIndicatorView!
  var starwarsCollection = [StarWarsEntity]()
  var swapiClient = SWAPIClient.sharedClient

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func activateProgressSpinner() {
    progressView.isHidden = false
    progressSpinner.startAnimating()
  }
  
  func deactivateProgressSpinner() {
    progressView.isHidden = true
    progressSpinner.stopAnimating()
  }
  
  @IBAction func fetchCharacters(_ sender: UIButton) {
    activateProgressSpinner()
    swapiClient.fetchCollection(for: SWAPI.characters) { result in
      switch result {
        case .success(let entities):
          if let characters = (entities.map { $0.entity }) as? [StarWarsEntity.Person] {
            self.swapiClient.getPlanetNames(for: characters) { result in
              self.deactivateProgressSpinner()
              switch result {
                case .success(let characters):
                  self.starwarsCollection = characters
                  self.performSegue(withIdentifier: "viewCollection", sender: self)
                case .failure(let error): print(error.localizedDescription)
              }
            }
          }
        case .failure(let error): print(error.localizedDescription)
      }
    }
  }
  
  @IBAction func fetchVehicles(_ sender: UIButton) {
    activateProgressSpinner()
    swapiClient.fetchCollection(for: SWAPI.vehicles) { result in
      self.deactivateProgressSpinner()
      switch result {
        case .success(let collection):
          self.starwarsCollection = collection
          self.performSegue(withIdentifier: "viewCollection", sender: self)
        case .failure(let error): print(error.localizedDescription)
      }
    }
  }

  @IBAction func fetchStarships(_ sender: UIButton) {
    activateProgressSpinner()
    swapiClient.fetchCollection(for: SWAPI.starships) { result in
      self.deactivateProgressSpinner()
      switch result {
        case .success(let collection):
          self.starwarsCollection = collection
          self.performSegue(withIdentifier: "viewCollection", sender: self)
        case .failure(let error): print(error.localizedDescription)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let listController = segue.destination as! ListController
    listController.starwarsCollection = self.starwarsCollection
  }

}

