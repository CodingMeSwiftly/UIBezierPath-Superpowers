//
//  MXView.swift
//  Apeidos
//
//  Created by Maximilian Kraus on 23/12/15.
//  Copyright © 2015 Maximilian Kraus. All rights reserved.
//

import UIKit

class MXView: UIView {
  init() {
    super.init(frame: .zero)
  }
  
  //  Storyboards are incompatible with truth and beauty.
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
