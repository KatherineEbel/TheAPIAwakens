//
//  HomeController.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/21/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

// MARK: HomeController Helper Types
enum HomeControllerError {
  case noAPIResponse(message: String)
}

enum SegueIdentifier: String {
  case viewCollection
}

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
  
  // will cancel downloads in progress
  func cancelDownloads() {
    swapiClient.session.getAllTasks { tasks in
      _ = tasks.map { $0.cancel() }
    }
  }
  
  func removeCancelButton() {
    self.navigationItem.rightBarButtonItem = nil
  }
  
  // Adds a barbutton item for user to cancel a request if it is taking too long
  func addCancelRequestButton() {
    let cancelButton = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(HomeController.cancelDownloads))
    self.navigationItem.rightBarButtonItem = cancelButton
  }
  
  func fetch(_ endpoint: Endpoint, completion: @escaping (() -> ())) {
    addCancelRequestButton()
    activateProgressSpinner()
    swapiClient.fetchPage(for: endpoint) { result in
      switch result {
        case .success(let collection): self.starwarsCollection = collection
        case .failure(let error): self.handle(error)
      }
      completion()
      self.removeCancelButton()
    }
  }
  func handle(_ error: Error) {
    deactivateProgressSpinner()
    if error is NetworkingError {
      self.alertForErrorMessage((error as! NetworkingError).errorDescription!)
    } else {
      self.alertForErrorMessage(error.localizedDescription)
    }
  }
  
  @IBAction func fetchCharacters(_ sender: UIButton) {
    fetch(SWAPI.characters) {
      let properties: [StarWarsEntity.PropertyNames] = [.Home, .Vehicles, .Starships]
      let entities = self.starwarsCollection.map { $0.entity as! StarWarsEntity.Person }
      for property in properties {
        self.swapiClient.update(property: property, for: entities) { result in
          switch result {
            case .success(let updatedEntities):
              self.starwarsCollection = self.swapiClient.updatePropertyForCollection(property: property, oldValues: self.starwarsCollection, newValues: updatedEntities)
              if property == properties.last! {
                self.deactivateProgressSpinner()
                self.performSegue(withIdentifier: SegueIdentifier.viewCollection.rawValue, sender: nil)
              }
            case .failure(let error):
              if let clientError = error as? SWAPIClientError {
                self.deactivateProgressSpinner()
                self.alertForErrorMessage(clientError.errorDescription)
              }
          }
        }
      }
    }
  }
  
  @IBAction func fetchVehicles(_ sender: UIButton) {
    fetch(SWAPI.vehicles) {
      self.deactivateProgressSpinner()
      self.performSegue(withIdentifier: SegueIdentifier.viewCollection.rawValue, sender: self)
    }
  }

  @IBAction func fetchStarships(_ sender: UIButton) {
    fetch(SWAPI.starships) {
      self.deactivateProgressSpinner()
      self.performSegue(withIdentifier: SegueIdentifier.viewCollection.rawValue, sender: nil)
    }
  }
  
  // MARK: Helper Methods
  
  func activateProgressSpinner() {
    progressView.isHidden = false
    progressSpinner.startAnimating()
  }
  
  func deactivateProgressSpinner() {
    progressView.isHidden = true
    progressSpinner.stopAnimating()
  }
  
  func alertForErrorMessage(_ message: String) {
    let alertController = UIAlertController(title: "Oops! We had a problem!", message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(okAction)
    present(alertController, animated: true, completion: nil)
  }
  
  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let listController = segue.destination as! ListController
    listController.starwarsCollection = self.starwarsCollection
  }

}

