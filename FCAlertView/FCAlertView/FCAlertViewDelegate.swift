//
//  FCAlertViewDelegate.swift
//  FCAlertView
//
//  Created by Kris Penney on 2016-08-26.
//  Copyright © 2016 Kris Penney. All rights reserved.
//

import Foundation

public protocol FCAlertViewDelegate: NSObjectProtocol {
  func alertView(_ alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title:String)
  
  // Optional
  func FCAlertViewDismissed(_ alertView: FCAlertView)
  func FCAlertViewWillAppear(_ alertView: FCAlertView)
  func FCAlertDoneButtonClicked(_ alertView: FCAlertView)
  
}

// Provide default impementation for optional methods
public extension FCAlertViewDelegate {
  func FCAlertViewDismissed(_ alertView: FCAlertView) {}
  func FCAlertViewWillAppear(_ alertView: FCAlertView) {}
  func FCAlertDoneButtonClicked(_ alertView: FCAlertView) {}
}
