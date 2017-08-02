//
//  FractionDemoView.swift
//  UIBezierPath+Length
//
//  Created by Maximilian Kraus on 15.07.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

class FractionDemoView: MXView {
  
  var scaleAndCenterPath = true
  
  var path: UIBezierPath?
  
  var pathRect: CGRect {
    return CGRect(x: 16, y: 84, width: frame.width - 32, height: frame.height / 2)
  }
  
  fileprivate let shapeLayer = CAShapeLayer()
  let dotLayer = CALayer()
  let slider = UISlider()
  fileprivate let sliderValueLabel = UILabel()
  fileprivate let lengthLabel = UILabel()
  fileprivate let hintLabel = UILabel()
  
  override init() {
    super.init()
    
    backgroundColor = .white
    
    shapeLayer.lineWidth = 1
    shapeLayer.lineCap = kCALineCapRound
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = UIColor.black.cgColor
    layer.addSublayer(shapeLayer)
    
    dotLayer.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    dotLayer.backgroundColor = tintColor.cgColor
    dotLayer.cornerRadius = dotLayer.frame.width / 2
    layer.addSublayer(dotLayer)
    
    slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
    slider.sizeToFit()
    addSubview(slider)
    
    addSubview(sliderValueLabel)
    addSubview(lengthLabel)
    
    hintLabel.text = "Tap to add line point."
    hintLabel.textColor = UIColor(hue: 0, saturation: 0, brightness: 0.39, alpha: 1)
    hintLabel.sizeToFit()
    addSubview(hintLabel)
  }
  
  
  func configure(with path: UIBezierPath) {
    self.path = path
    setNeedsLayout()
  }
  
  
  @objc private func sliderValueChanged(sender: UISlider) {
    sliderValueLabel.text = "Slider value: \(CGFloat(slider.value).string(fractionDigits: 2))"
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let path = path else { return }
    
    if scaleAndCenterPath {
      //  Scale to fit and center path inside the top half of this view.
      let scale = min(pathRect.width / path.bounds.width, pathRect.height / path.bounds.height)
      if scale != 1 {
        path.apply(CGAffineTransform(scaleX: scale, y: scale))
      }
      
      let offset = UIOffset(horizontal: pathRect.midX - path.bounds.midX, vertical: pathRect.midY - path.bounds.midY)
      if offset != .zero {
        path.apply(CGAffineTransform(translationX: offset.horizontal, y: offset.vertical))
      }
    }
    
    shapeLayer.path = nil
    shapeLayer.path = path.cgPath
    
    
    //  Re-position the dot (neccessary for valid layout after rotation).
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    dotLayer.position = path.mx_point(atFractionOfLength: CGFloat(slider.value))
    CATransaction.commit()
    
    
    slider.frame.origin.x = 32
    slider.frame.origin.y = pathRect.maxY + 44
    slider.frame.size.width = bounds.width - 64
    
    sliderValueLabel.text = "Slider value: \(CGFloat(slider.value).string(fractionDigits: 2))"
    sliderValueLabel.sizeToFit()
    sliderValueLabel.frame.size.width = slider.frame.width
    sliderValueLabel.frame.origin.x = 32
    sliderValueLabel.frame.origin.y = slider.frame.maxY + 24
    
    lengthLabel.text = "Path length: \(path.mx_length.string(fractionDigits: 2))"
    lengthLabel.sizeToFit()
    lengthLabel.frame.origin.x = 32
    lengthLabel.frame.origin.y = sliderValueLabel.frame.maxY + 32
    
    hintLabel.center = CGPoint(x: pathRect.midX, y: pathRect.midY)
    hintLabel.isHidden = !path.isEmpty
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    UIColor(hue: 0, saturation: 0, brightness: 0.94, alpha: 1).setFill()
    UIRectFill(pathRect.insetBy(dx: -8, dy: -8))
  }
}

fileprivate extension CGFloat {
  func string(fractionDigits:Int) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = fractionDigits
    formatter.maximumFractionDigits = fractionDigits
    formatter.decimalSeparator = "."
    return formatter.string(from: NSNumber(value: Float(self))) ?? "\(self)"
  }
}
