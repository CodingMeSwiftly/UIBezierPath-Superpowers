//
//  PerpendicularDemoView.swift
//  BezierPlayground
//
//  Created by Maximilian Kraus on 31.07.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

class PerpendicularDemoView: MXView {
  
  var showLookupPoints = true {
    didSet {
      if oldValue != showLookupPoints {
        setNeedsLayout()
      }
    }
  }
  
  var path: UIBezierPath?
  
  var pathRect: CGRect {
    return CGRect(x: 64, y: 84, width: frame.width - 128, height: frame.height - 168)
  }
  
  fileprivate let shapeLayer = CAShapeLayer()
  fileprivate var pointLayers: [CALayer] = []
  
  let perpendicularLayer = CAShapeLayer()
  
  let hintLabel = UILabel()
  
  override init() {
    super.init()
    
    backgroundColor = .white
    
    shapeLayer.lineWidth = 1
    shapeLayer.lineCap = kCALineCapRound
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = UIColor.black.cgColor
    layer.addSublayer(shapeLayer)
    
    hintLabel.isUserInteractionEnabled = false
    hintLabel.numberOfLines = 0
    hintLabel.textAlignment = .center
    hintLabel.text = "Touch and hold to see the perpendicular."
    hintLabel.textColor = UIColor(hue: 0, saturation: 0, brightness: 0.39, alpha: 1)
    hintLabel.sizeToFit()
    addSubview(hintLabel)
    
    
    perpendicularLayer.opacity = 0
    perpendicularLayer.strokeColor = UIColor.red.cgColor
    perpendicularLayer.lineWidth = 4
    layer.addSublayer(perpendicularLayer)
  }
  
  func configure(with path: UIBezierPath) {
    self.path = path
    setNeedsLayout()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let path = path else { return }
    
    //  Scale to fit and center path inside the center of this view.
    let scale = min(pathRect.width / path.bounds.width, pathRect.height / path.bounds.height)
    if scale != 1 {
      path.apply(CGAffineTransform(scaleX: scale, y: scale))
    }
    
    let offset = UIOffset(horizontal: pathRect.midX - path.bounds.midX, vertical: pathRect.midY - path.bounds.midY)
    if offset != .zero {
      path.apply(CGAffineTransform(translationX: offset.horizontal, y: offset.vertical))
    }
    
    shapeLayer.path = nil
    shapeLayer.path = path.cgPath
    
    for l in pointLayers {
      l.removeFromSuperlayer()
    }
    
    pointLayers.removeAll()
    
    if showLookupPoints {
      let table = path.mx_lookupTable
      
      for p in table {
        let pointLayer = CALayer()
        pointLayer.backgroundColor = UIColor.magenta.cgColor
        pointLayer.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
        pointLayer.cornerRadius = 2
        pointLayer.position = p
        
        pointLayers.append(pointLayer)
        layer.addSublayer(pointLayer)
      }
    }

    hintLabel.center = CGPoint(x: pathRect.midX, y: 0)
    hintLabel.frame.origin.y = bounds.height - hintLabel.frame.height - 24
  }
}
