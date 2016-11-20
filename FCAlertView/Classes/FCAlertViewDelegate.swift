//
//  FCAlertViewDelegate.swift
//  FCAlertView
//
//  Created by Kris Penney on 2016-08-26.
//  Copyright © 2016 Kris Penney. All rights reserved.
//

import Foundation

public protocol FCAlertViewDelegate: NSObjectProtocol {
  func alertView(in alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title:String)
  
  // Optional
  func FCAlertViewDismissed(in alertView: FCAlertView)
  func FCAlertViewWillAppear(in alertView: FCAlertView)
  func FCAlertDoneButtonClicked(in alertView: FCAlertView)
  
}

// Provide default impementation for optional methods
public extension FCAlertViewDelegate {
  func FCAlertViewDismissed(in alertView: FCAlertView) {}
  func FCAlertViewWillAppear(in alertView: FCAlertView) {}
  func FCAlertDoneButtonClicked(in alertView: FCAlertView) {}
}
