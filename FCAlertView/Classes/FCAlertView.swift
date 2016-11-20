//
//  FCAlertView.swift
//  FCAlertView
//
//  Created by Kris Penney on 2016-08-26.
//  Copyright © 2016 Kris Penney. All rights reserved.
//

import UIKit

public enum FCAlertType {
  case caution
  case success
  case warning
}

open class FCAlertView: UIView {
  
  var defaultHeight: CGFloat = 200
  var defaultSpacing: CGFloat = 105
  
  var alertView: UIView?
  var alertViewContents: UIView?
  let circleLayer: CAShapeLayer = {
    let circle = CAShapeLayer()
    circle.fillColor = UIColor.white.cgColor
    return circle
  }()
  
  var buttonTitles: [String]?
  var alertViewWithVector = 0
  var doneTitle: String?
  var vectorImage: UIImage?
  
  var firstRun = true
  
  //Delegate
  open var delegate: FCAlertViewDelegate?
  
  //AlertView Title & Subtitle Text
  var title: String?
  var subTitle: String = "You need to have a title or subtitle to use FCAlertView 😀"
  
  // AlertView Background : Probably take frame out & make it constant
  let alertBackground: UIView = {
    let alertBackgroundView = UIView()
    alertBackgroundView.backgroundColor = UIColor(white: 0, alpha: 0.35)
    
    return alertBackgroundView
  }()
  
  // AlertView Customizations
  var numberOfButtons = 0
  open var autoHideSeconds = 0
  open var cornerRadius: CGFloat = 18
  
  open var dismissOnOutsideTouch = false
  open var hideAllButtons = false
  open var hideDoneButton = false
  
  // Color Schemes
  open var colorScheme: UIColor?
  open var titleColor: UIColor = .black
  open var subTitleColor: UIColor = .black
  
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    firstRun = true
    
    backgroundColor = .clear
    
    addSubview(alertBackground)
    
    checkCustomizationValid()
  }
  
  // Default Init
  public convenience init() {
    
    let result = UIScreen.main.bounds.size
    
    let frame = CGRect(x: 0, y: 0, width: result.width, height: result.height)
    
    self.init(frame: frame)
    
  }
  
  // Initialize with a default theme
  public convenience init(type: FCAlertType){
    let result = UIScreen.main.bounds.size
    
    let frame = CGRect(x: 0, y: 0, width: result.width, height: result.height)
    self.init(frame: frame)
    
    switch type {
    case .caution:
      makeAlertTypeCaution()
    case .success:
      makeAlertTypeSuccess()
    case .warning:
      makeAlertTypeWarning()
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Customization Data Checkpoint
  fileprivate func checkCustomizationValid(){
    if (title == nil || title!.isEmpty) &&
      subTitle.isEmpty {
      subTitle = "You need to have a title or subtitle to use FCAlertView 😀"
    }
    
    if (doneTitle == nil || doneTitle!.isEmpty){
      doneTitle = "Ok"
    }
    
    if cornerRadius == 0 {
      cornerRadius = 18
    }
    
    if vectorImage != nil {
      alertViewWithVector = 1
    }
  }
  
  // MARK: Touch Events
  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let touchPoint = touch.location(in: alertBackground)
      let touchPoint2 = touch.location(in: alertViewContents)
      
      let isPointInsideBackview = alertBackground.point(inside: touchPoint, with: nil)
      let isPointInsideAlertView = alertViewContents!.point(inside: touchPoint2, with: nil)
      
      if dismissOnOutsideTouch && isPointInsideBackview && !isPointInsideAlertView {
        dismissAlertView()
      }
    }
  }
  
  // MARK: Drawing AlertView
  fileprivate func setupAlertViewFrame() -> CGRect {
    let result = UIScreen.main.bounds.size
    var alertViewFrame: CGRect

    alertBackground.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    
    //  Adjusting AlertView Frames
    if alertViewWithVector == 1 {
      alertViewFrame = CGRect(x: self.frame.size.width/2 - ((result.width - defaultSpacing)/2),
                                  y: self.frame.size.height/2 - (200.0/2),
                                  width: result.width - defaultSpacing,
                                  height: defaultHeight)
    }else{
      alertViewFrame = CGRect(x: self.frame.size.width/2 - ((result.width - defaultSpacing)/2),
                                  y: self.frame.size.height/2 - (170.0/2),
                                  width: result.width - defaultSpacing,
                                  height: defaultHeight - 30)
    }
    
    //  Frames for when AlertView doesn't contain a title
    if title == nil {
      alertViewFrame = CGRect(x: self.frame.size.width/2 - ((result.width - defaultSpacing)/2),
                                  y: self.frame.size.height/2 - ((alertViewFrame.size.height - 50)/2),
                                  width: result.width - defaultSpacing,
                                  height: alertViewFrame.size.height - 10)
    }
    
    //  Frames for when AlertView has hidden all buttons
    if hideAllButtons {
      alertViewFrame = CGRect(x: self.frame.size.width/2 - ((result.width - defaultSpacing)/2),
                                  y: self.frame.size.height/2 - ((alertViewFrame.size.height - 50)/2), width: result.width - defaultSpacing,
                                  height: alertViewFrame.size.height - 45)
    } else{
      
      // Frames for when AlertView has hidden the DONE/DISMISS button
      if hideDoneButton && numberOfButtons == 0 {
        alertViewFrame = CGRect(x: self.frame.size.width/2 - ((result.width - defaultSpacing)/2),
                                    y: self.frame.size.height/2 - ((alertViewFrame.size.height - 50)/2), width: result.width - defaultSpacing,
                                    height: alertViewFrame.size.height - 45)
      }
      
      // Frames for AlertView with 2 added buttons (vertical buttons)
      if !hideDoneButton && numberOfButtons >= 2 {
        alertViewFrame = CGRect(x: self.frame.size.width/2 - ((result.width - defaultSpacing)/2),
                                    y: self.frame.size.height/2 - ((alertViewFrame.size.height - 50 + 140)/2), width: result.width - defaultSpacing,
                                    height: alertViewFrame.size.height - 50 + 140)
      }
    }
    return alertViewFrame
  }
  
  fileprivate func renderCircleCutout(withAlertViewFrame alertViewFrame: CGRect){
    let radius = alertView!.frame.size.width
    let rectPath = UIBezierPath(roundedRect: CGRect(x: 0,
      y: 0,
      width: frame.size.width,
      height: alertView!.frame.size.height),
                                cornerRadius: 0)
    let circlePath = UIBezierPath(roundedRect: CGRect(x: alertViewFrame.size.width/2 - 33.75,
      y: -33.75,
      width: 67.5,
      height: 67.5),
                                  cornerRadius: radius)
    
    rectPath.append(circlePath)
    rectPath.usesEvenOddFillRule = true
    
    let fillLayer = CAShapeLayer()
    fillLayer.path = rectPath.cgPath
    fillLayer.fillRule = kCAFillRuleEvenOdd
    fillLayer.fillColor = UIColor.white.cgColor
    fillLayer.opacity = 1
    
    alertView!.layer.addSublayer(fillLayer)
  }
  
  fileprivate func renderHeader(withAlertViewFrame alertViewFrame: CGRect){

    let titleLabel = UILabel(frame: CGRect(x: 15.0,
      y: 20.0 + CGFloat(alertViewWithVector * 30),
      width: alertViewFrame.size.width - 30.0,
      height: 20.0))
    titleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
    titleLabel.numberOfLines = 1
    titleLabel.textColor = titleColor
    titleLabel.text = title
    titleLabel.textAlignment = .center
    
    let descriptionLevel = (title == nil) ? 25 : 45
    
    let descriptionLabel = UILabel(frame: CGRect(x: 25.0,
      y: CGFloat(descriptionLevel + alertViewWithVector * 30),
      width: alertViewFrame.size.width - 50.0,
      height: 60.0))
    descriptionLabel.font = (title == nil) ? UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular) :
      UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight)
    
    descriptionLabel.numberOfLines = 4
    descriptionLabel.textColor = subTitleColor
    descriptionLabel.text = subTitle
    descriptionLabel.textAlignment = .center
    descriptionLabel.adjustsFontSizeToFitWidth = true
    
    //  Separator Line - Separating Header View with Button View
    let separatorLineView = UIView(frame: CGRect(x: 0,
      y: alertViewFrame.size.height - 47,
      width: alertViewFrame.size.width,
      height: 2))
    separatorLineView.backgroundColor = UIColor(white: 100/255, alpha: 1)
    
    let blurEffect = UIBlurEffect(style: .extraLight)
    
    let visualEffectView = UIVisualEffectView(effect: blurEffect)
    visualEffectView.frame = separatorLineView.bounds
    visualEffectView.isUserInteractionEnabled = false
    
    separatorLineView.addSubview(visualEffectView)
    
    //  Adding Contents - Conteained in Header and Separator Views
    alertViewContents!.addSubview(titleLabel)
    alertViewContents!.addSubview(descriptionLabel)
    
//     numberOfButtons == 1 && !hideDoneButton &&
    if !hideAllButtons {
      alertViewContents!.addSubview(separatorLineView)
    }
  }
  
  override open func draw(_ rect: CGRect) {
    
    alpha = 0
    
    let alertViewFrame = setupAlertViewFrame()
    
    //  Setting up contents of AlertView
    alertViewContents = UIView(frame: alertViewFrame)
    alertViewContents!.backgroundColor = .clear
    addSubview(alertViewContents!)
    
    alertView = UIView(frame: CGRect(x: 0, y: 0, width: alertViewFrame.size.width, height: alertViewFrame.size.height))
    
    //  Setting Background Color of AlertView
    if alertViewWithVector == 1 {
      alertView!.backgroundColor = .clear
    }else{
      alertView!.backgroundColor = .white
    }
    
    alertViewContents!.addSubview(alertView!)
    
    // CREATING ALERTVIEW
    // CUSTOM SHAPING - Displaying Cut out circle for Vector Type Alerts
    
    if alertViewWithVector == 1 {
      renderCircleCutout(withAlertViewFrame: alertViewFrame)
    }
    
    //  HEADER VIEW - With Title & Subtitle
    renderHeader(withAlertViewFrame: alertViewFrame)
    
    //  Button(s) View - Section containing all Buttons
    
    // View only contains DONE/DISMISS Button
    if(!hideAllButtons && !hideDoneButton && numberOfButtons == 0) {
      let doneButton = UIButton(type: .system)
      if let colorScheme = self.colorScheme {
        doneButton.backgroundColor = colorScheme
        doneButton.tintColor = .white
      }else{
        doneButton.backgroundColor = .white
      }
      
      doneButton.frame = CGRect(x: 0,
                                    y: alertViewFrame.size.height - 45,
                                    width: alertViewFrame.size.width,
                                    height: 45)
      doneButton.setTitle(doneTitle, for: UIControlState())
      doneButton.addTarget(self, action: #selector(donePressed(_:)), for: .touchUpInside)
      doneButton.titleLabel!.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
      
      
      alertView!.addSubview(doneButton)
    }
    else if !hideAllButtons && numberOfButtons == 1 { // View also contains OTHER (One) Button
      
      // Render user button
      let otherButton = UIButton(type: .system)
      otherButton.backgroundColor = .white
      
      otherButton.setTitle(buttonTitles![0], for: UIControlState())
      otherButton.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
      otherButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
      otherButton.tintColor = colorScheme
      otherButton.titleLabel?.adjustsFontSizeToFitWidth = true
      otherButton.titleLabel?.minimumScaleFactor = 0.8

      
      if !hideDoneButton {
        
        otherButton.frame = CGRect(x: 0,
                                       y: alertViewFrame.size.height - 45,
                                       width: alertViewFrame.size.width/2,
                                       height: 45)
        
        //Render Done buttons
        let doneButton = UIButton(type: .system)
        
        if let colorScheme = self.colorScheme {
          doneButton.backgroundColor = colorScheme
          doneButton.tintColor = .white
        }else{
          doneButton.backgroundColor = .white
        }
        
        doneButton.frame = CGRect(x: alertViewFrame.size.width/2,
                                      y: alertViewFrame.size.height - 45,
                                      width: alertViewFrame.size.width/2,
                                      height: 45)
        doneButton.setTitle(doneTitle, for: UIControlState())
        doneButton.addTarget(self, action: #selector(donePressed(_:)), for: .touchUpInside)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        
        let horizontalSeparator = UIView(frame: CGRect(x: alertViewFrame.size.width/2 - 1,
          y: otherButton.frame.origin.y - 2,
          width: 2,
          height: 45))
        horizontalSeparator.backgroundColor = UIColor(white: 100/255, alpha: 1)
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = horizontalSeparator.bounds
        visualEffectView.isUserInteractionEnabled = false
        horizontalSeparator.addSubview(visualEffectView)
        
        alertView!.addSubview(doneButton)
        alertView!.addSubview(horizontalSeparator)
      }else{
        otherButton.frame = CGRect(x: 0,
                                       y: alertViewFrame.size.height - 45,
                                       width: alertViewFrame.size.width,
                                       height: 45)
      }
      
      alertView!.addSubview(otherButton)
      
    }else if(!hideAllButtons && numberOfButtons >= 2){
      let firstButton = UIButton(type: .system)
      firstButton.backgroundColor = .white
      
      if hideDoneButton {
        firstButton.frame = CGRect(x: 0,
                                       y: alertViewFrame.size.height - 45,
                                       width: alertViewFrame.size.width/2,
                                       height: 45)
      }else {
        firstButton.frame = CGRect(x: 0,
                                       y: alertViewFrame.size.height - 135,
                                       width: alertViewFrame.size.width,
                                       height: 45)
      }
      
      firstButton.setTitle(buttonTitles![0], for: UIControlState())
      firstButton.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
      firstButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
      firstButton.tintColor = colorScheme
      firstButton.titleLabel?.adjustsFontSizeToFitWidth = true
      firstButton.titleLabel?.minimumScaleFactor = 0.8
      firstButton.tag = 0
      
      let secondButton = UIButton(type: .system)
      secondButton.backgroundColor = .white
      secondButton.setTitle(buttonTitles![1], for: UIControlState())
      secondButton.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
      secondButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
      secondButton.tintColor = colorScheme
      secondButton.titleLabel?.adjustsFontSizeToFitWidth = true
      secondButton.titleLabel?.minimumScaleFactor = 0.8
      secondButton.tag = 0
      
      let firstSeparator = UIView(frame: CGRect(x: 0,
        y: firstButton.frame.origin.y - 2,
        width: alertViewFrame.size.width,
        height: 2))
      firstSeparator.backgroundColor = UIColor(white: 100/255, alpha: 1)
      
      let secondSeparator = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
      secondSeparator.backgroundColor = UIColor(white: 100/255, alpha: 1)
      
      let blurEffect = UIBlurEffect(style: .extraLight)
      
      let visualEffectView = UIVisualEffectView(effect: blurEffect)
      visualEffectView.frame = firstSeparator.bounds
      visualEffectView.isUserInteractionEnabled = false
      firstSeparator.addSubview(visualEffectView)
      
      let visualEffectView2 = UIVisualEffectView(effect: blurEffect)
      visualEffectView2.isUserInteractionEnabled = false
      secondSeparator.addSubview(visualEffectView2)
      
      if !hideDoneButton {
        secondButton.frame = CGRect(x: 0,
                                        y: alertViewFrame.size.height - 90,
                                        width: alertViewFrame.size.width,
                                        height: 45)
        secondSeparator.frame = CGRect(x: 0,
                                        y: secondButton.frame.origin.y - 2,
                                        width: alertViewFrame.size.width,
                                        height: 2)
        let doneButton = UIButton(type: .system)
        
        if let colorScheme = colorScheme {
          doneButton.backgroundColor = colorScheme
          doneButton.tintColor = .white
        }else{
          doneButton.backgroundColor = .white
        }
        
        doneButton.frame = CGRect(x: 0,
                                      y: alertViewFrame.size.height - 45,
                                      width: alertViewFrame.size.width,
                                      height: 45)
        doneButton.setTitle(doneTitle, for: UIControlState())
        doneButton.addTarget(self, action: #selector(donePressed(_:)), for: .touchUpInside)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        
        alertView!.addSubview(doneButton)
      }else {
        // Set proper frames for no donebutton
        secondButton.frame = CGRect(x: alertViewFrame.size.width/2,
                                        y: alertViewFrame.size.height - 45,
                                        width: alertViewFrame.size.width/2,
                                        height: 45)
        
        secondSeparator.frame = CGRect(x: alertViewFrame.size.width/2 - 1,
                                           y: secondButton.frame.origin.y,
                                           width: 2,
                                           height: 45)
      }
      
      visualEffectView2.frame = secondSeparator.bounds
      
      
      alertView!.addSubview(firstButton)
      alertView!.addSubview(secondButton)
      alertView!.addSubview(firstSeparator)
      alertView!.addSubview(secondSeparator)
    }

    
    circleLayer.path = UIBezierPath(ovalIn: CGRect(x: alertViewContents!.frame.size.width/2 - 30.0, y: -30.0, width: 60.0, height: 60.0)).cgPath
    
    
    let alertViewVector = UIButton(type: .system)
    alertViewVector.frame = CGRect(x: alertViewContents!.frame.size.width/2 - 15.0,
                                       y: -15.0,
                                       width: 30.0,
                                       height: 30.0)
    alertViewVector.setImage(vectorImage, for: UIControlState())
    alertViewVector.isUserInteractionEnabled = false
    alertViewVector.tintColor = colorScheme
    
    //  VIEW Border - Rounding Corners of AlertView
    alertView?.layer.cornerRadius = cornerRadius
    alertView?.clipsToBounds = true
    
    if alertViewWithVector == 1 {
      alertViewContents!.layer.addSublayer(circleLayer)
      alertViewContents!.addSubview(alertViewVector)
    }
    
    //  Scaling AlertView - Before Animation
    alertViewContents!.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
    
    //  Applying Shadow
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.1
    layer.shadowRadius = 10
    layer.shadowOffset = CGSize(width: 0, height: 0)
    
    
    showAlertView()
  }
  
  
  // Default Types of Alerts
  fileprivate func makeAlertTypeWarning() {
    if let path = Bundle(for: FCAlertView.self).path(forResource: "close-round", ofType: "png") {
      setTheme(iconPath: path, tintColor: .flatRed)
    }
  }
  
  fileprivate func makeAlertTypeCaution() {
    if let path = Bundle(for: FCAlertView.self).path(forResource: "alert-round", ofType: "png") {
      setTheme(iconPath: path, tintColor: .flatOrange)
    }
  }
  
  fileprivate func makeAlertTypeSuccess(){
    if let path = Bundle(for: FCAlertView.self).path(forResource: "checkmark-round", ofType: "png") {
      setTheme(iconPath: path, tintColor: .flatGreen)
    }
  }
  
  fileprivate func setTheme(iconPath path: String, tintColor color: UIColor){
    vectorImage = UIImage(contentsOfFile: path)
    alertViewWithVector = 1
    self.colorScheme = color
  }
  
  //Presenting AlertView
  open func showAlert(in alertView: UIViewController, withTitle title: String?, withSubtitle subTitle: String, withCustomImage image: UIImage?, withDoneButtonTitle done: String?, andButtons buttons: [String]?) {
    
    self.title = title
    self.subTitle = subTitle
    
    if let image = image {
      self.vectorImage = image
      alertViewWithVector = 1
    }
    
    doneTitle = done
    
    buttonTitles = buttons
    numberOfButtons = buttons?.count ?? 0
    
    checkCustomizationValid()
    alertView.view.window?.addSubview(self)
    
    if !firstRun {
      showAlertView()
    }else{
      firstRun = false
    }
    
  }
  
  // MARK: Showing and Hiding AlertView
  
  func showAlertView() {
    
    if let delegate = self.delegate {
      delegate.FCAlertViewWillAppear(in: self)
    }
    
    UIView.animate(withDuration: 0.3, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
      self.alpha = 1
      self.alertViewContents?.transform = CGAffineTransform(scaleX: 1, y: 1)
    }) { (finished) in
      if self.autoHideSeconds != 0 {
        self.perform(#selector(self.dismissAlertView), with: nil, afterDelay: Double(self.autoHideSeconds))
      }
    }
  }
  
  // Dismissing AlertView
  open func dismissAlertView() {
    UIView.animate(withDuration: 0.175, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
      self.alpha = 0
      self.alertViewContents?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }) { (finished) in
      
      if let delegate = self.delegate {
        delegate.FCAlertViewDismissed(in: self)
      }
      
      self.removeFromSuperview()
    }
  }
  
  @objc fileprivate func handleButton(_ sender: UIButton){
    guard let delegate = delegate else {
      return
    }
    
    delegate.alertView(in: self, clickedButtonIndex: sender.tag, buttonTitle: sender.titleLabel!.text!)
    
    self.dismissAlertView()
  }
  
  @objc fileprivate func donePressed(_ sender: UIButton){
    
    if let delegate = delegate {
      delegate.FCAlertDoneButtonClicked(in: self)
    }
    
    self.dismissAlertView()
  }
}
