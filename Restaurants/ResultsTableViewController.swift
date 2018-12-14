//
//  ResultsTableViewController.swift
//  Restaurants
//
//  Created by Clay on 12/13/18.
//  Copyright © 2018 clay. All rights reserved.
//

import Foundation
import UIKit

protocol ResultsTableViewControllerDelegate: AnyObject {
  
  func resultsTableViewControllerDidSelect(restaurant: Restaurant)
  
}

class ResultsTableViewController: UITableViewController {
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  enum Constant {
    static let reuseIdentifier = "ResultsTableViewControllerReuseIdentifier"
  }
  
  var result: RestaurantsResult
  var delegate: ResultsTableViewControllerDelegate?
  
  init(result: RestaurantsResult) {
    self.result = result
    
    super.init(style: UITableView.Style.plain)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.result.results.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: Constant.reuseIdentifier) ?? UITableViewCell()
    
    if indexPath.row < result.results.count {
      let restaurant = result.results[indexPath.row]
      cell.textLabel?.text = restaurant.name
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row < result.results.count {
      self.delegate?.resultsTableViewControllerDidSelect(restaurant: result.results[indexPath.row])
    }
    self.tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func update(with result: RestaurantsResult) {
    self.result = result
    self.tableView.reloadData()
  }

}
