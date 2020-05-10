//
//  SettingsVC.swift
//  XaBar
//
//  Created by Jan Kožnárek on 09/05/2020.
//  Copyright © 2020 Jan Kožnárek. All rights reserved.
//

import Foundation
import AppKit

class SettingsVC: CoreVC {
    
    typealias SM = SettingsManager
    
    static var canOpenWindow: Bool = true
    
    @IBOutlet var widthField: NSTextField!
    @IBOutlet var heightField: NSTextField!
    
    @IBOutlet var allowAnimationsCheckbox: NSButton!
    @IBOutlet var allowAutoCloseCheckbox: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        
    }
    
    
    private func prepareView() {
    
        allowAutoCloseCheckbox.state = boolToState(SM.get(.enableAutoClose))
        allowAnimationsCheckbox.state = boolToState(SM.get(.enableAnimations))
        widthField.stringValue = String(SM.get(.width))
        heightField.stringValue = String(SM.get(.height))
        
    }
    
    
    static func openInWindow() -> Void {

        let storyboard = NSStoryboard(name: "Main", bundle: nil)

        guard let vc = storyboard.instantiateController(withIdentifier: "SettingsVC") as? SettingsVC else {
            fatalError("Why cant i find MainViewController? - Check Main.storyboard")
        }
        
        SettingsVC.canOpenWindow = false
        
        NSApp.setActivationPolicy(.regular)
        vc.presentAsModalWindow(vc)
    }
    

    deinit {
        SettingsVC.canOpenWindow = true
    }

    
}


//MARK: ACTION METHODS
extension SettingsVC {
    
    @IBAction func widthChanged(_ sender: NSTextField) {
        
        SM.set(.width, value: Int(sender.stringValue) ?? 500)
        updateWindowSize()
        
    }
    
    
    @IBAction func heightChanged(_ sender: NSTextField) {
         
        SM.set(.height, value: Int(sender.stringValue) ?? 500)
        updateWindowSize()
        
    }
    
    
    @IBAction func allowAnimationsChanged(_ sender: NSButton) {
        
        SM.set(.enableAnimations, value: stateToBool(sender.state))
        delegate.popover.animates = SM.get(.enableAnimations)
        
    }
    
    
    @IBAction func allowAutoCloseChanged(_ sender: NSButton) {
        
        SM.set(.enableAutoClose, value: stateToBool(sender.state))
        delegate.popover.animates = SM.get(.enableAutoClose)
        
    }
    
    
}


//MARK: HELPER METHODS
extension SettingsVC {
    
    
    func boolToState(_ bool: Bool) -> NSControl.StateValue {
        return bool == true ? .on : .off
    }
    
    func stateToBool(_ state: NSControl.StateValue) -> Bool {
        return state == .on ? true : false
    }
    
    
    private func updateWindowSize() {
        
        let width = SM.get(.width)
        let height = SM.get(.height)
        
        delegate.popover.contentSize = NSSize(width: width, height: height)
        
    }
    
    
}
