//
//  Demos.swift
//  UIBezierPath+Length
//
//  Created by Maximilian Kraus on 15.07.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

//MARK: - Random numbers
fileprivate extension BinaryInteger {
  static func random(min: Self, max: Self) -> Self {
    assert(min < max, "min must be smaller than max")
    let delta = max - min
    return min + Self(arc4random_uniform(UInt32(delta)))
  }
}

fileprivate extension FloatingPoint {
  static func random(min: Self, max: Self, resolution: Int = 1000) -> Self {
    let randomFraction = Self(Int.random(min: 0, max: resolution)) / Self(resolution)
    return min + randomFraction * max
  }
}
//  -


enum Demo {
  case chaos, santa, tan, apeidos, slope, random, custom
  
  static var fractionDemos: [Demo] {
    return [.santa, .chaos, .apeidos, .tan, .random, .custom]
  }
  
  static var perpendicularDemos: [Demo] {
    return [.santa, .chaos, .apeidos, .tan, .random]
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
    case .random:
      let path = UIBezierPath()
      
      let randomPoints = (0..<14).map { _ in CGPoint(x: .random(min: 20, max: 280), y: .random(min: 20, max: 280)) }
      for (idx, p) in randomPoints.enumerated() {
        if idx % 3 != 0 {
          path.move(to: p)
        }
        
        path.addLine(to: p)
      }
      
      return path
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
    case .random:
      return "Random"
    }
  }
}
