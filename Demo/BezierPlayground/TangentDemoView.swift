//
//  TangentDemoView.swift
//  BezierPlayground
//
//  Created by Maximilian Kraus on 01.08.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

fileprivate extension FloatingPoint {
  var degreesToRadians: Self { return self * .pi / 180 }
  var radiansToDegrees: Self { return self * 180 / .pi }
}

class TangentDemoView: MXView {
  var path: UIBezierPath?
  
  var pathRect: CGRect {
    return CGRect(x: 16, y: 84, width: frame.width - 32, height: frame.height / 2)
  }
  
  let dotLayer = CALayer()
  let angleVertexLayer = CAShapeLayer()
  let slider = UISlider()
  
  
  fileprivate let shapeLayer = CAShapeLayer()
  fileprivate let sliderValueLabel = UILabel()
  fileprivate let angleValueLabel = UILabel()
  
  var angleValue: CGFloat = 0 {
    didSet {
      angleValueLabel.text = "Tangent angle: \(angleValue.radiansToDegrees.string(fractionDigits: 2)) °"
    }
  }
  
  override init() {
    super.init()
    
    backgroundColor = .white
    
    shapeLayer.lineWidth = 1
    shapeLayer.lineCap = kCALineCapRound
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = UIColor.black.cgColor
    layer.addSublayer(shapeLayer)
    
    angleVertexLayer.lineWidth = 2
    angleVertexLayer.lineCap = kCALineCapRound
    angleVertexLayer.fillColor = UIColor.clear.cgColor
    angleVertexLayer.strokeColor = UIColor.red.cgColor
    layer.addSublayer(angleVertexLayer)
    
    dotLayer.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
    dotLayer.backgroundColor = UIColor.red.cgColor
    dotLayer.cornerRadius = dotLayer.frame.width / 2
    layer.addSublayer(dotLayer)
    
    slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
    slider.sizeToFit()
    addSubview(slider)
    
    addSubview(sliderValueLabel)
    addSubview(angleValueLabel)
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
    
    //  Scale to fit and center path inside the top half of this view.
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
    
    angleValueLabel.text = "Tangent angle: \(angleValue.radiansToDegrees.string(fractionDigits: 2)) °"
    angleValueLabel.sizeToFit()
    angleValueLabel.frame.size.width = slider.frame.width
    angleValueLabel.frame.origin.x = 32
    angleValueLabel.frame.origin.y = sliderValueLabel.frame.maxY + 32
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
