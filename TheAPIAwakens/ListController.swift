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

}

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
      setup(costCell: cell)
      cell.attributeNameLabel.text = attributeName.rawValue
      cell.attributeValueLabel.text = attributeValue
      return cell
    } else if attributeName == .Length || attributeName == .Height {
      let cell = tableView.dequeueReusableCell(withIdentifier: "LengthCell", for: indexPath) as! LengthCell
      cell.attributeNameLabel.text = attributeName.rawValue
      cell.attributeValueLabel.text = attributeName == .Height ? attributeValue.toFeetFromCentimeters() : attributeValue.toFeetFromMeters()
      cell.unitsLabel.text = "ft"
      cell.resetConversionButtons()
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath) as! DefaultCell
      cell.attributeNameLabel.text = attributeName.rawValue
      cell.attributeValueLabel.text = attributeValue.capitalized
      return cell
    }
  }
  
  func setup(costCell cell: CostCell) {
    cell.delegate = self
    cell.conversionRate = currentConversionRate
    if cell.currentCurrency != currentCurrency {
      cell.currentCurrency = currentCurrency
    }
  }


    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
}

extension ListController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return starwarsCollection.count
  }
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    let title = (starwarsCollection[row].entity as! StarWarsType).name
    return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.white])
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedEntityName.text = (starwarsCollection[row].entity as! StarWarsType).name
    tableView.reloadData()
  }
}

extension ListController: CostCellDelegate {
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
        print(message)
      } catch let error {
        print(error.localizedDescription)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(confirmAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
}
