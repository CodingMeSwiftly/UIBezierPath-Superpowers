//
//  DemoListViewController.swift
//  UIBezierPath+Length
//
//  Created by Maximilian Kraus on 15.07.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

class DemoListViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .always
      navigationController?.navigationBar.prefersLargeTitles = true
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return Demo.fractionDemos.count
    case 1:
      return Demo.perpendicularDemos.count
    case 2:
      return Demo.tangentDemos.count
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.accessoryType = .disclosureIndicator
    
    switch indexPath.section {
    case 0:
      let demo = Demo.fractionDemos[indexPath.row]
      cell.textLabel?.text = demo.displayName
    case 1:
      let demo = Demo.perpendicularDemos[indexPath.row]
      cell.textLabel?.text = demo.displayName
    case 2:
      let demo = Demo.tangentDemos[indexPath.row]
      cell.textLabel?.text = demo.displayName
    default:
      break
    }
    
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      let demo = Demo.fractionDemos[indexPath.row]
      let next = FractionDemoViewController(demo: demo)
      navigationController?.pushViewController(next, animated: true)
    case 1:
      let demo = Demo.perpendicularDemos[indexPath.row]
      let next = PerpendicularDemoViewController(demo: demo)
      navigationController?.pushViewController(next, animated: true)
    case 2:
      let demo = Demo.tangentDemos[indexPath.row]
      let next = TangentDemoViewController(demo: demo)
      navigationController?.pushViewController(next, animated: true)
    default:
      break
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return "Point at fraction of length"
    case 1: return "Perpendicular"
    case 2: return "Tangent angle"
    default: return nil
    }
  }
}
