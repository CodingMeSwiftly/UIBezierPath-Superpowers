//
//  AppDelegate.swift
//  UIBezierPath+Length
//
//  Created by Maximilian Kraus on 06.06.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  override init() {
    super.init()
    
    UIBezierPath.mx_prepare()
  }
}
