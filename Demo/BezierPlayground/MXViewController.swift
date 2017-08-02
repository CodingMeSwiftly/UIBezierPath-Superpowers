//
//  MXViewController.swift
//  SteelPicture
//
//  Created by Maximilian Kraus on 21/06/15.
//  Copyright © 2015 Maximilian Kraus. All rights reserved.
//

import UIKit

class MXViewController: UIViewController {
  
  @nonobjc class var viewClass: UIView.Type {
    return UIView.self
  }
  
  var prefersNavigationBarHidden: Bool {
    return false
  }
  
  fileprivate var viewWillAppearOnceToken = true
  fileprivate var viewDidAppearOnceToken = true
  
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  //  Storyboards are incompatible with truth and beauty.
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}


//MARK: - View lifecycle
extension MXViewController {
  override func loadView() {
    let viewFrame: CGRect
    
    if let parent = parent {
      viewFrame = parent.view.bounds
    } else {
      viewFrame = UIScreen.main.bounds
    }
    
    let view = type(of: self).viewClass.init()
    view.frame = viewFrame
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.view = view
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(prefersNavigationBarHidden, animated: animated)
    
    if viewWillAppearOnceToken {
      viewWillAppearOnceToken = false
      viewWillAppearOnce(animated)
    }
  }
  
  func viewWillAppearOnce(_ animated: Bool) {
    //  No op.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if viewDidAppearOnceToken {
      viewDidAppearOnceToken = false
      viewDidAppearOnce(animated)
    }
  }
  
  func viewDidAppearOnce(_ animated: Bool) {
    //  No op.
  }
}
//  -
