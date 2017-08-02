//
//  FractionDemoViewController.swift
//  UIBezierPath+Length
//
//  Created by Maximilian Kraus on 15.07.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

class FractionDemoViewController: MXViewController {
  
  override class var viewClass: UIView.Type {
    return FractionDemoView.self
  }
  
  private var mx_view: FractionDemoView {
    return view as! FractionDemoView
  }
  
  let demo: Demo
  
  init(demo: Demo) {
    self.demo = demo
    
    super.init()
    
    title = demo.displayName
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if case .custom = demo {
      mx_view.scaleAndCenterPath = false
    }
    
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .never
    }
    
    mx_view.configure(with: demo.path)
    mx_view.slider.addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
  }
  
  @objc private func sliderValueDidChange(sender: UISlider) {
    guard let path = mx_view.path else { return }
    
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    
    mx_view.dotLayer.position = path.mx_point(atFractionOfLength: CGFloat(sender.value))
    
    CATransaction.commit()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    switch demo {
    case .custom: break
    default: return
    }
    
    guard let path = mx_view.path, let touchLocation = touches.first?.location(in: view) else { return }
    
    if mx_view.pathRect.contains(touchLocation) {
      if path.isEmpty {
        path.move(to: CGPoint(x: mx_view.pathRect.midX, y: mx_view.pathRect.midY))
      }
      
      path.addLine(to: touchLocation)
      mx_view.configure(with: path)
    }
  }
}
