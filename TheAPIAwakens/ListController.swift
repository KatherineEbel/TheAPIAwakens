//
//  ListController.swift
//  TheAPIAwakens
//
//  Created by Katherine Ebel on 11/28/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import UIKit

class ListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var starwarsCollectionPicker: SWCollectionPicker!
  @IBOutlet weak var starwarsEntityTableView: UITableView!
  @IBOutlet weak var selectedEntityName: UILabel!
  
  var starwarsCollection: [Any] = []

    override func viewDidLoad() {
      super.viewDidLoad()
      print(starwarsCollection)
      setNavTitle()
      starwarsCollectionPicker.selectRow(1, inComponent: 0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath) 

        // Configure the cell...

        return cell
    }

    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  func setNavTitle() {
    if starwarsCollection is [StarWarsEntity.Person] {
      self.navigationItem.title = "Characters"
    } else if starwarsCollection is [StarWarsEntity.Vehicle] {
      self.navigationItem.title = "Vehicles"
    } else if starwarsCollection is [StarWarsEntity.Starship] {
      self.navigationItem.title = "Starships"
    }
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
    let title = (starwarsCollection[row] as! StarWarsType).name
    return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.white])
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedEntityName.text = (starwarsCollection[row] as! StarWarsType).name
  }
  
  
}
