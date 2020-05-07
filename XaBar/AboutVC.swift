//
//  AboutVC.swift
//  MessengerMenubar3
//
//  Created by Jan Kožnárek on 22/04/2019.
//  Copyright © 2019 Jan Kožnárek. All rights reserved.
//

import Cocoa

class AboutVC: CoreVC {

    @IBOutlet weak var versionLable: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLable.stringValue = "Version: \(version)"
        }
        
    }
    

    
}
