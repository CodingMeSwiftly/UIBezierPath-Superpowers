//
//  UIBezierPath+DemoPaths.swift
//  UIBezierPath+Length
//
//  Created by Maximilian Kraus on 15.07.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit
import PocketSVG

extension UIBezierPath {
  @nonobjc static func pathWithSVG(fileName: String) -> UIBezierPath {
    let svgURL = Bundle.main.url(forResource: fileName, withExtension: "svg")!
    let paths = SVGBezierPath.pathsFromSVG(at: svgURL)
    let path = UIBezierPath(cgPath: paths.first!.cgPath)
    
    //  Move bounds.origin to .zero
    let t = CGAffineTransform(translationX: -path.bounds.minX, y: -path.bounds.minY)
    path.apply(t)
    
    return path
  }
}
