//
//  CalculationSettings.swift
//  BezierPathSuperpowers
//
//  Created by Maximilian Kraus on 01.02.18.
//  Copyright © 2018 Maximilian Kraus. All rights reserved.
//

import Foundation

public struct CalculationSettings {
  public enum LengthPrecision: Int {
    case low = 50
    case normal = 100
    case high = 150
  }
  
  public enum PerpendicularPrecision: CGFloat {
    case low = 15
    case normal = 5
    case high = 2
  }
  
  public var lengthPrecision: LengthPrecision
  public var perpendicularPrecision: PerpendicularPrecision
}


public extension CalculationSettings {
  static let bestPerformance = CalculationSettings(lengthPrecision: .low, perpendicularPrecision: .low)
  static let bestQuality = CalculationSettings(lengthPrecision: .high, perpendicularPrecision: .high)
  static let balanced = CalculationSettings(lengthPrecision: .normal, perpendicularPrecision: .normal)
}
