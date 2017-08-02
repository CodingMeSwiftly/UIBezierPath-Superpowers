//
//  Demos.swift
//  UIBezierPath+Length
//
//  Created by Maximilian Kraus on 15.07.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

enum Demo {
  case chaos, santa, tan, apeidos, slope, custom
  
  static var fractionDemos: [Demo] {
    return [.santa, .chaos, .apeidos, .tan, .custom]
  }
  
  static var perpendicularDemos: [Demo] {
    return [.santa, .chaos, .apeidos, .tan]
  }
  
  static var tangentDemos: [Demo] {
    return [.santa, .chaos, .apeidos, .tan, .slope]
  }
  
  var path: UIBezierPath {
    switch self {
    case .chaos:
      return UIBezierPath.pathWithSVG(fileName: "chaos")
    case .santa:
      return UIBezierPath.pathWithSVG(fileName: "santa")
    case .tan:
      return UIBezierPath.pathWithSVG(fileName: "tan")
    case .apeidos:
      return UIBezierPath.pathWithSVG(fileName: "apeidos")
    case .slope:
      return UIBezierPath.pathWithSVG(fileName: "slope")
    case .custom:
      return UIBezierPath()
    }
  }
  
  var displayName: String {
    switch self {
    case .chaos:
      return "Chaos"
    case .santa:
      return "Santas house"
    case .tan:
      return "Tan-ish"
    case .apeidos:
      return "Apeidos"
    case .slope:
      return "Slope"
    case .custom:
      return "Custom"
    }
  }
}
