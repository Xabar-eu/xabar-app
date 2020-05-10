//
//  CoreVC.swift
//  XaBar
//
//  Created by Jan Kožnárek on 28/12/2019.
//  Copyright © 2019 Jan Kožnárek. All rights reserved.
//

import Cocoa

class CoreVC: NSViewController {

    let delegate = NSApplication.shared.delegate as! AppDelegate
    var overlay: Overlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupOverlay()
        
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
        
    }
    
}


//MARK: SETUP METHODS
extension CoreVC {
    
    private func setupOverlay() {
        
        self.overlay = Overlay(targetView: self.view)
        self.view.addSubview(overlay)
        overlay.stopLoading()
        
    }
    
}
