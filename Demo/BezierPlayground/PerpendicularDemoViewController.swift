//
//  PerpendicularDemoViewController.swift
//  BezierPlayground
//
//  Created by Maximilian Kraus on 31.07.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit

fileprivate extension PerpendicularCalculationPrecision {
  var displayString: String {
    switch self {
    case .low: return "Low"
    case .normal: return "Normal"
    case .high: return "High"
    }
  }
}

class PerpendicularDemoViewController: MXViewController {
  
  private struct Settings {
    var showLookupPoints = true
    var perpendicularCalculationPrecision: PerpendicularCalculationPrecision = .normal
  }
  
  private var settings = Settings()
  
  override class var viewClass: UIView.Type {
    return PerpendicularDemoView.self
  }
  
  private var mx_view: PerpendicularDemoView! {
    return view as! PerpendicularDemoView
  }
  
  private var perpendicularLayer: CAShapeLayer {
    return mx_view.perpendicularLayer
  }
  
  
  let demo: Demo
  
  init(demo: Demo) {
    self.demo = demo
    
    super.init()
    
    title = demo.displayName
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(PerpendicularDemoViewController.barButtonTapped))
    
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .never
    }
    mx_view.configure(with: demo.path)
  }
  
  
  @objc private func barButtonTapped(sender: UIBarButtonItem) {
    let actionSheet = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: (settings.showLookupPoints ? "Hide" : "Show") + " lookup points", style: .default) { [weak self] _ in
      guard let strongOp = self else { return }
      
      strongOp.settings.showLookupPoints = !strongOp.settings.showLookupPoints
      strongOp.mx_view.showLookupPoints = strongOp.settings.showLookupPoints
    })
    
    actionSheet.addAction(UIAlertAction(title: "Calculation precision", style: .default) { [weak self] _ in
      guard let strongOp = self else { return }
      
      let inner = UIAlertController(title: "Calculation precision", message: nil, preferredStyle: .actionSheet)
      
      let precisionSettings: [PerpendicularCalculationPrecision] = [.low, .normal, .high]
      
      for setting in precisionSettings {
        inner.addAction(UIAlertAction(title: setting.displayString, style: .default) { _ in
          perpendicularCalculationPrecision = setting
          strongOp.mx_view.path?.invalidatePathCalculations()
          strongOp.mx_view.setNeedsLayout()
        })
      }
      
      inner.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      
      strongOp.present(inner, animated: true, completion: nil)
    })
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(actionSheet, animated: true, completion: nil)
  }
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    guard let touchLocation = touches.first?.location(in: view) else { return }
    
    mx_view.hintLabel.isHidden = true
    
    let path = UIBezierPath()
    path.move(to: touchLocation)
    path.addLine(to: mx_view.path!.mx_perpendicularPoint(for: touchLocation))
    
    perpendicularLayer.path = path.cgPath
    perpendicularLayer.opacity = 1
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    
    guard let touchLocation = touches.first?.location(in: view) else { return }
    
    let path = UIBezierPath()
    path.move(to: touchLocation)
    path.addLine(to: mx_view.path!.mx_perpendicularPoint(for: touchLocation))
    
    perpendicularLayer.path = path.cgPath
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    perpendicularLayer.opacity = 0
  }

}
