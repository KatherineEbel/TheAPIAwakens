//
//  ListController.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/28/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit


class ListController: UIViewController {
  
  @IBOutlet weak var starwarsCollectionPicker: SWCollectionPicker!
  @IBOutlet weak var selectedEntityName: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var smallestNameLabel: UILabel!
  @IBOutlet weak var largestNameLabel: UILabel!
  
  var starwarsCollection: [StarWarsEntity] = []
  var selectedEntity: StarWarsEntity! {
    let entity = starwarsCollection[starwarsCollectionPicker.selectedRow(inComponent: 0)]
    return entity
  }
  var currentConversionRate = 1.0
  var currentCurrency = CurrencyUnit.GalacticCredits
  var currentMeasurementSystem = MeasurementSystem.english

    override func viewDidLoad() {
      super.viewDidLoad()
      setNavTitle()
      updateSmallAndLargeLabels()
      selectedEntityName.text = (selectedEntity.entity as! StarWarsType).name
    }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationItem.backBarButtonItem?.title = ""
  }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  func setNavTitle() {
    if let _ = selectedEntity.entity as? StarWarsEntity.Person {
      self.navigationItem.title = "Characters"
    } else if let _ =  selectedEntity.entity as? StarWarsEntity.Vehicle {
      self.navigationItem.title = "Vehicles"
    } else if let _ = selectedEntity.entity as? StarWarsEntity.Starship {
      self.navigationItem.title = "Starships"
    }
  }
  
  func updateSmallAndLargeLabels() {
    if let sizes = SWAPIClient.sharedClient.smallestAndLargest(from: starwarsCollection) {
      smallestNameLabel.text = sizes.smallest
      largestNameLabel.text = sizes.largest
    }
  }
  
  func alertForErrorMessage(_ message: String) {
    let alertController = UIAlertController(title: "Oops! We had a problem!", message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(okAction)
    present(alertController, animated: true, completion: nil)
  }

}

// MARK: Tableview datasource and delegate
extension ListController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      tableView.rowHeight = 44.0
        return 5
    }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let attributeName = selectedEntity.propertyNames[indexPath.row]
    let attributeValue = selectedEntity.propertyValues[indexPath.row]
    if attributeName == .Cost {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CostCell", for: indexPath) as! CostCell
      cell.configure(withAttributeName: attributeName, andValue: attributeValue)
      cell.delegate = self
      return cell
    } else if attributeName == .Length || attributeName == .Height {
      let cell = tableView.dequeueReusableCell(withIdentifier: "LengthCell", for: indexPath) as! LengthCell
      cell.delegate = self
      cell.configure(withAttributeName: attributeName, andValue: attributeValue)
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath) as! DefaultCell
      cell.configure(withAttributeName: attributeName, andValue: attributeValue)
      return cell
    }
  }
  
  // Override to support conditional editing of the table view.
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      // Return false if you do not want the specified item to be editable.
      return false
  }
}

// MARK: UIPickerDatasource and delegate
extension ListController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1 // only one component in picker with the entity's name
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return starwarsCollection.count // one row per entity
  }
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    // change attributes of row to white text so it can be seen on dark background
    let title = (starwarsCollection[row].entity as! StarWarsType).name
    return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.white])
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedEntityName.text = (starwarsCollection[row].entity as! StarWarsType).name
    tableView.reloadData()
  }
}

// MARK: Cell Delegates -- keep users choices in sync
extension ListController: CostCellDelegate, LengthCellDelegate {
  
  func measurementSystemDidChange(for cell: LengthCell) {
    currentMeasurementSystem = cell.currentMeasurementSystem
  }
  func currencyUnitDidChange(for cell: CostCell) {
    currentCurrency = cell.currentCurrency
  }
  
  func conversionRateDidChange(for cell: CostCell) {
    currentConversionRate = cell.conversionRate
  }
  
  // presents user with an alert that has a textfield in which they can enter a new conversion rate
  func shouldChangeConversionRate(for cell: CostCell) {
    let alertController = UIAlertController(title: "Change conversion rate", message: "How many USD is one credit worth?", preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "Amount must be greater than 0"
    }
    let confirmAction = UIAlertAction(title: "Confirm Amount?", style: .default) { _ in
        let userAmount = alertController.textFields?[0].text
      do {
        if let userAmount = userAmount {
          try cell.changeConversionRate(usingString: userAmount)
        }
      } catch CostCellError.invalidConversionRate(message: let message)  {
        self.alertForErrorMessage(message)
      } catch let error {
        self.alertForErrorMessage(error.localizedDescription)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(confirmAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
}
