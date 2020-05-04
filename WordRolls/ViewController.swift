//
//  ViewController.swift
//  WordRolls
//
//  Created by sudeep on 03/12/19.
//  Copyright © 2019 sudeep. All rights reserved.
//

import Cocoa
import CoreGraphics

class ViewController: NSViewController, NSTextViewDelegate, NSTextFieldDelegate
{
  // MARK:- Properties
  // LHS
  @IBOutlet weak var leftBackView: NSView!
  @IBOutlet weak var wordField: NSTextField!
  @IBOutlet weak var fragmentedWordField: NSTextField!
  @IBOutlet var meaningField: NSTextView!
  @IBOutlet var exampleField: NSTextView!
  //RHS
  @IBOutlet weak var rightBackView: NSView!
  @IBOutlet weak var wordLabel: NSTextField!
  @IBOutlet weak var fragmentedWordLabel: NSTextField!
  @IBOutlet weak var meaningLabel: NSTextField!
  @IBOutlet weak var exampleLabel: NSTextField!
  
  // MARK:- Start
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    setupUI()
  }
  
  // MARK:- Helper
  
  func setupUI()
  {
    colorBackgroundOf(view: leftBackView, color: NSColor.white)
    colorBackgroundOf(view: rightBackView, color: NSColor.white)
    
    // temp
    colorBackgroundOf(view: rightBackView, color: NSColor.init(deviceRed: 0.8, green: 0.6, blue: 0.8, alpha: 1.0))
  }
  
  /// Color Background of NSView
  /// - Parameters:
  ///   - view: provide NSView you  want to color
  ///   - color: provide color
  func colorBackgroundOf(view:NSView, color:NSColor) {
    view.wantsLayer = true
    view.layer?.backgroundColor = color.cgColor
  }
  
  // MARK:- Text Editing
  
  func controlTextDidChange(_ obj: Notification)
  {
    let textField = obj.object as! NSTextField
    let text = textField.stringValue
    
    // kerning
    // https://stackoverflow.com/a/13586537
    let style = NSMutableParagraphStyle()
    style.alignment = NSTextAlignment.center
    
    let attrString = NSMutableAttributedString(string: text, attributes: [.paragraphStyle: style])
    let range = NSMakeRange(0, text.count - 1)
    
    switch textField {
      
    case wordField:
      attrString.addAttribute(.kern, value: 1.25, range: range)
      wordLabel.attributedStringValue = attrString
      break
      
    case fragmentedWordField:
      attrString.addAttribute(.kern, value: 0.88, range: range)
      fragmentedWordLabel.attributedStringValue = attrString
      break
      
    case meaningField:
      meaningLabel.stringValue = textField.stringValue
      break
      
    case exampleField:
      exampleLabel.stringValue = textField.stringValue
      break
      
    default:
      break
    }
  }
  
  func textDidChange(_ notification: Notification) {
    let textView = notification.object as! NSTextView
    
    switch textView {
    case meaningField:
      meaningLabel.stringValue = textView.string
      break
      
    case exampleField:
      exampleLabel.stringValue = textView.string
      break
      
    default:
      break
    }
  }
  
  // MARK:- Actions
  
  @IBAction func modeChanged(_ sender: NSSegmentedControl) {
    let textColor = sender.selectedSegment == 0 ? NSColor.white : NSColor.init(white: 0.08, alpha: 1.0)
    wordLabel.textColor = textColor
    fragmentedWordLabel.textColor = textColor
    meaningLabel.textColor = textColor
    exampleLabel.textColor = textColor
  }
  
  @IBAction func colorPicked(_ sender: NSColorWell) {
    colorBackgroundOf(view: rightBackView, color: sender.color)
  }
  
  @IBAction func exportTapped(_ sender: Any) {
    
    let date = NSDate()
    
    let savePanel = NSSavePanel()
    savePanel.canCreateDirectories = true
    savePanel.showsTagField = false
    savePanel.nameFieldStringValue = date.description + ".png"
    savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
    
    savePanel.begin { (result) in
      if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
        self.exportTo(path: savePanel.url!)
      }
    }
  }
  
  func exportTo(path:URL) {
    
    let captureView = rightBackView
    
    let imageRepresentation = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1080, pixelsHigh: 1080, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let capSize = (captureView?.bounds.size)!
    imageRepresentation.size = capSize
    
    // turning off anti-aliasing makes the font thinner
    // anti-aliasing adds a small grey border/shadow around the text
    // photoshop template uses "crisp" as the anti-aliasing style
    // https://stackoverflow.com/a/28319100
    // https://github.com/k06a/Mattericon/blob/master/UXMaterial/NSTextField%2BAntialiasing.m
    #warning("unable to replicate photoshop's crisp anti-aliasing. consider adding a small shadow around the text")
    let context = NSGraphicsContext(bitmapImageRep: imageRepresentation)!
    context.cgContext.setAllowsAntialiasing(false)
    context.cgContext.setShouldAntialias(false)
    context.cgContext.setAllowsFontSmoothing(false)
    context.cgContext.setShouldSmoothFonts(false)
    context.cgContext.setAllowsFontSubpixelPositioning(false)
    context.cgContext.setAllowsFontSubpixelQuantization(false)
    captureView?.layer!.render(in: context.cgContext)
    
    let imag = NSImage(cgImage: imageRepresentation.cgImage!, size: CGSize(width: 1080, height: 1080))
    
    let cgImg = imag.cgImage(forProposedRect: nil, context: nil, hints: nil)
    let imgRep = NSBitmapImageRep(cgImage: cgImg!)
    let data = imgRep.representation(using: .png, properties: [:])
    
    do {
      try data?.write(to: path, options: .atomic)
      //
      let alert = NSAlert()
      alert.messageText = "Success"
      alert.informativeText = "Image export successfully"
      alert.alertStyle = .informational
      alert.addButton(withTitle: "OK")
      alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
      //
    } catch {
      print(error)
    }
  }
  
  //MARK: End
}
