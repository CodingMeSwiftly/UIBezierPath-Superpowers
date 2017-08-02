//
//  TangentDemoViewController.swift
//  BezierPlayground
//
//  Created by Maximilian Kraus on 01.08.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

class TangentDemoViewController: MXViewController {
  override class var viewClass: UIView.Type {
    return TangentDemoView.self
  }
  
  private var mx_view: TangentDemoView {
    return view as! TangentDemoView
  }
  
  let demo: Demo
  
  init(demo: Demo) {
    self.demo = demo
    
    super.init()
    
    title = demo.displayName
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .never
    }
    
    mx_view.configure(with: demo.path)
    mx_view.slider.addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    updateView(forSliderValue: 0)
  }
  
  @objc private func sliderValueDidChange(sender: UISlider) {
    updateView(forSliderValue: CGFloat(sender.value))
  }
  
  func updateView(forSliderValue value: CGFloat) {
    guard let path = mx_view.path else { return }
    
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    
    let p = path.mx_point(atFractionOfLength: value)
    mx_view.dotLayer.position = p
    
    
    let angle = path.mx_tangentAngle(atFractionOfLength: value)
    
    let vertexPath = UIBezierPath()
    vertexPath.move(to: p)
    
    mx_view.angleValue = angle
    
    let pp = CGPoint(x: p.x + 80, y: p.y)
    vertexPath.addLine(to: pp.rotate(around: p, by: angle))
    mx_view.angleVertexLayer.path = vertexPath.cgPath
    
    mx_view.setNeedsLayout()
    
    CATransaction.commit()
  }
}

fileprivate extension CGPoint {
  //  Counter clockwise rotation
  func rotate(around center: CGPoint, by angle: CGFloat) -> CGPoint {
    let dx = self.x - center.x
    let dy = self.y - center.y
    let radius = sqrt(dx * dx + dy * dy)
    let azimuth = atan2(dy, dx)
    let newAzimuth = azimuth - angle
    let x = center.x + radius * cos(newAzimuth)
    let y = center.y + radius * sin(newAzimuth)
    return CGPoint(x: x, y: y)
  }
}
